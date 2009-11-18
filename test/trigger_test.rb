require File.join(File.dirname(__FILE__),'test_helper')

class TestTrigger < Test::Unit::TestCase
  def teardown
    Net::HTTP.block_requests
  end

  MESSAGE = <<END_OF_MESSAGE
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<title>this is a test</title>
</head>
<body style="margin:0px;padding:0px; background-color: #333; outline:0px;">
<h1 style="color: #FFF;">THIS IS A TEST</h1>
<p style="color: #CCC;">hello</p>
<p style="color: #CCC;">test message to: <strong style="color: #FFF;">%%EMAIL_ADDRESS%%</strong></p>
<p style="color: #CCC;">goodbye</p>
</body>
</html>
END_OF_MESSAGE

  def test_fire
    trigger = Mosaic::Lyris::Trigger.fire(1, 'one@email.not', 'two@email.not', 'three@email.not', :list_id => 1, :subject => 'this is a test', :clickthru => true, :add => true, :message => MESSAGE)
    assert_instance_of Mosaic::Lyris::Trigger, trigger
    assert_equal %w(one@email.not two@email.not three@email.not), trigger.sent
    assert_equal %w(four@email.not), trigger.not_sent
    assert_equal 'this is a test', trigger.subject
    assert_equal true, trigger.clickthru
    assert_equal true, trigger.add
    assert_equal MESSAGE, trigger.message
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
