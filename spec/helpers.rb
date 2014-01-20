module MiniTest::Assertions
  def assert_changes(obj, method, exp_diff)
    before = obj.send method
    yield
    after  = obj.send method
    diff = after - before
    assert_equal exp_diff, diff, "Expected #{obj.class.name}##{method} to change by #{exp_diff}, changed by #{diff}"
  end
end

module MiniTest::Expectations
  infect_an_assertion :assert_changes, :must_change
end