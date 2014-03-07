# Classes using this mixin should implement the following methods:
#
# editable_by?(user) -> Boolean
#   * true if `user` is allowed (according to the application's business logic) to edit
#     this resource
# save -> Boolean
#   * should return false when the object cannot be saved (invalid, etc)
#   * if the class is already an ActiveRecord model, you already have this
module UserResources::Model

  def self.included(base)
    base.class_eval do
      # The user that is changing this object through our protected methods.
      attr_accessor :user_performing_update
      # The attributes he is trying to set.
      attr_accessor :attributes_from_client
    end
  end

  
  # `user` is updating this object with the attributes `attrs`.
  def user_update(attrs, user)
    raise UserResources::Forbidden unless editable_by?(user)
    self.user_performing_update = user
    self.attributes_from_client = attrs

    before_set_attributes if respond_to?(:before_set_attributes, true)

    self.attributes = attrs

    raise UserResources::Forbidden unless editable_by?(user)

    # Save the record
    raise UserResources::Invalid.new(self) if !save

    self.user_performing_update = self.attributes_from_client = nil

    self
  end

  # `user` destroys the object. See `CoreResource::TRASHABLE`
  def user_destroy(user)
    raise UserResources::Forbidden if !editable_by?(user)

    self.user_performing_update = user
    self.attributes_from_client = {}

    destroy

    self.user_performing_update = self.attributes_from_client = nil
    self
  end
end
