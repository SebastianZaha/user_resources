class ControllerStub < ActionController::Base

  class RequestStub
    def format
      Mime::Type.lookup(:json)
    end

    def xhr?
      true
    end
  end

  include UserResources::Controller::Actions
  include UserResources::Controller::ExceptionHandling
  
  enable_user_resource_actions(ModelStub, [:create, :update, :destroy])

  attr_accessor :responded_with, :params, :current_user, :redirected_to, :rendered

  def respond_with(obj)
    @responded_with = obj
  end

  def redirect_to(url)
    @redirected_to = url
  end

  def render(hash)
    @rendered = hash
  end

  def request
    RequestStub.new
  end
end
