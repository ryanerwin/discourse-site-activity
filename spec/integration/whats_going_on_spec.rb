require 'rails_helper'

def get_index(mobile = false)
  get "/whats-going-on/", params: { mobile: mobile }, headers: {"X-Requested-With" => "XMLHttpRequest"}
end

def fabricate_group_users(num, username_prefix, group)
  num.times.map do |n|
    user = Fabricate(:user, username: [username_prefix, n].join)
    Fabricate(:group_user, user: user, group: group)
  end
end

def online!(user)
  user.last_seen_at = 5.days.ago
  user.save!
end

def test_limit(mobile, group_limit, member_limit)
  get_index(mobile)

  parsed = JSON.parse(response.body)
  expect(parsed["type"]).to eq(mobile ? "mobile" : "desktop")

  _group = parsed["group"]

  expect(_group["limit"]).to eq(group_limit)
  expect(_group["users"].length).to eq(group_limit)

  _member = parsed["member"]

  expect(_member["limit"]).to eq(member_limit)
  expect(_member["users"].length).to eq(member_limit)
end

describe(WhatsGoingOn::UsersOnlineController) {

  let(:group) { Fabricate(:group) }
  let(:members) { 20.times.map { |n| Fabricate(:user, username: "member#{n}") } }
  let(:online_members) { 10.times.map { |n| Fabricate(:user, username: "member_online#{n}") } }
  let(:group_users) { fabricate_group_users(10, "group_user", group) }
  let(:online_group_users) { fabricate_group_users(5, "group_user_online", group) }

  before {
    SiteSetting.site_activity_group = group.name
    group_users.each { |group_user| group_user.user.save! }
    online_members.each { |user| online!(user) }
    online_group_users.each { |group_user| online!(group_user.user) }
  }

  describe("special group") {
    it("should return correct result") {
      get_index
      parsed = JSON.parse(response.body)
      expect(parsed["group"]["name"]).to eq(group.name)

      online_group_usernames = online_group_users.map { |gu| gu.user.username }
      parsed["member"]["users"].each do |user|
        expect(online_group_usernames.include?(user["username"])).to_not eq(true)
      end

      SiteSetting.site_activity_group = nil
      get_index
      parsed = JSON.parse(response.body)
      expect(parsed["group"]).to eq(nil)
    }
  }

  describe("online minute") {
    it("should return correct result") {
      get_index

      parsed = JSON.parse(response.body)
      expect(parsed["current"]["member"]).to eq(15)

      _group = parsed["group"]

      expect(_group["current"]).to eq(5)
      expect(_group["total"]).to eq(15)

      _member = parsed["member"]

      expect(_member["current"]).to eq(10)
      expect(_member["total"]).to eq(User.count)

      SiteSetting.site_activity_member_online_minute = 10

      get_index

      parsed = JSON.parse(response.body)
      expect(parsed["current"]["member"]).to eq(5)
      expect(parsed["group"]["current"]).to eq(5)
      expect(parsed["member"]["current"]).to eq(0)
    }
  }

  describe("limit") {
    let(:gld) { 4 }
    let(:glm) { 3 }
    let(:mld) { 7 }
    let(:mlm) { 6 }

    before {
      SiteSetting.site_activity_group_limit_desktop   = gld
      SiteSetting.site_activity_group_limit_mobile    = glm
      SiteSetting.site_activity_member_limit_desktop  = mld
      SiteSetting.site_activity_member_limit_mobile   = mlm
    }

    context("desktop") {
      it("should return correct result") {
        test_limit(false, gld, mld)
      }
    }

    context("mobile") {
      it("should return correct result") {
        test_limit(true, glm, mlm)
      }
    }

  }
}