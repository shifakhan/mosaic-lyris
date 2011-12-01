require 'time'

module Mosaic
  module Lyris
    class List < Object
      attr_reader :cache_time,
                  :clickthru_url,
                  :footer_html,
                  :footer_text,
                  :handle_autoreply,
                  :handle_autoreply_email,
                  :handle_unsubscribe,
                  :handle_unsubscribe_email,
                  :id,
                  :last_sent,
                  :members,
                  :messages,
                  :name,
                  :reply_forward_email,
                  :reply_forward_subject,
                  :reply_from_email,
                  :reply_from_name,
                  :status

      def active?
        status == 'active'
      end

      def archived?
        status == 'archived'
      end

      class << self
        def add(name, attributes = {})
          reply = post('list', 'add') do |request|
            put_data(request, 'name', name)
            put_extra_data(request, 'CLICKTHRU_URL', attributes[:clickthru_url])
          end
          new attributes.merge(:id => reply.at('/DATASET/DATA').inner_html.to_i, :name => name)
        end

        def delete(id)
          reply = post('list', 'delete') do |request|
            request.MLID id
          end
          new :id => id
        end

        def query(what)
          reply = post('list', query_type(what))
          reply.search('/DATASET/RECORD').collect do |record|
            new :cache_time => get_xml_time_data(record, 'cache-time'),
                :id => get_integer_data(record, 'name', :id),
                :last_sent => get_date_data(record, 'last-sent'),
                :members => get_integer_data(record, 'members'),
                :messages => get_integer_data(record, 'messages'),
                :name => get_data(record, 'name'),
                :status => get_data(record, 'status')
          end
        end

      protected
        def query_type(what)
          if what == :all
            'query-listdata'
          else
            raise ArgumentError, "expected :all, got #{what.inspect}"
          end
        end
      end
    end
  end
end
