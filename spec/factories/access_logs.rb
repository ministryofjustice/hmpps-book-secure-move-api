FactoryBot.define do
  factory :access_log do
    id { '35cc6a19-0d88-453a-a0cb-970e161b5cbb' }
    request_id { 'b68c0883-540c-426a-a9a4-daf586eb5c78' }
    timestamp { Time.zone.now }
    whodunnit { 'AUSER01' }
    client { 'basm-front-end' }
    verb { 'GET' }
    controller_name { 'Move' }
    path { '/moves/787595a8-7052-4de5-b991-33a4b4f4bc47/' }
    params { '?include=court_hearings' }
  end

  trait :get do
    verb { AccessLog::HTTP_GET }
  end

  trait :put do
    verb { AccessLog::HTTP_PUT }
  end

  trait :post do
    verb { AccessLog::HTTP_POST }
  end

  trait :patch do
    verb { AccessLog::HTTP_PATCH }
  end

  trait :delete do
    verb { AccessLog::HTTP_DELETE }
  end

  trait :head do
    verb { AccessLog::HTTP_HEAD }
  end

end
