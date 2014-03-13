class ModelStub
  include UserResources::Model

  attr_accessor :attributes

  before_attributes_set :preprocess_attributes

  def self.find
  end


  def editable_by?(user)
    true
  end

  def save
    true
  end

  def persisted?
    false
  end


  protected

  def preprocess_attributes(attrs)
    attrs
  end
end


class ModelStubNotEditable < ModelStub
  def editable_by?(user)
    false
  end
end

class ModelStubNotValid < ModelStub
  def save
    false
  end
end

class ModelStubWithImmutable < ModelStub
  attr_immutable :not_mut
end
