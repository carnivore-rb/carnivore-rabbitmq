eval File.read(File.expand_path(File.join(File.dirname(__FILE__), 'carnivore-rabbitmq.gemspec')))

spec.platform = 'java'
spec.add_dependency 'march_hare'
spec
