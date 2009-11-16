require File.join(File.dirname(__FILE__),'test_helper')

class TestRecord < Test::Unit::TestCase
  def teardown
    Net::HTTP.block_requests
  end

  def test_bad_query
    assert_raises ArgumentError do
      demographics = Mosaic::Lyris::Record.query(:bad, 1)
    end
  end

  def test_query_all
    Net::HTTP.block_requests false
    demographics = Mosaic::Lyris::Record.query(:all, 1)
  end
end
