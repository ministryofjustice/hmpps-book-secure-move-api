module JSONAPI
  module ConditionalRelationships
    extend ActiveSupport::Concern

    class_methods do
      def has_one_if_included(relationship_name, options = {}, &block)
        options[:if] = proc do |_record, params|
          params[:included]&.include?(relationship_name)
        end

        has_one relationship_name, options, &block
      end

      def has_many_if_included(relationship_name, options = {}, &block)
        options[:if] = proc do |_record, params|
          params[:included]&.include?(relationship_name)
        end

        has_many relationship_name, options, &block
      end
    end
  end
end
