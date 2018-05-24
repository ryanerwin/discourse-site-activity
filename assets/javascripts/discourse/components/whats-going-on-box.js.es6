import { default as computed, on } from 'ember-addons/ember-computed-decorators';
import { ajax } from 'discourse/lib/ajax';

export default Ember.Component.extend({

  classNames: ["wrap"],

  @on("init")
  setup() {
    this._fetch();
    this._refresh();
  },

  _fetch() {
    ajax("/whats-going-on/", { data: { mobile: this.get("site.mobileView") } }).then((result) => {
      this.set("model", result);
    }).catch((e) => {
      console.error(e);
    });
  },

  _refresh() {
    const updateInterval = this.get("siteSettings.site_activity_update_interval_minute");

    const handle = Ember.run.later((this), () => {
      this._fetch();
      this._refresh();
    }, {}, updateInterval * 60 * 1000);

    this.set('timer', handle);
  },

  @on("willDestroyElement")
  _cancel() {
    if (this.get('timer')) {
      Ember.run.cancel(this.get('timer'));
    }
  },

  @computed("model.group.name", "model.group.full_name")
  groupName(name, full_name) {
    return full_name || name;
  }

});