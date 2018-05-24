import { registerHelper, registerUnbound } from 'discourse-common/lib/helpers';

export default registerHelper("wgo-sum", function(params) {
  return params[0] + params[1];
});

registerUnbound("wgo-users", function(users) {
  if (!users) return;

  const currentUser = Discourse.User.current();

  return users.map((user) => {
    const name      = _escape(user.name || user.username);
    const username  = _escape(user.username);
    const addClass  = currentUser && currentUser.id === user.id ? "wgo-user-self" : "";

    return `<a href="/u/${username}" class="wgo-user ${addClass}">${name}</a>`;
  }).join(", ");
});

function _escape(arg) {
  return Handlebars.Utils.escapeExpression(arg);
}