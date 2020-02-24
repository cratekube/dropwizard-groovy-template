package io.cratekube

import io.dropwizard.Application
import io.dropwizard.setup.Environment

/**
 * Application for this Dropwizard application.
 */
class App extends Application<AppConfig> {
  static void main(String... args) {
    new App().run(args)
  }

  @Override
  void run(AppConfig configuration, Environment environment) throws Exception {}
}
