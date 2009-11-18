module Mosaic
  module Lyris
    class Trigger < Object
      attr_reader :id,
                  :not_sent,
                  :sent

      class << self
        def fire(id, *recipients)
          options = recipients.pop if recipients.last.is_a?(Hash)
          reply = post('triggers', 'fire-trigger') do |request|
            request.MLID options[:list_id] if options[:list_id]
            put_data(request, 'extra', id, :id => 'trigger_id')
            put_data(request, 'extra', recipients.join(','), :id => 'recipients')
          end
          sent = get_data(reply.at('/DATASET'), 'sent') || ''
          not_sent = get_data(reply.at('/DATASET'), 'not sent') || ''
          new :id => id, :not_sent => not_sent.split(','), :sent => sent.split(',')
        end
      end
    end
  end
end
