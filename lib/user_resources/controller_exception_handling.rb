require_relative 'extensions/active_model_errors'

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
    error = exception.record.errors.humanize
    non_html = {text: error, status: :unprocessable_entity}
    return render(non_html) if request.xhr?

    respond_to do |fmt|
      fmt.html do
        flash[:error] = error
        redirect_to(:back)
      end
      fmt.any { render(non_html) }
    end
  end
end
