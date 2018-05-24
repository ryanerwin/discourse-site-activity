module Jobs

  class CountGuests < Jobs::Scheduled
    sidekiq_options retry: false
    every 10.minutes

    def execute(_args)
      return unless SiteSetting.site_activity_enabled

      online_date = SiteSetting.site_activity_guest_online_day.to_i.days.ago.to_date

      guest_count = TopicViewItem
        .where(user_id: nil)
        .where("viewed_at > ?", online_date)
        .count("DISTINCT ip_address")

      PluginStore.set("whats_going_on", "guest_count", guest_count)

      puts "CountGuests done!" if Rails.env.development?
    end
    
  end

end
