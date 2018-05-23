export default {
  shouldRender(_args, component) {
    if (component.siteSettings.login_required && !component.currentUser) return false;
    return true;
  }
};