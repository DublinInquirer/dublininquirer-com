class RenameCouponsToLandingPages < ActiveRecord::Migration[5.2]
  def change
    rename_table :coupons, :landing_pages
    rename_column :subscriptions, :coupon_code, :landing_page_slug
  end
end
