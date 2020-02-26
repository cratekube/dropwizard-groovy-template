package io.cratekube.example

import io.dropwizard.Configuration
import io.federecio.dropwizard.swagger.SwaggerBundleConfiguration

import javax.validation.Valid
import javax.validation.constraints.NotNull

/**
 * Configuration class for this Dropwizard application.
 */
class AppConfig extends Configuration {
  @Valid
  @NotNull
  SwaggerBundleConfiguration swagger
}
