module UserResources::ControllerExceptionHandling


  protected

  def render_forbidden
    return render(nothing: true, status: :forbidden) if request.xhr?

    respond_to do |fmt|
      fmt.html do
        flash[:error] = 'Forbidden'
        redirect_to('/')
      end
      fmt.any { render(nothing: true, status: :forbidden) }
    end
  end

  def render_invalid(exception)
    non_html = {text: exception.message, status: :unprocessable_entity}
    return render(non_html) if request.xhr?

    respond_to do |fmt|
      fmt.html do
        flash[:error] = extract_message(exception)
        redirect_to(:back)
      end
      fmt.any { render(non_html) }
    end
  end


  private

  def extract_message(exception)
    model = exception.model
    errors = model.errors

    if errors.blank?
      'Error'
    else
      cls = model.class.name.humanize.downcase
      op = model.new_record? ? 'creating' : 'updating'
      "Errors #{op} the #{cls}: #{errors.full_messages.map(:+).join(', ')}"
    end
  end
end
