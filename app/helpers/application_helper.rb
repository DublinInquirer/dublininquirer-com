module ApplicationHelper
  def render_errors_for(record, attribute)
    render partial: 'forms/errors', locals: {record: record, attribute: attribute}
  end

  def asset_exists?(path)
    if Rails.configuration.assets.compile
      Rails.application.precompiled_assets.include? path
    else
      Rails.application.assets_manifest.assets[path].present?
    end
  end

  def is_christmastime?
    return true if (Date.current.month == 12)
    return true if (Date.current.month == 11) && (Date.current.day > 15)
    false
  end
end
