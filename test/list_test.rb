require File.join(File.dirname(__FILE__),'test_helper')

class TestList < Test::Unit::TestCase
  def test_add
    list = Mosaic::Lyris::List.add 'new list'
    assert_instance_of Mosaic::Lyris::List, list
    assert_equal 12345, list.id
    assert_equal 'new list', list.name
  end

  def test_add_duplicate
    assert_raise Mosaic::Lyris::Error do
      list = Mosaic::Lyris::List.add 'duplicate list'
    end
  end

  def test_bad_query
    assert_raise ArgumentError do
      lists = Mosaic::Lyris::List.query(:bad)
    end
  end

  def test_delete
    list = Mosaic::Lyris::List.delete 12345
    assert_instance_of Mosaic::Lyris::List, list
    assert_equal 12345, list.id
  end

  def test_delete_not_found
    assert_raise Mosaic::Lyris::Error do
      Mosaic::Lyris::List.delete 99999
    end
  end

  def test_query_all
    lists = Mosaic::Lyris::List.query(:all)
    assert_instance_of Array, lists
    assert_equal 2, lists.size
    lists.each_with_index do |l,i|
      assert_instance_of Mosaic::Lyris::List, l
      assert_equal i+1, l.id
      assert_equal ['list one','list two'][i], l.name
      assert_equal [Date.new(2001,1,1),Date.new(2002,2,2)][i], l.last_sent
      assert_equal [1111,2222][i], l.members
      assert_equal [11,22][i], l.messages
      assert_equal [Time.utc(2001,1,1,1,1,1,0),Time.utc(2002,2,2,2,2,2,0)][i], l.cache_time
    end
  end
end
