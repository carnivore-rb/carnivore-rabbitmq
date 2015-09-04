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
  if(ENV['BUILD_JAVA'] || RUBY_PLATFORM == 'java')
    s.platform = 'java'
    s.add_runtime_dependency 'march_hare', '~> 2.12.0'
  else
    s.add_runtime_dependency 'bunny', '~> 2.2.0'
  end
  s.add_runtime_dependency 'carnivore', '>= 1.0.0', '< 2.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'minitest'
  s.files = Dir['lib/**/*'] + %w(README.md CHANGELOG.md CONTRIBUTING.md LICENSE)
end
