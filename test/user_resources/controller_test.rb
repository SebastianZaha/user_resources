require_relative '../test_helper'

class ControllerTest < Test::Unit::TestCase

  def setup
    @controller = ControllerStub.new
    @controller.current_user = :someone
    @controller.params = {id: 1, name: 'Hello'}
  end

  def test_create
    # The resource that the controller should create.
    obj = Minitest::Mock.new
    # Our assertions
    obj.expect(:create, obj, [@controller.params])

    (ModelStub::UserAction).stub :new, obj do
      @controller.create
    end
    obj.verify

    assert(@controller.responded_with === obj, 'Controller should respond with created object')
  end

  def test_update
    # The resource that the controller should create.
    obj = Minitest::Mock.new
    # Our assertions
    obj.expect(:update, obj, [@controller.params])

    (ModelStub::UserAction).stub :new, obj do
      @controller.update
    end
    obj.verify

    assert(@controller.responded_with === obj, 'Controller should respond with updated object')
  end

  def test_destroy
    # The resource that the controller should create.
    obj = Minitest::Mock.new
    # Our assertions
    obj.expect(:destroy, obj, [])

    (ModelStub::UserAction).stub :new, obj do
      @controller.destroy
    end
    obj.verify

    assert(@controller.responded_with === obj, 'Controller should respond with destroyed object')
  end

  def test_exception_handling
    e = ActiveRecord::RecordInvalid.new(ModelStubInvalid.new)
    @controller.send(:render_invalid, e)

    assert_equal(:unprocessable_entity, @controller.rendered[:status])
    assert(@controller.rendered[:text].include?('Error'))
  end
end