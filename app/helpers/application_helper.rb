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
end
