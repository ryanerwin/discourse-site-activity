module WhatsGoingOn
  class UsersOnlineController < ApplicationController

    def index
      users         = User.where("last_seen_at > ?", 7.days.ago).select(:username, :name).order(last_seen_at: :desc).map { |user| user.slice(:username, :name) }
      guest_count   = PluginStore.get("whats_going_on", "guest_count").to_i

      current       = { member: users.size, guest: guest_count }
      most_online   = get_most_online(current.values.inject(:+))

      render json: { users: users, current: current, most: most_online }
    end

    private

      def get_most_online(current_total)
        tmp_most_online = { total: current_total, time: Time.now }
        old_most_online = PluginStore.get("whats_going_on", "most_online")

        if old_most_online.blank? || tmp_most_online[:total] >= old_most_online[:total]
          PluginStore.set("whats_going_on", "most_online", tmp_most_online)
          tmp_most_online
        else
          old_most_online
        end
      end

  end
end