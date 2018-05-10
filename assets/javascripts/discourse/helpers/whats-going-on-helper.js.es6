import { registerHelper } from 'discourse-common/lib/helpers';

export default registerHelper("wgo-user-sep", function(params) {
  return params[0] < params[1] ? "," : "";
});

registerHelper("wgo-sum", function(params) {
  return params[0] + params[1];
});

registerHelper("wgo-users", function(params) {
  if (!params[0]) return;

  return params[0].map((username) => {
    username = Handlebars.Utils.escapeExpression(username);
    return `<a href="/u/${username}" class="wgo-user">${username}</a>`;
  }).join(", ");
});