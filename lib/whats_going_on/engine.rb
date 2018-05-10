module WhatsGoingOn
  class Engine < ::Rails::Engine
    isolate_namespace WhatsGoingOn

    config.after_initialize do
      Discourse::Application.routes.append do
        mount ::WhatsGoingOn::Engine, at: "/whats-going-on"
      end
    end

  end
end