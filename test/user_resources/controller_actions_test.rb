require 'test_helper'

class ControllerActionsTest < Test::Unit::TestCase

  def setup
    @controller = DummyController.new
    @controller.current_user = :someone
    @controller.params = {id: 1, name: 'Hello'}
  end

  def test_create
    # The resource that the controller should create.
    obj = Minitest::Mock.new
    # Our assertions
    obj.expect(:user_update, obj, [@controller.params, @controller.current_user])

    DummyModel.stub :new, obj do
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

    DummyModel.stub :find, obj do
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

    DummyModel.stub :find, obj do
      @controller.destroy
    end
    obj.verify

    assert(@controller.responded_with === obj, 'Controller should respond with destroyed object')
  end


  class DummyModel
    def self.find; end
  end


  class DummyController < ActionController::Base

    include UserResources::ControllerActions
    enable_user_resource_actions(DummyModel, [:create, :update, :destroy])

    attr_accessor :responded_with, :params, :current_user

    def respond_with(obj); @responded_with = obj; end
    def request(); DummyRequest.new end
  end

  class DummyRequest
    def format
      Mime::Type.lookup(:json)
    end
  end
end
