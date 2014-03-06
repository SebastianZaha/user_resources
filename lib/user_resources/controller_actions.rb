# Classes including this mixing should implement
# * current_user - returning the user that is logged in and performs the current action.
module UserResources::ControllerActions

  
  private

  def self.included(base)
    base.send :extend, ClassMethods
  end


  def create
    o = self.class.user_res_cls.new
      .user_update(params, current_user)
    respond_with(o)
  end

  def update
    o = self.class.user_res_cls.find(params[:id])
      .user_update(params, current_user)
    respond_with(o)
  end
  
  def destroy
    o = self.class.user_res_cls.find(params[:id])
      .user_destroy(current_user)
    respond_with(o)
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
