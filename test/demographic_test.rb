require File.join(File.dirname(__FILE__),'test_helper')

class TestDemographic < Test::Unit::TestCase
  def test_add_duplicate
    assert_raise Mosaic::Lyris::Error do
      demographic = Mosaic::Lyris::Demographic.add :text, 'duplicate text', :list_id => 1
    end
  end

  def test_add_checkbox
    demographic = Mosaic::Lyris::Demographic.add :checkbox, 'new checkbox', :list_id => 1, :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :checkbox, demographic.type
    assert_equal 'new checkbox', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_add_date
    demographic = Mosaic::Lyris::Demographic.add :date, 'new date', :list_id => 1, :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :date, demographic.type
    assert_equal 'new date', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_add_multiple_checkbox
    demographic = Mosaic::Lyris::Demographic.add :multiple_checkbox, 'new multiple checkbox', :list_id => 1, :options => %w(one two three four five), :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :multiple_checkbox, demographic.type
    assert_equal 'new multiple checkbox', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three four five), demographic.options
  end

  def test_add_multiple_select_list
    demographic = Mosaic::Lyris::Demographic.add :multiple_select_list, 'new multiple select list', :list_id => 1, :options => %w(one two three four five six seven eight nine ten), :size => 4, :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :multiple_select_list, demographic.type
    assert_equal 'new multiple select list', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three four five six seven eight nine ten), demographic.options
    assert_equal 4, demographic.size
  end

  def test_add_radio_button
    demographic = Mosaic::Lyris::Demographic.add :radio_button, 'new radio button', :list_id => 1, :options => %w(one two three), :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :radio_button, demographic.type
    assert_equal 'new radio button', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three), demographic.options
  end

  def test_add_select_list
    demographic = Mosaic::Lyris::Demographic.add :select_list, 'new select list', :list_id => 1, :options => %w(one two three four five six seven eight), :size => 4, :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :select_list, demographic.type
    assert_equal 'new select list', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
    assert_equal %w(one two three four five six seven eight), demographic.options
    assert_equal 4, demographic.size
  end

  def test_add_text
    demographic = Mosaic::Lyris::Demographic.add :text, 'new text', :list_id => 1, :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :text, demographic.type
    assert_equal 'new text', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_add_textarea
    demographic = Mosaic::Lyris::Demographic.add :textarea, 'new textarea', :list_id => 1, :enabled => true
    assert_instance_of Mosaic::Lyris::Demographic, demographic
    assert_equal 1, demographic.list_id
    assert_equal 12345, demographic.id
    assert_equal :textarea, demographic.type
    assert_equal 'new textarea', demographic.name
    assert demographic.enabled, 'demographic is not enabled'
  end

  def test_bad_query
    assert_raise ArgumentError do
      demographics = Mosaic::Lyris::Demographic.query(:bad, :list_id => 1)
    end
  end

  def test_bad_type
    assert_raise ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add :bad, 'bad type', :list_id => 1, :enabled => true
    end
  end

  def test_invalid_options
    assert_raise ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add :text, 'invalid options', :list_id => 1, :options => %w(one two three), :enabled => true
    end
  end

  def test_invalid_size
    assert_raise ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add :text, 'invalid options', :list_id => 1, :size => 3, :enabled => true
    end
  end

  def test_missing_options
    assert_raise ArgumentError do
      demographic = Mosaic::Lyris::Demographic.add :select_list, 'missing options', :list_id => 1, :enabled => true
    end
  end

  def test_query_all
    demographics = Mosaic::Lyris::Demographic.query(:all, :list_id => 1)
    assert_instance_of Array, demographics
    assert_equal 16, demographics.size
    demographics.each_with_index do |d,i|
      assert_instance_of Mosaic::Lyris::Demographic, d
      assert_equal 1, d.list_id
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
    demographics = Mosaic::Lyris::Demographic.query(:enabled, :list_id => 1)
    assert_instance_of Array, demographics
    assert_equal 9, demographics.size
    demographics.each_with_index do |d,i|
      assert_instance_of Mosaic::Lyris::Demographic, d
      assert_equal 1, d.list_id
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
    demographics = Mosaic::Lyris::Demographic.query(:enabled_details, :list_id => 1)
    assert_instance_of Array, demographics
    assert_equal 8, demographics.size
    demographics.each_with_index do |d,i|
      assert_instance_of Mosaic::Lyris::Demographic, d
      assert_equal 1, d.list_id
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
