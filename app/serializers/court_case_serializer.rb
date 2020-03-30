class CourtCaseSerializer < ActiveModel::Serializer
  attributes :nomis_case_id, :nomis_case_status, :nomis_case_start_date,
             :nomis_case_type, :nomis_case_number

  belongs_to :location, serializer: LocationSerializer

  def nomis_case_id
    object.id
  end

  def nomis_case_status
    object.case_status
  end

  def nomis_case_start_date
    object.begin_date
  end

  def nomis_case_type
    object.case_type
  end

  def nomis_case_number
    object.case_info_number
  end

  # def location_id
  #   location = Location.find_by nomis_agency_id: object.agency_id
  #   if location
  #     location.id
  #   end
  # end

  # def location
  #   location = Location.find_by nomis_agency_id: object.agency_id
  #
  #   if location
  #     LocationSerializer.new(location)
  #   end
  # end
end
