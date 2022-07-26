module GovukMessageQueueConsumer
  module RabbitMQConfig
    class ConfigurationError < StandardError
    end

    def self.from_environment(env)
      {
        hosts: fetch(env, "RABBITMQ_HOSTS").split(","),
        vhost: fetch(env, "RABBITMQ_VHOST"),
        user: fetch(env, "RABBITMQ_USER"),
        pass: fetch(env, "RABBITMQ_PASSWORD"),
        recover_from_connection_close: true,
      }
    end

    def self.fetch(env, variable_name)
      env[variable_name] || raise_error(variable_name)
    end

    def self.raise_error(variable_name)
      raise ConfigurationError, <<-ERR
        The environment variable #{variable_name} is not set. If you are in test
        mode, make sure you set the correct vars in your helpers. If you get this
        error in development, make sure you run rails or rake with `govuk_setenv`
        and puppet is up to date.
      ERR
    end
  end
end
