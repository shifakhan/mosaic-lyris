module Mosaic
  module Lyris
    class Record < Object
      attr_reader :id,
                  :list_id

      class << self
        def query(what, list_id)
          reply = post('record', query_type(what)) do |request|
            request.MLID list_id
          end
          reply.search('/DATASET/RECORD').collect do |record|
            new :id => get_integer_data(record, 'id'),
                :list_id => list_id
          end
        end

      protected
        def query_type(what)
          raise ArgumentError, "expected :all; got #{what.inspect}" unless %w(all).include?(what.to_s)
          'query-listdata'
        end
      end
    end
  end
end
