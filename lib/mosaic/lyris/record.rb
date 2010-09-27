module Mosaic
  module Lyris
    class Record < Object
      attr_reader :demographics,
                  :doubleoptin,
                  :email,
                  :encoding,
                  :id,
                  :joindate,
                  :list_id,
                  :proof,
                  :state,
                  :statedate,
                  :trashed,
                  :trigger

      class << self
        def add(email, options = {})
          validate_options!(options)
          reply = post('record', 'add') do |request|
            request.MLID options[:list_id] if options[:list_id]
            put_data(request, 'email', email)
            put_demographic_data(request, options[:demographics])
            put_extra_data(request, 'trigger', 'yes') if options[:trigger]
            put_extra_data(request, 'proof', 'yes') if options[:proof]
            put_extra_data(request, 'state', options[:state])
            put_extra_data(request, 'encoding', options[:encoding])
            put_extra_data(request, 'doubleoptin', 'yes') if options[:doubleoptin]
          end
          new(options.merge(:id => reply.at('/DATASET/DATA').html, :email => email, :state => options[:state] || 'active', :trashed => %w(bounced unsubscribed trashed).include?(options[:state].to_s)))
        end

        def query(what, options = {})
          if /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i === what
            query_one(what, options)
          else
            query_all(what, options)
          end
        end

        def update(email, options = {})
          validate_options!(options)
          reply = post('record', 'update') do |request|
            request.MLID options[:list_id] if options[:list_id]
            put_data(request, 'email', email)
            put_extra_data(request, 'new_email', options[:email])
            put_demographic_data(request, options[:demographics])
            put_extra_data(request, 'trigger', 'yes') if options[:trigger]
            put_extra_data(request, 'proof', 'yes') if options[:proof]
            put_extra_data(request, 'state', options[:state])
            put_extra_data(request, 'encoding', options[:encoding])
          end
          # TODO: query full record? this is an incomplete snapshot of the updated record (ie. it only contains updated attributes/demographics)
          new(options.merge(:id => reply.at('/DATASET/DATA').html, :email => options[:email] || email, :state => options[:state], :trashed => options[:state] && %w(bounced unsubscribed trashed).include?(options[:state].to_s)))
        end

      protected
        def query_all(what, options = {})
          raise ArgumentError, "expected :all; got #{what.inspect}" unless %w(all).include?(what.to_s)
          reply = post('record', 'query-listdata') do |request|
            request.MLID options[:list_id] if options[:list_id]
            put_extra_data(request, 'pagelimit', options[:per_page])
            put_extra_data(request, 'page', options[:page] || 1) if options[:per_page]
            put_extra_data(request, 'type', options[:state])
          end
          reply.search('/DATASET/RECORD').collect do |record|
            new :demographics => get_demographic_data(record),
                :email => get_data(record, 'email'),
                :id => get_data(record, 'extra', nil, :id => 'uid'),
                :list_id => options[:list_id],
                :proof => get_boolean_data(record, 'extra', 'yes', nil, :id => 'proof'),
                :state => get_data(record, 'extra', nil, :id => 'state') || 'active',
                :statedate => get_date_data(record, 'extra', nil, :id => 'statedate'),
                :trashed => get_boolean_data(record, 'extra', 'y', nil, :id => 'trashed')
          end
        end

        def query_one(email, options = {})
          reply = post('record', 'query-data') do |request|
            request.MLID options[:list_id] if options[:list_id]
            put_data(request, 'email', email)
          end
          record = reply.at('/DATASET/RECORD')
          new :demographics => get_demographic_data(record),
              :email => get_data(record, 'extra', nil, :id => 'email'),
              :id => get_data(record, 'extra', nil, :id => 'uid'),
              :joindate => get_time_data(record, 'extra', nil, :id => 'joindate'),
              :list_id => options[:list_id],
              :proof => get_boolean_data(record, 'extra', 'yes', nil, :id => 'proof'),
              :state => get_data(record, 'extra', nil, :id => 'state') || 'active',
              :statedate => get_date_data(record, 'extra', nil, :id => 'statedate'),
              :trashed => get_boolean_data(record, 'extra', 'y', nil, :id => 'trashed')
        end

        def validate_options!(options)
          raise ArgumentError, "expected state of :active, :bounced, :unsubscribed or :trashed; got #{options[:state]}" unless %w(active bounced unsubscribed trashed).include?(options[:state].to_s) if options[:state]
        end
      end
    end
  end
end
