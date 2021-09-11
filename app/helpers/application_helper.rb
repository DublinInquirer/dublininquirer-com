module ApplicationHelper
  def render_errors_for(record, attribute)
    render partial: 'forms/errors', locals: {record: record, attribute: attribute}
  end

  def asset_exists?(path)
    raise "TODO: implement ability to check for portrait existence"
  end

  def is_christmastime?
    return true if (Date.current.month == 12)
    return true if (Date.current.month == 11)
    false
  end

  def format_url(url)
    url&.gsub(/(^https?:\/\/(www.)?)/,'').gsub(/(\/)$/,'')
  end
end
