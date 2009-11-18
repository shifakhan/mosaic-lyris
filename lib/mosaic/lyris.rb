%w(
  object
  demographic
  filter
  list
  message
  partner
  record
  trigger
).each do |file|
  require File.join(File.dirname(__FILE__),'lyris',file)
end
