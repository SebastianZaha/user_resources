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
    obj.expect(:user_update, obj, [@controller.params, @controller.current_user])

    ModelStub.stub :new, obj do
      @controller.create
    end
    obj.verify

    assert(@controller.responded_with === obj, 'Controller should respond with created object')
  end

  def test_update
    # The resource that the controller should create.
    obj = Minitest::Mock.new
    # Our assertions
    obj.expect(:user_update, obj, [@controller.params, @controller.current_user])

    ModelStub.stub :find, obj do
      @controller.update
    end
    obj.verify

    assert(@controller.responded_with === obj, 'Controller should respond with updated object')
  end

  def test_destroy
    # The resource that the controller should create.
    obj = Minitest::Mock.new
    # Our assertions
    obj.expect(:user_destroy, obj, [@controller.current_user])

    ModelStub.stub :find, obj do
      @controller.destroy
    end
    obj.verify

    assert(@controller.responded_with === obj, 'Controller should respond with destroyed object')
  end

  def test_exception_handling
  end
end