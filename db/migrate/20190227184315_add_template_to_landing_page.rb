class AddTemplateToLandingPage < ActiveRecord::Migration[5.2]
  def change
    add_column :landing_pages, :template, :text
  end
end
