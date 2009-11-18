module Mosaic
  module Lyris
    class Trigger < Object
      attr_reader :add,
                  :clickthru,
                  :id,
                  :message,
                  :not_sent,
                  :recipient_data,
                  :sent,
                  :subject

      class << self
        def fire(id, *recipients)
          options = recipients.pop if recipients.last.is_a?(Hash)
          reply = post('triggers', 'fire-trigger') do |request|
            request.MLID options[:list_id] if options[:list_id]
            put_extra_data(request, 'trigger_id', id)
            put_extra_data(request, 'recipients', recipients.join(','))
            put_extra_data(request, 'recipient_data', options[:recipient_data])
            put_extra_data(request, 'subject', options[:subject])
            put_extra_data(request, 'clickthru', 'on') if options[:clickthru]
            put_extra_data(request, 'add', 'yes') if options[:add]
            put_extra_data(request, 'message', options[:message])
          end
          sent = get_data(reply.at('/DATASET'), 'sent') || ''
          not_sent = get_data(reply.at('/DATASET'), 'not sent') || ''
          new options.merge(:id => id, :not_sent => not_sent.split(','), :sent => sent.split(','))
        end
      end
    end
  end
end
