require File.join(File.dirname(__FILE__),'test_helper')

class TestDemographic < Test::Unit::TestCase
  def test_add_duplicate
    assert_raises Mosaic::Lyris::Error do
      demographic = Mosaic::Lyris::Demographic.add 1, :text, 'duplicate text'
    end
  end

  # checkbox
  # date
  # multiple checkbox
  # multiple select list
  # radio button
  # select list
  # text
  # textarea

  def test_add_checkbox
    demographic = Mosaic::Lyris::Demographic.add 1, :checkbox, 'new checkbox', :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :checkbox, demographic.type
    assert_equal 'new checkbox', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_add_date
    demographic = Mosaic::Lyris::Demographic.add 1, :date, 'new date', :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :date, demographic.type
    assert_equal 'new date', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_add_multiple_checkbox
    demographic = Mosaic::Lyris::Demographic.add 1, :multiple_checkbox, 'new multiple checkbox', :options => %w(one two three four five), :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :multiple_checkbox, demographic.type
    assert_equal 'new multiple checkbox', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three four five), demographic.options
  end

  def test_add_multiple_select_list
    demographic = Mosaic::Lyris::Demographic.add 1, :multiple_select_list, 'new multiple select list', :options => %w(one two three four five six seven eight nine ten), :size => 4, :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :multiple_select_list, demographic.type
    assert_equal 'new multiple select list', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three four five six seven eight nine ten), demographic.options
    assert_equal 4, demographic.size
  end

  def test_add_radio_button
    demographic = Mosaic::Lyris::Demographic.add 1, :radio_button, 'new radio button', :options => %w(one two three), :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :radio_button, demographic.type
    assert_equal 'new radio button', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three), demographic.options
  end

  def test_add_select_list
    demographic = Mosaic::Lyris::Demographic.add 1, :select_list, 'new select list', :options => %w(one two three four five six seven eight), :size => 4, :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :select_list, demographic.type
    assert_equal 'new select list', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three four five six seven eight), demographic.options
    assert_equal 4, demographic.size
  end

  def test_add_text
    demographic = Mosaic::Lyris::Demographic.add 1, :text, 'new text', :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :text, demographic.type
    assert_equal 'new text', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_add_textarea
    demographic = Mosaic::Lyris::Demographic.add 1, :textarea, 'new textarea', :enabled => true
    assert_not_nil demographic
    assert_equal 12345, demographic.id
    assert_equal :textarea, demographic.type
    assert_equal 'new textarea', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_bad_query
    assert_raises ArgumentError do
      demographics = Mosaic::Lyris::Demographic.query(:bad, 1)
    end
  end

  def test_bad_type
    assert_raises ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add 1, :bad, 'bad type', :enabled => true
    end
  end

  def test_invalid_options
    assert_raises ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add 1, :text, 'invalid options', :options => %w(one two three), :enabled => true
    end
  end

  def test_invalid_size
    assert_raises ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add 1, :text, 'invalid options', :size => 3, :enabled => true
    end
  end

  def test_missing_options
    assert_raises ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add 1, :select_list, 'missing options', :enabled => true
    end
  end

  # def test_delete
  #   list = Mosaic::Lyris::List.delete 12345
  #   assert_not_nil list
  #   assert_equal 12345, list.id
  # end
  #
  # def test_delete_not_found
  #   assert_raises Mosaic::Lyris::Error do
  #     Mosaic::Lyris::List.delete 99999
  #   end
  # end

  def test_query_all
    demographics = Mosaic::Lyris::Demographic.query(:all, 1)
    assert_not_nil demographics
    assert_equal 16, demographics.size
    demographics.each_with_index do |d,i|
      assert_equal [(1..8).to_a,(11..18).to_a].flatten[i], d.id
      assert_equal [:checkbox, :date, :multiple_checkbox, :multiple_select_list, :radio_button, :select_list, :text, :textarea, :checkbox, :date, :multiple_checkbox, :multiple_select_list, :radio_button, :select_list, :text, :textarea][i], d.type
      assert_equal ['enabled checkbox', 'enabled date', 'enabled multiple checkbox', 'enabled multiple select list', 'enabled radio button', 'enabled select list', 'enabled text', 'enabled textarea', 'disabled checkbox', 'disabled date', 'disabled multiple checkbox', 'disabled multiple select list', 'disabled radio button', 'disabled select list', 'disabled text', 'disabled textarea'][i], d.name
      assert_equal i < 8, d.enabled
      assert_equal 'Custom', d.group
      assert_nil d.options
      assert_nil d.size
    end
  end

  def test_query_enabled
    demographics = Mosaic::Lyris::Demographic.query(:enabled, 1)
    assert_not_nil demographics
    assert_equal 9, demographics.size
    demographics.each_with_index do |d,i|
      assert_equal i, d.id
      assert_equal [:email, :checkbox, :date, :multiple_checkbox, :multiple_select_list, :radio_button, :select_list, :text, :textarea, :checkbox, :date, :multiple_checkbox, :multiple_select_list, :radio_button, :select_list, :text, :textarea][i], d.type
      assert_equal ['EMAIL_ADDRESS', 'enabled checkbox', 'enabled date', 'enabled multiple checkbox', 'enabled multiple select list', 'enabled radio button', 'enabled select list', 'enabled text', 'enabled textarea'][i], d.name
      assert d.enabled, "'#{d.name}' demographic should be enabled"
      assert_nil d.group
      assert_nil d.options
      assert_nil d.size
    end
  end

  def test_query_enabled_details
    demographics = Mosaic::Lyris::Demographic.query(:enabled_details, 1)
    assert_not_nil demographics
    assert_equal 8, demographics.size
    demographics.each_with_index do |d,i|
      assert_equal i+1, d.id
      assert_equal [:checkbox, :date, :multiple_checkbox, :multiple_select_list, :radio_button, :select_list, :text, :textarea][i], d.type
      assert_equal ['enabled checkbox', 'enabled date', 'enabled multiple checkbox', 'enabled multiple select list', 'enabled radio button', 'enabled select list', 'enabled text', 'enabled textarea'][i], d.name
      assert d.enabled, "'#{d.name}' demographic should be enabled"
      assert_nil d.group
      assert_equal [nil, nil, %w(one two three four five), %w(one two three four five six seven eight nine ten), %w(one two three), %w(one two three four five six seven eight)][i], d.options
      assert_nil d.size
    end
  end
end
