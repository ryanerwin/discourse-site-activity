module WhatsGoingOn
  class UsersOnlineController < ApplicationController

    def index
      @special_group      = Group.where(name: SiteSetting.site_activity_group).first if !SiteSetting.site_activity_group.blank?
      @group              = nil
      @group_member_ids   = []

      group_query if !@special_group.blank?

      member_query

      guest_count         = ps_get("guest_count").to_i
      current             = { member: ((@group ? @group[:current] : 0) + @member[:current].to_i), guest: guest_count }
      most_online         = get_most_online(current.values.inject(:+))

      render json: { type: mobile_or_desktop, group: @group, member: @member, current: current, most: most_online }
    end

    private

      def mobile_or_desktop
        ActiveModel::Type::Boolean.new.cast(params[:mobile]) ? "mobile" : "desktop"
      end

      def setting_for(*args)
        SiteSetting.send("site_activity_" + args.join("_"))
      end

      def online_minute_for(obj)
        setting_for(obj, "online_minute").to_i.minutes.ago
      end

      def group_query
        online_minute       = online_minute_for("group")
        @group_member_ids   = GroupUser.where(group_id: @special_group.id).pluck(:user_id)
        limit               = setting_for("group_limit", mobile_or_desktop).to_i

        users = User
          .where("last_seen_at > ?", online_minute)
          .where(id: @group_member_ids)
          .select(:id, :username, :name)
          .order(last_seen_at: :desc)
          .limit(limit)

        users_count = User
          .where("last_seen_at > ?", online_minute)
          .where(id: @group_member_ids)
          .count

        @group = {
          name: @special_group.name,
          full_name: @special_group.full_name,
          total: @special_group.user_count,
          users: users,
          current: users_count,
          limit: limit
        }
      end

      def member_query
        online_minute   = online_minute_for("member")
        limit           = setting_for("member_limit", mobile_or_desktop).to_i

        users = User
          .where("last_seen_at > ?", online_minute)
          .where.not(id: @group_member_ids)
          .select(:id, :username, :name)
          .order(last_seen_at: :desc)
          .limit(limit)

        users_count = User
          .where("last_seen_at > ?", online_minute)
          .where.not(id: @group_member_ids)
          .count

        @member = {
          users: users,
          current: users_count,
          total: User.count,
          limit: limit
        }
      end

      def ps_set(key, val)
        PluginStore.set("whats_going_on", key, val)
      end

      def ps_get(key)
        PluginStore.get("whats_going_on", key)
      end

      def get_most_online(current_total)
        tmp_most_online = { total: current_total, time: Time.now }
        old_most_online = ps_get("most_online")

        if old_most_online.blank? || tmp_most_online[:total] >= old_most_online[:total]
          ps_set("most_online", tmp_most_online)
          tmp_most_online
        else
          old_most_online
        end
      end

  end
end