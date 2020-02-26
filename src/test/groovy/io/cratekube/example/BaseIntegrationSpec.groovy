package io.cratekube.example

import io.dropwizard.testing.junit.DropwizardAppRule
import org.junit.ClassRule
import spock.lang.Shared
import spock.lang.Specification

import javax.ws.rs.client.Client

import static io.dropwizard.testing.ResourceHelpers.resourceFilePath

class BaseIntegrationSpec extends Specification {
  @Shared Client client

  @ClassRule public static final DropwizardAppRule<AppConfig> APP = new DropwizardAppRule<>(
    App,
    resourceFilePath('testapp.yml')
  )

  def setupSpec() {
    APP.before()
  }

  def cleanupSpec() {
    APP.after()
  }

  def setup() {
    client = APP.client()
  }

  def baseRequest(String path = '') {
    return client.target("http://localhost:${APP.localPort}${path}").request()
  }
}
