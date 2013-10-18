require 'carnivore-rabbitmq/version'
require 'carnivore'

Carnivore::Source.provide(:http, 'carnivore-rabbitmq/rabbitmq')
