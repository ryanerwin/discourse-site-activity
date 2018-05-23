# name: site-activity
# version: 0.3
# author: Muhlis Budi Cahyono (muhlisbc@gmail.com)
# url: https://github.com/ryanerwin/discourse-site-activity

enabled_site_setting :site_activity_enabled

register_asset "stylesheets/whats-going-on.scss"

require_relative "lib/whats_going_on/engine.rb"

after_initialize {

  load File.expand_path("../jobs/count_guests.rb", __FILE__)

  add_to_serializer(:user, :custom_fields) {
    if scope.is_staff? || (scope.authenticated? && object.id == scope.user.id)
      object.custom_fields || {}
    end
  }

  User.register_custom_field_type("hide_site_activity", :boolean)

  add_to_serializer(:current_user, :hide_site_activity) {
    object.custom_fields["hide_site_activity"]
  }

}