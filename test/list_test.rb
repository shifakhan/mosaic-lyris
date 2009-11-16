require File.join(File.dirname(__FILE__),'test_helper')

class TestList < Test::Unit::TestCase
  def test_add
    list = Mosaic::Lyris::List.add 'new list'
    assert_not_nil list
    assert_equal 12345, list.id
    assert_equal 'new list', list.name
  end

  def test_add_duplicate
    assert_raises Mosaic::Lyris::Error do
      list = Mosaic::Lyris::List.add 'duplicate list'
    end
  end

  def test_bad_query
    assert_raises ArgumentError do
      lists = Mosaic::Lyris::List.query(:bad)
    end
  end

  def test_delete
    list = Mosaic::Lyris::List.delete 12345
    assert_not_nil list
    assert_equal 12345, list.id
  end

  def test_delete_not_found
    assert_raises Mosaic::Lyris::Error do
      Mosaic::Lyris::List.delete 99999
    end
  end

  def test_query_all
    lists = Mosaic::Lyris::List.query(:all)
    assert_not_nil lists
    assert_equal 2, lists.size
    assert_equal [1,2], lists.collect { |l| l.id }
    assert_equal ['list one','list two'], lists.collect { |l| l.name }
    assert_equal [Date.new(2001,1,1),Date.new(2002,2,2)], lists.collect { |l| l.last_sent }
    assert_equal [1111,2222], lists.collect { |l| l.members }
    assert_equal [11,22], lists.collect { |l| l.messages }
    assert_equal [Time.utc(2001,1,1,1,1,1,0),Time.utc(2002,2,2,2,2,2,0)], lists.collect { |l| l.cache_time }
  end
end
