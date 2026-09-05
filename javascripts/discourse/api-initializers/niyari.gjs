import { apiInitializer } from "discourse/lib/api";

export default apiInitializer((api) => {
  if (settings.header_dropdown_menu !== false) {
    const site_settings = api.container.lookup("service:site-settings");
    
    site_settings.navigation_menu = "header dropdown";
  }

  api.registerValueTransformer("topic-list-item-class", ({ value }) => {
    return [...value, "niyari-topic-card"];
  });
});
