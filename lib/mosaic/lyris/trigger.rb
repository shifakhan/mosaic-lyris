require 'uri'

module Mosaic
  module Lyris
    class Trigger < Object
      attr_reader :add,
                  :clickthru,
                  :enabled,
                  :id,
                  :message,
                  :message_id,
                  :message_text,
                  :name,
                  :not_sent,
                  :recipients_data,
                  :sent,
                  :subject,
                  :total_opened,
                  :unique_bounced,
                  :unique_click,
                  :unique_opened,
                  :unique_unsubscribed,
                  :total_sent

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
            put_extra_data(request, 'message_text', options[:message_text])
          end
          sent = get_data(reply.at('/DATASET'), 'sent') || ''
          not_sent = get_data(reply.at('/DATASET'), 'not sent') || ''
          new options.merge(:id => id, :not_sent => not_sent.split(','), :sent => sent.split(','))
        end

        def lookup_trigger(key, options = {})
          locale = options[:locale] || I18n.locale
          locale = locale.to_s
          key = key.to_s
          if triggers[locale].is_a?(Hash) && triggers[locale][key]
            triggers[locale][key]
          else
            triggers[key]
          end
        end

        def query(what, options = {})
          if what == :all
            query_all(options)
          else
            query_one(what, options)
          end
        end

        def recipients_data_url(recipients_data)
          return if recipients_data.nil?
          return recipients_data if URI.parse(recipients_data).scheme
          url = callback_url.dup
          url.path = recipients_data
          url.to_s
        end

      protected
        def query_all(options)
          reply = post('triggers', 'query-listdata') do |request|
            request.MLID options[:list_id] if options[:list_id]
          end
          reply.search('/DATASET/RECORD').collect do |record|
            new :id => get_integer_data(record, 'trigger_id'),
                :name => get_data(record, 'trigger_name'),
                :enabled => get_boolean_data(record, 'trigger_enabled', 'on')
          end
        end

        def query_one(id, options)
          reply = post('triggers', 'query-data-summary') do |request|
            request.MLID options[:list_id] if options[:list_id]
            put_extra_data(request, 'trigger_id', id)
          end
          record = reply.at('/DATASET/RECORD')
          new :id => get_integer_data(record, 'trigger_id'),
              :message_id => get_integer_data(record, 'message_id'),
              :spam_complaints => get_integer_data(record, 'spam_complaints'),
              :subject => get_data(record, 'message_subject'),
              :total_opened => get_integer_data(record, 'total_opened'),
              :total_sent => get_integer_data(record, 'total_sent'),
              :unique_opened => get_integer_data(record, 'unique_opened'),
              :unique_click => get_integer_data(record, 'unique_click'),
              :unique_unsubscribed => get_integer_data(record, 'unique_unsubscribed'),
              :unique_bounced => get_integer_data(record, 'unique_bounced')
        end
      end

      def enabled?
        enabled
      end
    end
  end
end
