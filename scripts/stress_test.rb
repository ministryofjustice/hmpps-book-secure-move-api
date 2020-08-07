require 'net/http'
require 'uri'
require 'tty-table'

class SimpleStressTest
  def initialize(person_id)
    @person_id = person_id
    @report = {
      started_at: Time.zone.now,
      ended_at: nil,
      elapsed_profile: nil,
      elapsed_move: nil,
      elapsed_journey: nil,
      elapsed_total: nil,
      success: true,
    }
  end

  def call
    profile_id = nil
    move_id = nil
    journey_id = nil

    measure_time(:elapsed_profile) do
      profile_id = create_profile(@person_id)

      unless profile_id
        @report[:ended_at] = Time.zone.now
        @report[:success] = false

        return @report
      end
    end

    measure_time(:elapsed_move) do
      move_id = create_move(profile_id)

      unless move_id
        @report[:ended_at] = Time.zone.now
        @report[:success] = false

        return @report
      end
    end

    measure_time(:elapsed_journey) do
      journey_id = create_journey(move_id)

      unless journey_id
        @report[:success] = false
      end
    end

    @report[:ended_at] = Time.zone.now
    @report[:elapsed_total] = (@report[:ended_at] - @report[:started_at]).seconds
    @report[:profile_id] = profile_id
    @report[:move_id] = move_id
    @report[:journey_id] = journey_id

    @report
  end

private

  def create_profile(person_id)
    uri = URI("http://localhost:5000/api/v1/people/#{person_id}/profiles")

    post(uri, profile_attributes.to_json)
  end

  def create_move(profile_id)
    uri = URI('http://localhost:5000/api/moves')

    post(uri, move_attributes(profile_id).to_json)
  end

  def create_journey(move_id)
    uri = URI("http://localhost:5000/api/v1/moves/#{move_id}/journeys")

    post(uri, journey_attributes.to_json)
  end

  def post(uri, body)
    Net::HTTP.start(uri.host, uri.port) do |http|
      request = Net::HTTP::Post.new(uri, headers)
      request.body = body
      response = http.request(request)

      JSON.parse(response.body).dig('data', 'id')
    end
  end

  def headers
    {
      'Content-Type' => 'application/vnd.api+json',
      'Accept' => 'application/vnd.api+json; version=2',
      'Authorization' => 'Bearer spoofed',
    }
  end

  def profile_attributes
    {
      data: {
        type: 'profiles',
        attributes: {
          assessment_answers: [],
        },
      },
    }
  end

  def move_attributes(profile_id)
    {
      data: {
        type: 'moves',
        attributes: {
          date: Date.today,
          time_due: Time.zone.now,
          status: 'requested',
          additional_information: 'some more info',
          move_type: 'court_appearance',
        },
        relationships: {
          profile: { data: { id: profile_id, type: 'profiles' } },
          from_location: from_location_attributes,
          to_location: to_location_attributes,
          prison_transfer_reason: prison_transfer_reason_attributes,
        },
      },
    }
  end

  def journey_attributes
    {
      data: {
        type: 'journeys',
        attributes: {
          billable: true,
          timestamp: Time.zone.now,
          vehicle: { id: '12345678ABC', registration: 'AB12 CDE' },
        },
        relationships: {
          from_location: from_location_attributes,
          to_location: to_location_attributes,
        },
      },
    }
  end

  # Resettlement
  def prison_transfer_reason_attributes
    { data: { id: PrisonTransferReason.first.id, type: 'prison_transfer_reasons' } }
  end

  # Guildford
  def from_location_attributes
    { data: { id: Location.first.id, type: 'locations' } }
  end

  # Wetherby
  def to_location_attributes
    { data: { id: Location.last.id, type: 'locations' } }
  end

  def measure_result
    yield
  end

  def measure_time(request_time)
    start_time = Time.zone.now
    yield
    end_time = Time.zone.now

    elapsed = (end_time - start_time).seconds

    @report[request_time] = elapsed
  end
end

class WorstCaseStressTestOrchestrator
  def initialize(people_ids)
    @people_ids = people_ids
    @report = {
      started_at: Time.zone.now,
      ended_at: nil,
      wall_time: nil,
      results: [],
    }
  end

  def call
    @people_ids.each do |person_id|
      @report[:results] << SimpleStressTest.new(person_id).call
    end

    @report[:ended_at] = Time.zone.now
    @report[:wall_time] = (@report[:ended_at] - @report[:started_at]).seconds

    cleanup
    @report
  end

  def cleanup
    @report[:results].each do |result|
      profile_id, move_id, journey_id = result.slice(:profile_id, :move_id, :journey_id).values

      Journey.find(journey_id).destroy if journey_id
      Profile.find(profile_id).destroy if profile_id
      Move.find(move_id).destroy if move_id
    end
  end
end

class ReportPrinter
  def initialize(report)
    @report = report
    @results, @wall_time = @report.slice(:results, :wall_time).values
    @success_results = @results.select { |result| result[:success] }

    @count = @results.length
    @success_count = @success_results.length
    @failure_count = @count - @success_count
  end

  def print
    table = TTY::Table.new(headers, rows)
    summary_table = TTY::Table.new(summary_headers, summary_rows)

    puts table.render(:unicode)
    puts summary_table.render(:unicode)
  end

private

  def headers
    %w[resource mean_time total_time 99_percentile 95_percentile]
  end

  def rows
    [
      calculate_row(:profile),
      calculate_row(:move),
      calculate_row(:journey),
    ]
  end

  def summary_headers
    %w[count success_count failure_count wall_time]
  end

  def summary_rows
    [
      [
        @count,
        @success_count,
        @failure_count,
        @wall_time,
      ],
    ]
  end

  # All rows are empty - because all were failures
  def calculate_row(resource)
    return [resource, nil, nil, nil, nil] if @success_results.empty? || @success_results.length < 2

    data = @success_results.map do |result|
      result["elapsed_#{resource}".to_sym]
    end

    data = data.compact

    total_time = data.inject(:+)
    mean_time =  total_time / data.length
    ninety_ninth_percentile = percentile(data, 0.99)
    ninety_fifth_percentile = percentile(data, 0.95)

    [resource, mean_time, total_time, ninety_ninth_percentile, ninety_fifth_percentile]
  end

  def mean(count, sum)
    sum / count
  end

  def stdev; end

  def total_time(_resource)
    r.inject(:+)
  end

  # def success_count; end

  # def failure_count; end

  def percentile(values, percentile)
    values_sorted = values.sort
    k = (percentile * (values_sorted.length - 1) + 1).floor - 1
    f = (percentile * (values_sorted.length - 1) + 1).modulo(1)

    values_sorted[k] + (f * (values_sorted[k + 1] - values_sorted[k]))
  end
end
def print_summary(report)
  rows = report[:results].map do |result|
    result.slice(:elapsed_total, :elapsed_profile, :elapsed_move, :elapsed_journey).values
  end
end

people_ids = %w[
  fad10821-8760-47b8-904d-1580afe6bd60
  031ddfc0-4258-47a3-8b00-c491609ccb8f
  03809bda-cb99-466a-8748-97a01dad97a9
  05771e8b-4da1-470a-a97c-3de5e6ea86a3
  0e97968f-0291-46fa-9d6c-988ce840524c
  1407669b-a65b-4713-9086-ae13e1cbb5b4
  16095870-fdc5-4f5f-8067-5594c2beaf51
  16db1367-86b5-4903-b970-33da7ab73498
  1750c0d2-7809-49b4-bee6-897ab0908885
  186addca-52f8-4c20-bcf0-d7bf6fed090d
  1e4f852d-4f13-4c5b-a171-94f8ea633444
  1f4327ff-c4d9-46c6-9e9d-6ed075d79a6b
  23223b91-d18a-4c64-ba4e-df33afc04895
  26f2a1fa-6457-4464-a8db-d285bd03cc78
  274c2ac1-9e91-4a62-a0d5-0478fa4f3715
  28882310-a3e4-4924-bcb6-35f81e271237
  29aa5250-80b0-4835-b56f-1c2bfd4d5a7b
  2ca6213d-32b8-4c31-95d4-a4a28ad5d1ce
  2cc65156-a313-45eb-94ec-f6007f7f240b
  2cca0027-a7a0-42a9-a5f5-61f24cf8f167
  2e3d73f1-8ab6-4bd9-8587-dab7ae0acd5a
  365da0ca-2258-41d2-a227-2ac5c12acfb7
  3671a6a3-2c04-4ad8-8051-9608c419df60
  38eb32aa-2d21-4809-9db9-26988bd15887
  3be7456b-0301-4efd-af8a-31377c14d531
  42c37a90-bf1e-4b44-8f9e-4842efa3816f
  4586e8c1-1a0f-4932-8c59-6d6027c6a149
  478878fe-6d70-4076-aec0-8cdffd8b1341
  479d6926-bf85-4f11-92f1-cdd7d444ce3f
  47d0d43f-afd4-44d1-a1cf-4d0316a9f608
  48ef72f4-888a-4d40-b947-8988e8a9b507
  4c62ea98-92ae-4cbf-841d-e474ec22b6ab
  4c87ce11-f331-46a7-86db-ba4a18de9e05
  4da6a712-69f4-48e7-8a6d-da828177153e
  5037fd57-6c81-49b5-931f-40305c000c8c
  51a8299d-dc02-4b7a-84da-bab7c5b24c2e
  565fa11b-9c2a-454f-8fad-a377ab213b18
  58615013-dc0a-4afa-a0ae-66205df2cfe9
  5975dd49-69a9-42f5-bcf7-ae54f8e5cf6c
  5c3ade94-2afb-4f3b-801a-f6123351fa14
  6072ef08-5946-4e85-87fe-a31f3070c3e7
  647ee53e-22be-45d3-a172-995449a629af
  64937cc1-647a-4a36-8a3a-65140118750e
  665ffd89-2c13-4641-955e-28e5627b27b8
  6b52deeb-574c-42c6-bf48-ba6078357754
  6ffc9a8f-ed93-4888-bf97-9e82eaf3f4d4
  72afbe58-6a89-4bf8-8866-67600a471591
  749c9de5-9810-4ca7-a45d-edf62b1f9989
  77b22141-4e25-4647-8abc-c07457ff5cf4
  782f9bd0-3d3c-462b-9334-655261418193
  7c62aabb-a571-4513-a3d5-06cb4490d0b0
  7c7cd9ce-264e-41c0-81f6-37384553ff82
  7f1afebf-6280-470b-8af8-7f4bee759b8e
  84f27217-ba13-4ba3-a77c-ea58b6c6e892
  87caadeb-7e94-41a4-a4fa-2db046b37d47
  8a2301d1-5835-472f-a42d-c96f93cbb9ab
  8c84fd41-1279-4220-8ac8-c1c7eaa4aa1e
  8e4844f0-dced-4085-ae02-a2df11d5fa8e
  8f50d9a6-bfc8-4836-a834-69e0b81d3042
  935c37a7-46ba-4a36-9cd2-8dc5be14d15c
  979a76d9-76dd-4ac1-aa97-cf31eb45aa41
  9e25b61d-3aa7-4a5f-9900-63586ab116aa
  a0ebb970-661f-448b-b42d-55cfc5bf154b
  a14c2fec-a40c-409c-94f6-b452da2200e4
  a20c41ee-7e65-4034-a143-0ea631135cbf
  a3af6a59-723d-46c2-8f8d-c244190f65c1
  a459b1a7-a0b5-4026-8c2f-36ef28f26935
  a5c26f29-d6c3-4660-b57d-129b50ff1157
  a62c027b-1625-40e1-9dc3-82df98d76adb
  a6e07603-13ce-4b07-8ca8-8879d7c62424
  a6e7ac13-86dd-4b35-b6ef-f02c6949cbde
  adeab547-5162-4def-834b-c2064d3746cc
  ae41ccd6-8c03-44fd-8f8b-97288dd59f02
  aee32ceb-161d-46c5-b216-1bb5435eab94
  af3e1fe3-2398-44e0-8b78-10f83f1e5648
  b1216049-8a40-4bc5-936a-23b79274e379
  b200a395-9ba2-40ff-bb9d-46a70586a472
  b411df46-8c15-4a12-9f59-4b684efdbfb0
  b62e842c-eb00-4be1-8e69-6eec9e62b7cd
  b867c149-e850-47b5-bd48-10643298e91a
  bee13edf-f1dc-43f1-8043-ea4542bd3ba9
  bf623be9-43fd-4cde-8f11-2bd68ed3b2a5
  bfa6ef20-a28a-4636-a121-43157da3dbf3
  c14ab698-0251-487c-b1a7-efdeaaeddcc3
  ca7a6f47-3c74-4cd1-a459-749ea84356ae
  cad4414b-9782-494d-af5f-008b7dcffa2e
  cda9aa22-4d73-490b-80e5-5b52350b95b2
  d1306234-b25f-4db6-8a93-b505301bc988
  d9eab1d5-ba15-491e-9a37-aa5a0ca56871
  daca821f-6bae-45f9-8ffe-a2afc45bd244
  dee660c1-ecab-4dd1-bfdc-723017d9acd1
  df3d5e1a-3400-4a38-8bb2-ecfd09bb1b3c
  dfac6e75-ea19-480d-9f89-02b044fcafce
  e6f64cbc-026f-4b98-af8c-d9a034e6a67e
  e710419d-48af-42b5-8ac4-717d3cbf35ce
  e80eb451-6761-45fd-ac87-e089296b4558
  ed0ea311-925a-44b0-a8f8-32959022f2d7
  ed0fd666-56c3-48c6-88a7-c7bf22184538
  ee00d58b-e7d0-46e4-b480-92332d10c9fb
  fa09b39c-14dd-4cac-a766-951f483021e4
]

report = WorstCaseStressTestOrchestrator.new(people_ids).call

ReportPrinter.new(report).print
