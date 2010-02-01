module Mosaic
  module Lyris
    class Upload < Object
      attr_reader :bytes_processed,
                  :completed_at,
                  :estimated_complete_at,
                  :list_id,
                  :size,
                  :status,
                  :time_elapsed,
                  :time_remaining

      def done?
        status == 'done'
      end

      def fatal?
        status == 'fatal'
      end

      def active?
        status =~ /^[0-9]+%$/
      end

      def incomplete?
        pending? || active?
      end

      def pending?
        status == 'pending'
      end

      def retry?
        status == 'retry'
      end

      class << self
        def add(email, file, options = {})
          validate_options!(options)
          reply = post('record', 'upload') do |request|
            request.MLID options[:list_id] || ''
            put_data(request, 'email', email)
            put_extra_data(request, 'file', file)
            put_extra_data(request, 'type', options[:type] || 'active')
            put_extra_data(request, 'trigger', 'yes') if options[:trigger]
            if options[:update]
              put_extra_data(request, 'update', options[:update].to_s == 'only' ? 'only' : 'on')
              put_extra_data(request, 'delete_blank', 'on') if options[:blank]
              put_extra_data(request, 'untrash', 'on') if options[:untrash]
            end
            put_extra_data(request, 'validate', 'on') if options[:validate]
          end
          new(options.merge(:id => reply.at('/DATASET/DATA').html, :email => options[:email], :file => file, :type => options[:type] || 'active'))
        end

        def build(record, options = {})
          new :list_id => options[:list_id],
              :file => get_element(record, 'FILE'),
              :status => get_element(record, 'STATUS'),
              :size => get_integer_element(record, 'SIZE'),
              :bytes_processed => get_integer_element(record, 'PROCESSED'),
              :time_elapsed => get_integer_element(record, 'ELAPSED'),
              :time_remaining => get_integer_element(record, 'TIMELEFT'),
              :estimated_complete_at => get_time_element(record, 'ETC'),
              :completed_at => get_time_element(record, 'TIME')
        end

        def query(what, options = {})
          reply = post('record', 'upload-status') do |request|
            request.MLID options[:list_id] || ''
            put_extra_data(request, 'file', what) unless what.to_s == 'all'
          end
          if what.to_s == 'all'
            reply.search('/DATASET/*').collect do |record|
              build record, options
            end
          else
            build reply.at('/DATASET/DATASET_1'), options
          end
        end

        def validate_options!(options)
          raise ArgumentError, "expected type of :active, :proof, :unsubscribed, :bounced, :trashed or :globalunsubscribe; got #{options[:type]}" unless %w(active proof unsubscribed bounced trashed globalunsubscribe).include?(options[:type].to_s) if options[:type]
          raise ArgumentError, "expected update value of true or :only; for #{options[:update]}" unless %w(true only).include?(options[:update].to_s) if options[:update]
        end
      end
    end
  end
end
