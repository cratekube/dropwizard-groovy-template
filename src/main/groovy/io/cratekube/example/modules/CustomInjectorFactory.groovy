package io.cratekube.example.modules

import com.google.inject.Guice
import com.google.inject.Injector
import com.google.inject.Module
import com.google.inject.Stage
import com.google.inject.util.Modules
import ru.vyarus.dropwizard.guice.injector.InjectorFactory

/**
 * This class was created after looking at the following guide in the dropwiard-guicey documentation:
 * https://xvik.github.io/dropwizard-guicey/4.0.1/guide/test/#overriding-beans
 *
 * This is used to inject custom modules during our integration tests.
 */
class CustomInjectorFactory implements InjectorFactory {
  static final ThreadLocal<Module[]> CUSTOM_MODULES = new ThreadLocal<Module[]>()

  @Override
  Injector createInjector(Stage stage, Iterable<? extends Module> modules) {
    def overrides = CUSTOM_MODULES.get()
    CUSTOM_MODULES.remove()
    return Guice.createInjector(stage, overrides == null ? modules : [Modules.override(modules).with(overrides)])
  }

  static void override(Module... modules) {
    CUSTOM_MODULES.set(modules)
  }
}
