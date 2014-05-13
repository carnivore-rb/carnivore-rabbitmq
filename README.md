# Carnivore RabbitMQ

Provides RabbitMQ `Carnivore::Source`

# Usage

## RabbitMQ

```ruby
require 'carnivore'
require 'carnivore-rabbitmq'

Carnivore.configure do
  source = Carnivore::Source.build(
    :type => :rabbitmq,
    :args => {
      :connection => {
        :connection => :args
      },
      :exchange => 'e_name',
      :queue => 'q_name'
    }
  )
end
```

# Info
* Carnivore: https://github.com/heavywater/carnivore
* Repository: https://github.com/heavywater/carnivore-rabbitmq
* IRC: Freenode @ #heavywater
