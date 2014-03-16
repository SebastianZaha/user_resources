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

  def new_record?
    true
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

class ModelStubInvalid < ModelStub
  # Required dependency for ActiveModel::Errors
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  extend ActiveModel::Validations

  def save
    false
  end

  def errors
    err = ActiveModel::Errors.new(self)
    err.add(:base, 'Email not valid')
    err
  end
end

class ModelStubWithImmutable < ModelStub
  attr_immutable :not_mut
end
