class ControllerStub < ActionController::Base

  class RequestStub
    def format
      Mime::Type.lookup(:json)
    end
  end

  include UserResources::Controller
  enable_user_resource_actions(ModelStub, [:create, :update, :destroy])

  attr_accessor :responded_with, :params, :current_user, :redirected_to

  def respond_with(obj)
    @responded_with = obj
  end

  def redirect_to(url)
    @redirected_to = url
  end

  def request
    RequestStub.new
  end

  def invalid_action
    raise UserResources::Invalid.new(ModelStub.new)
  end

  def forbidden_action
    raise UserResources::Forbidden.new
  end
end
