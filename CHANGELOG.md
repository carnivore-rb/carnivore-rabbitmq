# v0.2.6
* Kill connection to server when terminated

# v0.2.4
* Refactor to isolate connection to ease supervision
* Push received messages via internal signaling

# v0.2.2
* Transfer messages via internal signal
* Properly cleanup on termination
* Cache signals on source

# v0.2.0
* Update for latest carnivore

# v0.1.8
* Include support for auto extraction
* Detect received payload correctly based on adapter

# v0.1.6
* Fix connection setup when using march_hare

# v0.1.4
* Move routing key set prior to queue setup
* Add `:publish_to` option to allow publish to exchange instead of queue

# v0.1.2
* Include option to provide routing key
* Only start message collection if source is receiving
* Parse payload within collector on receipt

# v0.1.0
* Initial release
