module Mosaic
  module Lyris
    class Demographic < Object
      attr_reader :enabled,
                  :group,
                  :id,
                  :list_id,
                  :name,
                  :options,
                  :size,
                  :type

      class << self
        def add(list_id, type, name, options = {})
          validate_options!(type, options)
          reply = post('demographic', 'add') do |request|
            request.MLID list_id
            put_data(request, demographic_type(type), name)
            put_array_data(request, 'option', options[:option])
            put_data(request, 'state', 'enabled') if options[:enabled]
            put_data(request, 'size', options[:size]) if options[:size]
          end
          new(options.merge(:id => reply.at('/DATASET/DATA').html.to_i, :list_id => list_id, :name => name, :type => type))
        end

        def query(what, list_id)
          reply = post('demographic', query_type(what)) do |request|
            request.MLID list_id
          end
          reply.search('/DATASET/RECORD').collect do |record|
            new :enabled => ([:enabled, :enabled_details].include?(what) || get_boolean_data(record, 'state', 'enabled')),
                :group => get_data(record, "group"),
                :id => get_integer_data(record, 'id'),
                :list_id => list_id,
                :name => get_data(record, 'name'),
                :options => get_array_data(record, 'option'),
                :size => get_integer_data(record, 'size'),
                :type => get_data(record, 'type').downcase.gsub(/ /,'_').to_sym
          end
        end

      protected
        def demographic_type(type)
          raise ArgumentError, "expected :checkbox, :date, :multiple_checkbox, :multiple_select_list, :radio_button, :select_list, :text or :textarea; got #{type.inspect}" unless %w(checkbox date multiple_checkbox multiple_select_list radio_button select_list text textarea).include?(type.to_s)
          type.to_s.gsub(/_/,' ')
        end

        def query_type(what)
          raise ArgumentError, "expected :all, :enabled or :enabled_details; got #{what.inspect}" unless %w(all enabled enabled_details).include?(what.to_s)
          "query-#{what}".gsub(/_/,'-')
        end

        def validate_options!(type, options)
          if %w(multiple_checkbox multiple_select_list radio_button select_list).include?(type.to_s)
            raise ArgumentError, "missing options for #{type.inspect} demographic" unless options[:options]
          else
            raise ArgumentError, "#{type.inspect} demographic does not support options" if options[:options]
          end
          raise ArgumentError, "#{type.inspect} demographic does not support :size option" if options[:size] unless %w(multiple_select_list select_list).include?(type.to_s)
        end
      end
    end
  end
end

