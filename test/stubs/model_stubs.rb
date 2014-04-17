class ModelStub

  attr_accessor :attributes

  def self.find(*args)
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

  def transaction
    yield
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


class ModelStubAction < UserResources::UserAction

  def allowed?
    true
  end
end
