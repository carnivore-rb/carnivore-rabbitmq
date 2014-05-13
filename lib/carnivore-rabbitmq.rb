require 'carnivore-rabbitmq/version'
require 'carnivore'

module Carnivore
  class Source
    autoload :Rabbitmq, 'carnivore-rabbitmq/rabbitmq'
  end
end

Carnivore::Source.provide(:rabbitmq, 'carnivore-rabbitmq/rabbitmq')
