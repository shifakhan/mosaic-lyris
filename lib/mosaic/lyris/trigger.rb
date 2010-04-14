require 'uri'

module Mosaic
  module Lyris
    class Trigger < Object
      attr_reader :add,
                  :clickthru,
                  :id,
                  :message,
                  :not_sent,
                  :recipients_data,
                  :sent,
                  :subject

      class << self
        def fire(id, *recipients)
          options = recipients.pop if recipients.last.is_a?(Hash)
          list_id = options[:list_id] || default_list_id
          id = lookup_trigger(id, :locale => options.delete(:locale)) if id.is_a?(Symbol)
          reply = post('triggers', 'fire-trigger') do |request|
            request.MLID list_id if list_id
            put_extra_data(request, 'trigger_id', id)
            put_extra_data(request, 'recipients', recipients.join(','))
            put_extra_data(request, 'recipients_data', recipients_data_url(options[:recipients_data]))
            put_extra_data(request, 'subject', options[:subject])
            put_extra_data(request, 'clickthru', 'on') if options[:clickthru]
            put_extra_data(request, 'add', 'yes') if options[:add]
            put_extra_data(request, 'message', options[:message])
          end
          sent = get_data(reply.at('/DATASET'), 'sent') || ''
          not_sent = get_data(reply.at('/DATASET'), 'not sent') || ''
          new options.merge(:id => id, :not_sent => not_sent.split(','), :sent => sent.split(','))
        end

        def lookup_trigger(key, options = {})
          locale = options[:locale] || I18n.locale
          locale = locale.to_s
          key = key.to_s
          if triggers[locale] && triggers[locale][key]
            triggers[locale][key]
          else
            triggers[key]
          end
        end

        def recipients_data_url(recipients_data)
          return if recipients_data.nil?
          return recipients_data if URI.parse(recipients_data).scheme
          url = callback_url.dup
          url.path = recipients_data
          url.to_s
        end
      end
    end
  end
end
