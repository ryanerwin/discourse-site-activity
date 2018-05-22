import { registerHelper, registerUnbound } from 'discourse-common/lib/helpers';

export default registerHelper("wgo-sum", function(params) {
  return params[0] + params[1];
});

registerUnbound("wgo-users", function(users) {
  if (!users) return;

  return users.map((user) => {
    const name      = Handlebars.Utils.escapeExpression(user.name || user.username);
    const username  = Handlebars.Utils.escapeExpression(user.username);
    return `<a href="/u/${username}" class="wgo-user">${name}</a>`;
  }).join(", ");
});