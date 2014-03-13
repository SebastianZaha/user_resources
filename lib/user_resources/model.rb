# Requires:
#   editable_by?(user) -> Boolean
#     * true if `user` is allowed (according to the application's business logic) to edit
#       this resource
#
#  Required (possibly) - The following are also required but already provided by ActiveRecord:
#
#   * save -> Boolean
#     * should return false when the object cannot be saved (invalid, etc)
#     * if the class is already an ActiveRecord model, you already have this
#   * persisted? -> Boolean
#   * attributes=(Hash)
#
# Provides:
#   * self.user_performing_update -> Object (whatever the caller passes to user_updates)
#   * self.attributes_from_client -> Hash
#   * self.attr_immutable(Array<Symbol> attribute_names)
#   * self.before_attributes_set(Symbol method_name)
#     - requires: method(Hash attributes) -> Hash
#     - method will be called before client sent attributes are set. It should return a set of
#       pre-processed attributes if it needs to pre-process them
#
#   * user_update(Hash attrs, Object user)
#   * user_destroy(Object user)
module UserResources::Model

  def self.included(base)
    base.class_eval do

      # The user that is changing this object through our protected methods.
      attr_accessor :user_performing_update
      # The attributes he is trying to set.
      attr_accessor :attributes_from_client

      def self.attr_immutable(*symbols)
        instance_variable_set(:@attr_immutable, symbols)
      end

      def self.before_attributes_set(method_name)
        instance_variable_set(:@before_attr_set, method_name)
      end
    end
  end

  
  # `user` is updating this object with the attributes `attrs`.
  def user_update(attrs, user)
    raise UserResources::Forbidden unless editable_by?(user)
    self.user_performing_update = user

    callback = self.class.instance_variable_get(:@before_attr_set)
    self.attributes_from_client = callback ? self.send(callback, attrs) : attrs

    self.attributes = sanitize_immutable(attributes_from_client)

    raise UserResources::Forbidden unless editable_by?(user)

    # Save the record
    raise ActiveRecord::RecordInvalid.new(self) if !save

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


  protected

  def sanitize_immutable(attrs)
    immutable = self.class.instance_variable_get(:@attr_immutable)

    if persisted? && immutable
      attrs.reject { |k, v| immutable.include?(k)  }
    else
      attrs
    end
  end
end
