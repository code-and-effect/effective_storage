require 'test_helper'

class StorageTest < ActiveSupport::TestCase
  test 'user factory' do
    user = build_user()
    assert user.valid?
  end

end
