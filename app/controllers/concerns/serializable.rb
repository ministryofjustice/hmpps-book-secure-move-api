module Serializable
  extend ActiveSupport::Concern

  # Based on https://github.com/IcaliaLabs/pager-api
  def paginate(*args)
    options = args.extract_options!
    collection = args.first

    paginated_collection = paginate_collection(collection, options)

    yield(paginated_collection, options) if block_given?

    options[:meta] = pagination_meta(paginated_collection, options)
    options[:links] = pagination_links(paginated_collection, options)
    options[:json] = build_serializer(paginated_collection, options)

    render options.slice(:json, :status)
  end

  def render_json(*args)
    options = args.extract_options!
    renderable = args.first

    options[:json] = build_serializer(renderable, options)

    render options.slice(:json, :status)
  end

private

  FIRST_PAGE = 1

  def build_serializer(serializable, options)
    serializer_class = options.delete(:serializer)
    raise ArgumentError, 'serializer option must be specified' unless serializer_class

    options[:params] = merge_included_params(options)

    serializer_class.new(serializable, options.slice(:include, :fields, :meta, :links, :params))
  end

  def merge_included_params(options)
    # This converts a string or array of includes to a unique list of individual symbols for each level
    # e.g. "profile.person,profile.person_escort_record" => [:profile, :person, :person_escort_record]
    includes_list = [options[:include]].flatten.compact
    unique_resources = includes_list.map { |i| i.split('.') }.flatten.uniq.map(&:to_sym)

    options.fetch(:params, {}).merge(
      included: unique_resources,
    )
  end

  def paginate_collection(collection, options)
    options[:page] = params[:page] || FIRST_PAGE
    options[:per_page] = params[:per_page] || ::Kaminari.config.default_per_page

    collection.page(options[:page]).per(options[:per_page])
  end

  def pagination_meta(collection, options)
    options.fetch(:meta, {}).merge(
      pagination:
      {
        per_page: options[:per_page],
        total_pages: collection.total_pages,
        total_objects: collection.total_count,
      },
    )
  end

  # Based on https://github.com/rails-api/active_model_serializers
  def pagination_links(collection, options)
    no_pages = collection.total_pages.zero?

    options.fetch(:links, {}).merge(
      self: url_for_page(collection.current_page, options),
      first: url_for_page(FIRST_PAGE, options),
      prev: (url_for_page(collection.prev_page, options) unless no_pages || collection.first_page?),
      next: (url_for_page(collection.next_page, options) unless no_pages || collection.last_page?),
      last: url_for_page(no_pages ? FIRST_PAGE : collection.total_pages, options),
    )
  end

  def url_for_page(number, options)
    params = request.query_parameters.dup
    params[:page] = number
    params[:per_page] = options[:per_page]
    "#{request.protocol}#{request.host}#{request.path}?#{params.to_query}"
  end
end
