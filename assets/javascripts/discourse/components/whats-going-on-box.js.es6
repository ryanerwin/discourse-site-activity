import { on } from 'ember-addons/ember-computed-decorators';
import { ajax } from 'discourse/lib/ajax';

export default Ember.Component.extend({

  classNames: ["wrap"],

  @on("init")
  setup() {
    this._fetch();
    this._refresh();
  },

  _fetch() {
    ajax("/whats-going-on/").then((result) => {
      this.set("model", result);
    }).catch((e) => {
      console.error(e);
    });
  },

  _refresh() {
    const handle = Ember.run.later((this), () => {
      this._fetch();
      this._refresh();
    }, {}, 10 * 60 * 1000); // 10 minutes

    this.set('timer', handle);
    console.log("_refresh");
  },

  @on("willDestroyElement")
  _cancel() {
    if (this.get('timer')) {
      Ember.run.cancel(this.get('timer'));
    }
  }

});