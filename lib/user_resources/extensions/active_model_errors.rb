module ActiveModel
  class Errors

    def humanize
      cls = @base.class.name.humanize
      if blank?
        ''
      else
        op = @base.new_record? ? 'creating' : 'updating'
        "Errors #{op} the #{cls}: #{full_messages.join(', ')}"
      end
    end
  end
end
