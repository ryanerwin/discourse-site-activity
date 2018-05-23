module WhatsGoingOn
  class UsersOnlineController < ApplicationController

    def index
      special_group         = Group.where(name: SiteSetting.site_activity_group).first if !SiteSetting.site_activity_group.blank?
      group_online_minute   = SiteSetting.site_activity_group_online_minute.to_i.minutes.ago
      member_online_minute  = SiteSetting.site_activity_member_online_minute.to_i.minutes.ago

      group             = nil
      group_member_ids  = []

      if !special_group.blank?
        group_member_ids = GroupUser.where(group_id: special_group.id).pluck(:user_id)

        users = User
          .where("last_seen_at > ?", group_online_minute)
          .where(id: group_member_ids)
          .select(:id, :username, :name)
          .order(last_seen_at: :desc)

        group = {
          name: special_group.name,
          full_name: special_group.full_name,
          total: special_group.user_count,
          users: users,
          current: users.size
        }
      end
        
      users = User
        .where("last_seen_at > ?", member_online_minute)
        .where.not(id: group_member_ids)
        .select(:id, :username, :name)
        .order(last_seen_at: :desc)

      member = {
        users: users,
        current: users.size,
        total: User.count
      }

      guest_count   = PluginStore.get("whats_going_on", "guest_count").to_i

      current       = { member: ((group ? group[:current] : 0) + member[:current].to_i), guest: guest_count }
      most_online   = get_most_online(current.values.inject(:+))

      render json: { group: group, member: member, current: current, most: most_online }
    end

    private

      def get_users(last_seen_at, ids)
        User
          .where("last_seen_at > ?", last_seen_at)
          .where(id: except_ids)
          .select(:id, :username, :name)
          .order(last_seen_at: :desc)        
      end

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