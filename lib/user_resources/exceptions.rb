module UserResources

  
  class Forbidden < StandardError; end

    
  class UnprocessableEntity < StandardError
    attr_accessor :entity, :message
    
    def initialize(entity, message = nil)
      @entity = entity
      if !(@message = message)
        errors = entity.try(:errors)
        @message = errors.full_messages.join(',') if errors
      end
    end
  end
end
