require 'test/unit'
require 'mocha/setup'

require 'active_support/core_ext/time/calculations'

require File.join(File.dirname(__FILE__),'http_responder')

require File.join(File.dirname(__FILE__),'..','lib','mosaic','lyris.rb')

begin
  config_path = File.expand_path("../config.yml", __FILE__)
  Mosaic::Lyris::Object.configuration = YAML.load_file(config_path)
rescue Errno::ENOENT => e
  STDERR.puts "WARNING: For tests to succeed, you must set valid configuration parameters in '#{config_path}'"
  STDERR.puts "Sample configuration..."
  STDERR.puts <<SAMPLECONFIG
server: 'www.elabs6.com'
site_id: 99999999
password: 'xxxxxxxx'
SAMPLECONFIG
  STDERR.puts
  raise
end

Time.zone_default = ActiveSupport::TimeZone['Eastern Time (US & Canada)']

Net::HTTP.block_requests

def lyris_response(file, type, activity, input = nil)
  conditions = { :type => type, :activity => activity }
  conditions[:input] = input if input
  Net::HTTP.respond_to :post, '/API/mailing_list.html', File.join(File.dirname(__FILE__),'responses',type,file), conditions
end

# list requests
lyris_response 'add_success_12345.xml', 'list', 'add', %r(<DATA type="name">new list</DATA>)m
lyris_response 'add_error_name_already_exists.xml', 'list', 'add', %r(<DATA type="name">duplicate list</DATA>)m
lyris_response 'delete_error_not_found_99999.xml', 'list', 'delete', %r(<MLID>99999</MLID>)m
lyris_response 'delete_success_12345.xml', 'list', 'delete', %r(<MLID>12345</MLID>)m
lyris_response 'query_list_data_success.xml', 'list', 'query-listdata'

# demographic requests
lyris_response 'add_success_12345.xml', 'demographic', 'add', %r(<MLID>.*?</MLID>.*?<DATA type=".*?">new .*?</DATA>)m
lyris_response 'add_error_name_already_exists.xml', 'demographic', 'add', %r(<MLID>.*?</MLID>.*?<DATA type="text">duplicate text</DATA>)m
lyris_response 'query_all_success.xml', 'demographic', 'query-all', %r(<MLID>.*?</MLID>)m
lyris_response 'query_enabled_success.xml', 'demographic', 'query-enabled', %r(<MLID>.*?</MLID>)m
lyris_response 'query_enabled_details_success.xml', 'demographic', 'query-enabled-details', %r(<MLID>.*?</MLID>)m

# record requests
lyris_response 'query_all_success.xml', 'record', 'query-listdata', %r(<MLID>1</MLID>)m
lyris_response 'query_all_success_empty.xml', 'record', 'query-listdata', %r(<MLID>2</MLID>)m
lyris_response 'query_all_success_page_1.xml', 'record', 'query-listdata', %r(<MLID>3</MLID>.*?<DATA type="extra" id="page">1</DATA>)m
lyris_response 'query_all_success_page_2.xml', 'record', 'query-listdata', %r(<MLID>3</MLID>.*?<DATA type="extra" id="page">2</DATA>)m
lyris_response 'query_all_success_page_3.xml', 'record', 'query-listdata', %r(<MLID>3</MLID>.*?<DATA type="extra" id="page">3</DATA>)m
lyris_response 'add_success.xml', 'record', 'add', %r(<MLID>1</MLID>.*?<DATA type="email">new@email.not</DATA>)m
lyris_response 'add_error_email_already_exists.xml', 'record', 'add', %r(<MLID>1</MLID>.*?<DATA type="email">duplicate@email.not</DATA>)m
lyris_response 'query_email_error_not_found.xml', 'record', 'query-data', %r(<MLID>1</MLID>.*?<DATA type="email">missing@email.not</DATA>)m
lyris_response 'query_email_success_active.xml', 'record', 'query-data', %r(<MLID>1</MLID>.*?<DATA type="email">active@email.not</DATA>)m
lyris_response 'query_email_success_admin_trashed.xml', 'record', 'query-data', %r(<MLID>1</MLID>.*?<DATA type="email">admin.trashed@email.not</DATA>)m
lyris_response 'query_email_success_bounced.xml', 'record', 'query-data', %r(<MLID>1</MLID>.*?<DATA type="email">bounced@email.not</DATA>)m
lyris_response 'query_email_success_unsubscribed.xml', 'record', 'query-data', %r(<MLID>1</MLID>.*?<DATA type="email">unsubscribed@email.not</DATA>)m
lyris_response 'update_error_not_found.xml', 'record', 'update', %r(<MLID>1</MLID>.*?<DATA type="email">missing@email.not</DATA>)m
lyris_response 'update_success.xml', 'record', 'update', %r(<MLID>1</MLID>.*?<DATA type="email">active@email.not</DATA>)m

# trigger requests
lyris_response 'fire_error_invalid_trigger_id.xml', 'triggers', 'fire-trigger', %r(<MLID>1</MLID>.*?<DATA type="extra" id="trigger_id">666</DATA>)m
lyris_response 'fire_error_invalid_recipients.xml', 'triggers', 'fire-trigger', %r(<MLID>1</MLID>.*?<DATA type="extra" id="trigger_id">1</DATA>.*?<DATA type="extra" id="recipients">invalid@email.not</DATA>)m
lyris_response 'fire_success.xml', 'triggers', 'fire-trigger', %r(<MLID>1</MLID>.*?<DATA type="extra" id="trigger_id">1</DATA>.*?<DATA type="extra" id="recipients">one@email.not,two@email.not,three@email.not</DATA>)m
