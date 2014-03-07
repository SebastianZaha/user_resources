require 'test_helper'

class ModelTest < Test::Unit::TestCase

  class DummyModel
    include UserResources::Model

    attr_accessor :attributes
  end


  def test_exceptions
    m = DummyModel.new
    attrs = {name: 'Hello'}

    # Stub methods. Model is not editable, but save would return true.
    def m.editable_by?(user) false end
    def m.save() true end

    msg = 'Model should raise a forbidden exception when it is not editable by this user.'
    assert_raise(UserResources::Forbidden, msg) do
      m.user_update(attrs, :someone)
    end

    # Stub methods. Model is editable by :someone, but save returns false.
    def m.editable_by?(user) user == :someone end
    def m.save() false end

    msg = 'Model should raise an invalid exception when it cannot be saved.'
    assert_raise(UserResources::Invalid, msg) do
      m.user_update(attrs, :someone)
    end

    # Now it's both valid, and editable
    def m.save() true end

    m.user_update(attrs, :someone)
    assert_equal(m.attributes, attrs, 'Should set attributes on the model')
  end
end