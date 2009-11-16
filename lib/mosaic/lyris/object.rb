require 'builder'
require 'net/https'
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

    protected
      class << self
        def password
          @@password
        end

        def password=(value)
          @@password = value
        end

        def get_boolean_data(record, type, value)
          if data = get_data(record, type)
            data == value
          end
        end

        def get_data(record, type, attribute = nil)
          if element = record.at("/DATA[@type='#{type}']")
            if attribute
              element[attribute]
            else
              element.html
            end
          end
        end

        def get_date_data(record, type, attribute = nil)
          if data = get_data(record, type, attribute)
            Date.parse data
          end
        end

        def get_integer_data(record, type, attribute = nil)
          if data = get_data(record, type, attribute)
            data.gsub(/,/,'').to_i
          end
        end

        def get_time_data(record, type, attribute = nil)
          if data = get_data(record, type, attribute)
            Time.xmlschema(data)
          end
        end

        def post(type, activity, &block)
          xml = Builder::XmlMarkup.new
          xml.instruct!
          xml.DATASET do
            xml.DATA password, :type => 'extra', :id => 'password'
            xml.SITE_ID site_id
            block.call(xml) if block
          end
          input = xml.target!

          request = Net::HTTP::Post.new("/API/mailing_list.html")
          # $stderr.puts "REQUEST: type=#{type.inspect}, activity=#{activity.inspect}, input=#{input.inspect}"
          request.set_form_data('type' => type, 'activity' => activity, 'input' => input)

          conn = Net::HTTP.new(server, 443)
          conn.use_ssl = true
          conn.verify_mode = OpenSSL::SSL::VERIFY_NONE

          conn.start do |http|
            reply = http.request(request).body
            # $stderr.puts "REPLY: body=#{reply.inspect}"
            document = Hpricot.XML reply
            raise Error, (document % '/DATASET/DATA').html unless document % '/DATASET/TYPE[text()=success]'
            document
          end
        end

        def put_data(request, type, value, attributes = {})
          request.DATA value, {:type => type}.merge(attributes) unless value.nil?
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
      end
    end
  end
end
