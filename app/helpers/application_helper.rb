module ApplicationHelper
  def render_errors_for(record, attribute)
    render partial: 'forms/errors', locals: {record: record, attribute: attribute}
  end
end
