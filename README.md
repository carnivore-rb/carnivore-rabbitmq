# Carnivore RabbitMQ

Provides RabbitMQ `Carnivore::Source`

# Usage

## RabbitMQ

```ruby
require 'carnivore'
require 'carnivore-rabbitmq'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :rabbitmq, :args => {:stuff => :yeah}
  )
end
```

# Info
* Carnivore: https://github.com/heavywater/carnivore
* Repository: https://github.com/heavywater/carnivore-rabbitmq
* IRC: Freenode @ #heavywater
