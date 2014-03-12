module UserResources

  
  class Forbidden < StandardError; end

    
  class Invalid < StandardError
    attr_accessor :model, :message
    
    def initialize(model, message = nil)
      @model = model

      if !(@message = message)
        errors = model.try(:errors)
        @message = errors.full_messages.join(',') if errors
      end
    end
  end
end
