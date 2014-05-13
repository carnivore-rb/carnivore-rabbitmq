$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__)) + '/lib/'
require 'carnivore-rabbitmq/version'

spec = Gem::Specification.new do |s|
  s.name = 'carnivore-rabbitmq'
  s.version = Carnivore::Rabbitmq::VERSION.version
  s.summary = 'Message processing source'
  s.author = 'Chris Roberts'
  s.email = 'code@chrisroberts.org'
  s.homepage = 'https://github.com/heavywater/carnivore-rabbitmq'
  s.description = 'Carnivore RabbitMQ source'
  s.require_path = 'lib'
  s.license = 'Apache 2.0'
  s.add_dependency 'carnivore', '>= 0.1.8'
  s.add_dependency 'bunny'
  s.files = Dir['lib/**/*'] + %w(README.md CHANGELOG.md CONTRIBUTING.md LICENSE)
end
