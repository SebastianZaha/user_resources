require_relative 'controller_exception_handling'

# Classes including this mixing should implement
# * current_user - returning the user that is logged in and performs the current action.
module UserResources::Controller

  include UserResources::ControllerExceptionHandling

  private

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      rescue_from UserResources::Forbidden, with: :render_forbidden
      rescue_from UserResources::Invalid, with: :render_invalid
    end
  end


  def create
    o = self.class.user_res_cls.new
      .user_update(resource_attributes, current_user)
    respond_with(o)
  end

  def update
    o = self.class.user_res_cls.find(params[:id])
      .user_update(resource_attributes, current_user)
    respond_with(o)
  end
  
  def destroy
    o = self.class.user_res_cls.find(params[:id])
      .user_destroy(current_user)
    respond_with(o)
  end

  # HTML forms by default (at least in rails) name resources attributes like `address[street]`.
  # JSON APIs and API endpoints usually send a json body with the serialized resource. Rails
  # decodes this directly in `params`.
  def resource_attributes
    request.format.html? ? params[user_res_cls.to_s.downcase] : params
  end


  module ClassMethods

    def enable_user_resource_actions(user_resource_class, methods)
      cattr_accessor :user_res_cls
      self.user_res_cls = user_resource_class

      public(:create) if methods.include?(:create)
      public(:update) if methods.include?(:update)
      public(:destroy) if methods.include?(:destroy)
    end
  end
end
