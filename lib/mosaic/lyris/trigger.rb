module Mosaic
  module Lyris
    class Trigger < Object
      class << self
        def fire(id, recipients, options = {})
          reply = post('triggers', 'fire-trigger') do |request|
            request.MLID options[:list_id] if options[:list_id]
          end
        end
      end
    end
  end
end
