require_relative '../test_helper'

class ModelTest < Test::Unit::TestCase


  def test_exceptions
    attrs = {name: 'Hello'}

    m = ModelStub.new
    a = ModelStubAction.new(m, :someone)
    def a.allowed? 
      false
    end
    
    msg = 'Model should raise a forbidden exception when it is not editable by this user.'
    assert_raise(UserResources::Forbidden, msg) do
      a.create(attrs)
    end

    m = ModelStubInvalid.new
    a = ModelStubAction.new(m, :someone)
    msg = 'Model should raise an invalid exception when it cannot be saved.'
    assert_raise(ActiveRecord::RecordInvalid, msg) do
      a.create(attrs)
    end

    # Now it's both valid, and editable
    m = ModelStub.new
    a = ModelStubAction.new(m, :someone)
    a.create(attrs)
    assert_equal(m.attributes, attrs, 'Should set attributes on the model')
  end

  def test_before_save
    m = ModelStub.new
    a = ModelStubAction.new(m, :someone)
    
    attrs = {id: 1, illegal_attr: true}

    def a.before_save(attrs)
      attrs.select { |k, v| k != :illegal_attr} 
    end

    a.create(attrs)

    assert_equal(1, m.attributes[:id])
    assert(!m.attributes[:illegal_attr], 'The illegal attribute should not be set.')
  end

  def test_before_update_for_immutable_attributes
    attrs = {id: 1, not_mut: 2}

    m = ModelStub.new
    a = ModelStubAction.new(m, :someone)
    a.create(attrs)
    assert_equal(1, m.attributes[:id])
    assert_equal(2, m.attributes[:not_mut])

    # Fake that we saved the model now
    def m.persisted?() true end
    def a.before_update(attrs)
      attrs.select { |k, v| k != :not_mut}
    end
    
    a.update({id: 11, not_mut: 12})

    assert_equal(11, m.attributes[:id], 'The mutable attribute should change')

    # NOTE that the attributes = method in our dummy resets all attributes always.
    # The 'attributes=' method in Rails only considers a smart diff (see assign_attributes in
    # ActiveRecord)
    assert_equal(nil, m.attributes[:not_mut], 'The immutable attribute was reset')
  end
end
