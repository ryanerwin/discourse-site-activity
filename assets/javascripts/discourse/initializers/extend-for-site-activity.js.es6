import PreferencesInterface from "discourse/controllers/preferences/interface";

export default {
  name: "extend-for-site-activity",
  initialize() {

    PreferencesInterface.reopen({

      saveAttrNames: function() {
        const attrs = this._super(...arguments);
        if (!attrs.includes("custom_fields")) attrs.push("custom_fields");
        return attrs;
      }.property(),

      _updateHideSiteActivity: function() {
        const saved = this.get("saved");
        const currentUser = this.get("currentUser");

        if (saved && currentUser && this.get("model.id") == currentUser.get("id")) {
          currentUser.set("hide_site_activity", this.get("model.custom_fields.hide_site_activity"));
        }
      }.observes("saved")

    });

  }
};