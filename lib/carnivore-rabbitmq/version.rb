module Carnivore
  module Rabbitmq
    # Custom version class
    class Version < Gem::Version
    end
    # Current version of library
    VERSION = Version.new('0.1.1')
  end
end
