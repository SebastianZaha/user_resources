require_relative 'controller_exception_handling'

# Classes including this mixing should implement
# * current_user - returning the user that is logged in and performs the current action.
module UserResources::Controller::Actions

  
  private

  # The following 3 methods are the methods that can be *potentially* exposed as public, 
  # by calling `enable_resource_actions`
  
  def create
    model = model_class.new
    action = action_class.new(model, current_user)

    respond_with(action.create(resource_attributes))
  end

  def update
    model = model_class.find(params[:id])
    action = action_class.new(model, current_user)

    respond_with(action.update(resource_attributes))
  end

  def destroy
    model = model_class.find(params[:id])
    action = action_class.new(model, current_user)

    respond_with(action.destroy)
  end


  private

  # HTML forms by default (at least in rails) name resources attributes like `address[street]`.
  # JSON APIs and API endpoints usually send a json body with the serialized resource. Rails
  # decodes this directly in `params`.
  def resource_attributes
    request.format.html? ? params[user_resource_class.to_s.downcase] : params
  end

  def model_class
    self.class.user_resource_class
  end
  
  def action_class
    "#{model_class}Action".constantize
  end


  def self.included(base)
    base.class_eval do
      extend ClassMethods
    end
  end

  
  module ClassMethods

    def enable_user_resource_actions(user_resource_class, methods)
      cattr_accessor :user_resource_class
      self.user_resource_class = user_resource_class

      public(:create) if methods.include?(:create)
      public(:update) if methods.include?(:update)
      public(:destroy) if methods.include?(:destroy)
    end
  end
end
