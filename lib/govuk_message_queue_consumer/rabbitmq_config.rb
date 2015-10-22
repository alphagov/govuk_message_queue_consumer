class RabbitMQConfig
  class ConfigurationError < StandardError
  end

  def from_environment
    {
      hosts: fetch("RABBITMQ_HOSTS").split(','),
      port: fetch("RABBITMQ_PORT").to_i,
      vhost: fetch("RABBITMQ_VHOST"),
      user: fetch("RABBITMQ_USER"),
      pass: fetch("RABBITMQ_PASSWORD"),
      recover_from_connection_close: true,
    }
  end

private

  def fetch(variable_name)
    ENV[variable_name] || raise_error(variable_name)
  end

  def raise_error(variable_name)
    raise ConfigurationError, <<-err
      The environment variable #{variable_name} is not set. If you are in test
      mode, make sure you set the correct vars in your helpers. If you get this
      error in development, make sure you run rails or rake with `govuk_setenv`
      and puppet is up to date.
    err
  end
end
