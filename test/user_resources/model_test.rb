require 'test_helper'

class ModelTest < Test::Unit::TestCase


  def test_exceptions
    attrs = {name: 'Hello'}

    m = DummyNotEditable.new
    msg = 'Model should raise a forbidden exception when it is not editable by this user.'
    assert_raise(UserResources::Forbidden, msg) do
      m.user_update(attrs, :someone)
    end

    m = DummyNotValid.new
    msg = 'Model should raise an invalid exception when it cannot be saved.'
    assert_raise(UserResources::Invalid, msg) do
      m.user_update(attrs, :someone)
    end

    # Now it's both valid, and editable
    m = DummyModel.new
    m.user_update(attrs, :someone)
    assert_equal(m.attributes, attrs, 'Should set attributes on the model')
  end

  def test_before_attributes_set
    m = DummyModel.new
    attrs = {id: 1, illegal_attr: true}

    def m.preprocess_attributes(attrs)
      attrs.delete(:illegal_attr)
      attrs
    end

    m.user_update(attrs, :someone)

    assert_equal(1, m.attributes[:id])
    assert(!m.attributes[:illegal_attr], 'Our preprocess_attributes callback should be called')
  end

  def test_immutable_attributes
    attrs = {id: 1, not_mut: 2}

    m = DummyWithImmutable.new.user_update(attrs, :someone)
    assert_equal(1, m.attributes[:id])
    assert_equal(2, m.attributes[:not_mut])

    # Fake that we saved the model now
    def m.persisted?() true end
    m.user_update({id: 11, not_mut: 12}, :someone)

    assert_equal(11, m.attributes[:id], 'The mutable attribute should change')

    # NOTE that the attributes = method in our dummy resets all attributes always.
    # The 'attributes=' method in Rails only considers a smart diff (see assign_attributes in
    # ActiveRecord)
    assert_equal(nil, m.attributes[:not_mut], 'The immutable attribute was reset')
  end


  class DummyModel
    include UserResources::Model

    attr_accessor :attributes

    before_attributes_set :preprocess_attributes

    def editable_by?(user); true end
    def save(); true end
    def persisted?() false end

    protected

    def preprocess_attributes(attrs)
      attrs
    end
  end

  class DummyNotEditable < DummyModel
    def editable_by?(user)
      false
    end
  end

  class DummyNotValid < DummyModel
    def save
      false
    end
  end

  class DummyWithImmutable < DummyModel
    attr_immutable :not_mut
  end
end
