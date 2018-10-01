# name: site-activity
# version: 0.4.2
# author: Muhlis Budi Cahyono (muhlisbc@gmail.com)
# url: https://github.com/ryanerwin/discourse-site-activity

enabled_site_setting :site_activity_enabled

register_asset "stylesheets/whats-going-on.scss"

require_relative "lib/whats_going_on/engine.rb"

after_initialize {

  register_editable_user_custom_field("hide_site_activity")

  load File.expand_path("../jobs/count_guests.rb", __FILE__)

  DiscoursePluginRegistry.serialized_current_user_fields << "hide_site_activity"

  User.register_custom_field_type("hide_site_activity", :boolean)

  add_to_serializer(:current_user, :hide_site_activity) {
    object.custom_fields["hide_site_activity"]
  }

}
