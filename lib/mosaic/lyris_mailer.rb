module Mosaic
  module LyrisMailer
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::SanitizeHelper

  private
    if ActionMailer::Base.respond_to?(:add_delivery_method)
      def friendly_from_for(mail)
        mail[:from].display_names.first
      end

      def from_for(mail)
        mail[:from].addresses.first
      end
    else
      def friendly_from_for(mail)
        mail.friendly_from
      end

      def from_for(mail)
        mail.from
      end
    end

    def get_lyris_html(mail)
      if mail.multipart?
        get_part_body(mail, 'text/html') || simple_format(get_part_body(mail, 'text/plain'))
      elsif mail.content_type.start_with? 'text/html'
        get_part_body(mail, 'text/html')
      elsif mail.content_type.start_with? 'text/plain'
        simple_format(mail.body.to_s)
      else
        raise TypeError, "unable to retrieve text/html for content type (#{mail.content_type})"
      end
    end

    # TODO: handle encoding?
    def get_lyris_options(mail)
      lyris_options = {}
      lyris_options[:subject] = mail.subject
      lyris_options[:from_email] = from_for(mail)
      lyris_options[:from_name] = friendly_from_for(mail)
      lyris_options[:clickthru] = true
      lyris_options[:message] = get_lyris_html(mail)
      lyris_options[:message_text] = get_lyris_text(mail)
      lyris_options
    end

    def get_lyris_text(mail)
      if mail.multipart?
        get_part_body(mail, 'text/plain') || ActionController::Base.helpers.strip_tags(get_part_body(mail, 'text/html'))
      elsif mail.content_type.start_with? 'text/plain'
        mail.body.to_s
      elsif mail.content_type.start_with? 'text/html'
        ActionController::Base.helpers.strip_tags(get_part_body(mail, 'text/html'))
      else
        raise TypeError, "unable to retrieve text/plain for content type (#{mail.content_type})"
      end
    end

    def get_part(mail, content_type)
      return mail if mail.parts.length == 0
      mail.parts.find { |part| part.content_type.start_with? content_type }
    end

    def get_part_body(mail, content_type)
      part = get_part(mail, content_type)
      part.body.to_s if part
    end

    def perform_delivery_lyris(mail)
      args = []
      args << Mosaic::Lyris::Object.default_trigger_id
      args += mail.destinations
      args << get_lyris_options(mail)
      trigger = Mosaic::Lyris::Trigger.fire(*args)
      # TODO: deal with sent vs not sent
      # raise "triggered email not sent" unless trigger.sent.include?(email)
    end
  end
end

if ActionMailer::Base.respond_to?(:add_delivery_method)
  module Mosaic
    class LyrisDeliveryMethod
      include LyrisMailer

      def initialize(values = {})
      end

      def deliver!(mail)
        perform_delivery_lyris(mail)
      end
    end
  end

  ActionMailer::Base::add_delivery_method :lyris, Mosaic::LyrisDeliveryMethod
else
  ActionMailer::Base.send :include, Mosaic::LyrisMailer
  ActionMailer::Base.send :extend, ActionView::Helpers::SanitizeHelper::ClassMethods
end
