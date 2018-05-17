import { registerHelper } from 'discourse-common/lib/helpers';

export default registerHelper("wgo-sum", function(params) {
  return params[0] + params[1];
});

registerHelper("wgo-users", function(params) {
  if (!params[0]) return;

  return params[0].map((user) => {
    const name      = Handlebars.Utils.escapeExpression(user.name || user.username);
    const username  = Handlebars.Utils.escapeExpression(user.username);
    return `<a href="/u/${username}" class="wgo-user">${name}</a>`;
  }).join(", ");
});