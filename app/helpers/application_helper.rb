# frozen_string_literal: true

# :nodoc:
module ApplicationHelper
  # Select the appropriate Boostrap class for Rails's flash messages
  def bootstrap_class_for(flash_type)
    case flash_type
    when 'success'
      'alert-success'   # Green
    when 'error'
      'alert-danger'    # Red
    when 'alert'
      'alert-warning'   # Yellow
    else
      'alert-info'      # Blue
    end
  end

  # Display model validation errors in form templates
  def display_validation_errors(object)
    return '' if object.errors.empty?

    header = I18n.t('activerecord.errors.template.header', count: object.errors.count)
    msgs = object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

    html = <<-HTML
      <div class="alert alert-danger alert-dismissable" role="alert">
        <button type="button" class="close" data-dismiss="alert">
          <span aria-hidden="true">&times;</span><span class="sr-only">Close</span>
        </button>
        <h4>
          #{header}
        </h4>
        <ul>#{msgs}</ul>
      </div>
    HTML

    html.html_safe
  end
end
