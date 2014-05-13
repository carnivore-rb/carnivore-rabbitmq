$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'carnivore-rabbitmq/version'

spec = Gem::Specification.new do |s|
  s.name = 'carnivore-rabbitmq'
  s.version = Carnivore::Rabbitmq::VERSION.version
  s.summary = 'Message processing helper'
  s.author = 'Chris Roberts'
  s.email = 'chrisroberts.code@gmail.com'
  s.homepage = 'https://github.com/heavywater/carnivore-rabbitmq'
  s.description = 'Carnivore RabbitMQ source'
  s.require_path = 'lib'
  s.license = 'Apache 2.0'
  s.add_dependency 'carnivore', '>= 0.1.8'
  s.add_dependency 'bunny'
  s.files = Dir['**/*']
end
