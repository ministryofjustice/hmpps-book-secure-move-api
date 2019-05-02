# frozen_string_literal: true

PagerApi.setup do |config|
  config.pagination_handler = :kaminari
  config.include_pagination_on_meta = true
end
