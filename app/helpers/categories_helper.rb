module CategoriesHelper
  def display_category(str)
    return nil if str.blank?
    str.gsub('-',' ').capitalize
  end
end
