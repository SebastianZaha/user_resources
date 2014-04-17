class UserResources::UserAction

  def initialize(resource, user)
    @resource, @user = resource, user
  end

  def create(attrs)
    if @resource.persisted?
      raise UserResources::Forbidden.new('Cannot create, resource already persisted') 
    end
    
    @resource.transaction do
      attrs = before_save(attrs) || attrs
      attrs = before_create(attrs) || attrs

      @resource.attributes = attrs

      raise UserResources::Forbidden.new('Action not allowed') unless allowed?

      # Save the record
      raise ActiveRecord::RecordInvalid.new(@resource) unless @resource.save

      after_create(attrs)
      after_save(attrs)
    end

    @resource
  end
  
  def update(attrs)
    unless @resource.persisted?
      raise UserResources::Forbidden.new('Cannot update, resource not persisted yet.')
    end
    
    @resource.transaction do

      attrs = before_save(attrs) || attrs
      attrs = before_update(attrs) || attrs

      raise UserResources::Forbidden.new('Action not allowed') unless allowed?

      @resource.attributes = attrs

      raise UserResources::Forbidden.new('Action not allowed') unless allowed?

      # Save the record
      raise ActiveRecord::RecordInvalid.new(@resource) unless @resource.save

      after_update(attrs)
      after_save(attrs)
    end

    @resource
  end

  def destroy
    @resource.transaction do
      before_destroy
    
      raise UserResources::Forbidden.new('Action not allowed') unless allowed?
      
      @resource.destroy
    
      after_destroy
    end
    
    @resource
  end


  protected

  def allowed?
    raise NotImplementedError
  end


  def before_create(attrs)
  end

  def after_create(attrs)
  end

  def before_update(attrs)
  end

  def before_save(attrs)
  end

  def after_update(attrs)
  end
  
  def after_save(attrs)
  end

  def before_destroy
  end
  
  def after_destroy
  end
  
  
  # Helper method to see if an attribute has been changed by this action. By passing `to` one can
  # also check if that attribute changed to a specific value.
  def attribute_changed?(attrs, attribute, to = nil)
    before = @resource.attributes[attribute] 
    after = attrs[attribute]
    
    if attrs.key?(attribute) && before != after
      to ? after == to : true    
    else
      false
    end
  end
end
