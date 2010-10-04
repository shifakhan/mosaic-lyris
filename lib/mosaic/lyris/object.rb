require 'builder'
require 'net/https'
require 'uri'
require 'hpricot'

module Mosaic
  module Lyris
    class Error < RuntimeError; end

    class Object
      private_class_method :new

      def initialize(attributes)
        attributes.each do |attribute,value|
          instance_variable_set "@#{attribute}", value unless value.nil?
        end
      end

      def to_param
        id && id.to_s
      end

    protected
      class << self
        def callback_url
          @@callback_url
        end

        def callback_url=(value)
          @@callback_url = value && URI.parse(value)
        end

        def default_list_id
          @@default_list_id
        end

        def default_list_id=(value)
          @@default_list_id = value
        end

        def get_array_data(record, type)
          if record.at("/DATA[@type='#{type}']")
            record.search("/DATA[@type='#{type}']").collect do |data|
              if block_given?
                yield data
              else
                data.html
              end
            end
          end
        end

        def get_boolean_data(record, type, value, attribute = nil, conditions = {})
          if data = get_data(record, type, attribute, conditions)
            data == value
          end
        end

        def get_data(record, type, attribute = nil, conditions = {})
          xpath = "/DATA[@type='#{type}']"
          xpath << conditions.collect { |a,v| "[@#{a}='#{v}']" }.join
          if element = record.at(xpath)
            data = attribute ? element[attribute] : element.html
            # TODO: fix encoding if necessary... seems like we should need to convert to UTF-8 here, but this works for now
            HTMLEntities.new.decode(data.gsub(/&#(\d+);/) { Integer($1).chr })
          end
        end

        def get_date_data(record, type, attribute = nil, conditions = {})
          data = get_data(record, type, attribute, conditions)
          Date.parse(data) unless data.blank?
        end

        def get_demographic_data(record)
          if data = get_array_data(record, 'demographic') { |d| [ d[:id].to_i, d.html ] }
            data.inject({}) do |h,(k,v)|
              case h[k]
              when NilClass
                h[k] = v
              when Array
                h[k] << v
              else
                h[k] = Array(h[k])
                h[k] << v
              end
              h
            end
          end
        end

        def get_element(record, element)
          if data = record.at("/#{element}")
            data.html
          end
        end

        def get_integer_data(record, type, attribute = nil, conditions = {})
          if data = get_data(record, type, attribute, conditions)
            data.gsub(/,/,'').to_i
          end
        end

        def get_integer_element(record, element)
          get_element(record, element).to_i
        end

        def get_time_data(record, type, attribute = nil, conditions = {})
          if data = get_data(record, type, attribute, conditions)
            Time.parse(data) + (Time.zone.utc_offset - Time.zone_offset('PST'))
          end
        end

        def get_time_element(record, element)
          if data = get_element(record, element)
            Time.parse(data) + (Time.zone.utc_offset - Time.zone_offset('PST'))
          end
        end

        def get_time_offset_data(record, type, attribute = nil, conditions = {})
          if offset = get_integer_data(record, type, attribute, conditions)
            offset + (Time.zone.utc_offset - Time.zone_offset('PST'))
          end
        end

        def get_xml_time_data(record, type, attribute = nil, conditions = {})
          if data = get_data(record, type, attribute, conditions)
            Time.xmlschema(data)
          end
        end

        def logger
          @@logger ||= nil
        end

        def logger=(logger)
          @@logger = logger
        end

        def password
          @@password
        end

        def password=(value)
          @@password = value
        end

        def post(type, activity, &block)
          xml = Builder::XmlMarkup.new(:indent => 2)
          xml.instruct!
          xml.DATASET do
            xml.SITE_ID site_id
            put_extra_data(xml, 'password', password)
            block.call(xml) if block
          end
          input = xml.target!

          request = Net::HTTP::Post.new("/API/mailing_list.html")
          logger.debug ">>>>> REQUEST:\ntype=#{type}\nactivity=#{activity}\ninput=#{input}\n>>>>>" if logger
          request.set_form_data('type' => type, 'activity' => activity, 'input' => input)

          conn = Net::HTTP.new(server, 443)
          conn.use_ssl = true
          conn.verify_mode = OpenSSL::SSL::VERIFY_NONE

          conn.start do |http|
            # TODO: parse encoding from declaration? update declaration after conversion?
            reply = http.request(request).body
            logger.debug ">>>>> REPLY:\n#{reply}\n>>>>>" if logger
            document = Hpricot.XML(reply)
            raise Error, (document % '/DATASET/DATA').html unless document % '/DATASET/TYPE[text()=success]'
            document
          end
        end

        def put_array_data(request, type, values)
          Array(values).each do |value|
            put_data(request, type, value)
          end
        end
        
        def put_data(request, type, value, attributes = {})
          request.DATA value, {:type => type}.merge(attributes) unless value.nil?
        end

        def put_demographic_data(request, demographics)
          Array(demographics).each do |id, value|
            Array(value).each do |v|
              put_data(request, 'demographic', v, :id => id)
            end
          end
        end

        def put_extra_data(request, id, value)
          put_data(request, 'extra', value, :id => id)
        end

        def server
          @@server
        end

        def server=(value)
          @@server = value
        end

        def site_id
          @@site_id
        end

        def site_id=(value)
          @@site_id = value
        end

        def triggers
          @@triggers
        end

        def triggers=(value)
          @@triggers = value
        end
      end
    end
  end
end
