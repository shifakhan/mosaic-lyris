require File.join(File.dirname(__FILE__),'test_helper')

class TestTrigger < Test::Unit::TestCase
  def teardown
    Net::HTTP.block_requests
  end

  def test_fire
    trigger = Mosaic::Lyris::Trigger.fire(1, 'one@email.not', 'two@email.not', 'three@email.not', :list_id => 1)
    assert_instance_of Mosaic::Lyris::Trigger, trigger
    assert_equal %w(one@email.not two@email.not three@email.not), trigger.sent
    assert_equal %w(four@email.not), trigger.not_sent
  end

  def test_fire_invalid_recipients
    assert_raise Mosaic::Lyris::Error do
      Mosaic::Lyris::Trigger.fire(1, 'invalid@email.not', :list_id => 1)
    end
  end

  def test_fire_invalid_trigger_id
    assert_raise Mosaic::Lyris::Error do
      Mosaic::Lyris::Trigger.fire(666, 'one@email.not', :list_id => 1)
    end
  end
end
