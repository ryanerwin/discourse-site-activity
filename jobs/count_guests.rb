module Jobs

  class CountGuests < Jobs::Scheduled
    sidekiq_options retry: false
    every 10.minutes

    def execute(_args)
      return unless SiteSetting.site_activity_enabled

      guest_count = TopicViewItem.where(user_id: nil).where("viewed_at > ?", SiteSetting.site_activity_online_minute.to_i.minutes.ago.to_date).count("DISTINCT ip_address")
      PluginStore.set("whats_going_on", "guest_count", guest_count)
    end
    
  end

end
