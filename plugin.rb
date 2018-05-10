# name: site-activity
# version: 0.1
# author: Muhlis Budi Cahyono (muhlisbc@gmail.com)
# url: https://github.com/ryanerwin/discourse-site-activity

enabled_site_setting :site_activity_enabled

register_asset "stylesheets/whats-going-on.scss"

require_relative "lib/whats_going_on/engine.rb"

after_initialize {

  load File.expand_path("../jobs/count_guests.rb", __FILE__)

}