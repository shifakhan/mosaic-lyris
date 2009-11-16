%w(
  object
  list
  demographic
).each do |file|
  require File.join(File.dirname(__FILE__),'lyris',file)
end
