# Flockbot Ruby Library

The Flockbot Ruby library provides convenient access to some limited features
of the [Flocknote](https://www.flocknote.com/) application. Flocknote does
not currently expose a public API, so this gem leverages parts of the
internal API in order to better integrate with external applications.

### Requirements

* Ruby 2.0+.

### Bundler

Add the following to your `Gemfile`:

``` ruby
gem "flockbot", git: "git://github.com/setonparish/flockbot"
```

## Configuration

The `email` and `password` need to be for a Flocknote user with admin rights.
The `subdomain` is the first part of your Flocknote URL.  Example: https://myparish.flocknote.com/

You can configure the client in three different ways depending on your needs.

### Manual configuration

```ruby
require 'flockbot'

client = Flockbot::Client.new(subdomain: "myparish", email: "me@example.com", password: "abc123")
```

### Block configuration

``` ruby
require 'flockbot'

Flockbot.configure do |config|
  config.subdomain = "myparish"
  config.email = "me@example.com"
  config.password = "abc123"
end

client = Flockbot::Client.new
```

### Environment variable configuration
You can also set environment variables and Flockbot will use those by default.

```ruby
require 'flockbot'

# environment variables set somewhere in your application
# ENV["FLOCKBOT_SUBDOMAIN"] = "myparish"
# ENV["FLOCKBOT_EMAIL"] = "me@example.com"
# ENV["FLOCKBOT_PASSWORD"] = "abc123"

client = Flockbot::Client.new
```

## Quick Start Usage Examples

### Groups

You can retrieve information about your Flocknote groups.

```ruby
require 'flockbot'

client = Flockbot::Client.new(subdomain: "myparish", email: "me@example.com", password: "abc123")

# List all of your groups
client.groups
#=> [#<Flockbot::Models::Group id=971110 name=Everyone>,
#    #<Flockbot::Models::Group id=981068 name=RCIA>,
#    #<Flockbot::Models::Group id=992537 name=Alpha>,
#    #<Flockbot::Models::Group id=928649 name=Lectors]

# Find just your "everyone" group
client.everyone_group
#=> #<Flockbot::Models::Group id=971110 name=Everyone>

# Get subscriber counts for any group
client.groups.first.subscriber_count
#=> 924
```

### Adding Users

You can add a new or existing user to any Flocknote group.

A `first_name` and `last_name` are always required as well as an `email`, `mobile_phone`, or both.

If the user is not currently in Flocknote, they will be added to the group you specified as well as your "everyone" group.

If the user already exists in Flocknote, they will be automatically matched on either `email` or `mobile_phone` and added to the specified group.  This is true even if the name provided is not the exact one found in Flocknote.  As an example, if you already have a user named "James Smith" in Flocknote with email "jim@example.com" and you use Flockbot to add "Jimmy Smith" with email "jim@example.com" to your "Lectors" group, your existing user will added to the "RCIA group".  A duplicate user will not be created, nor will Flockbot change the existing user's name.

```ruby
require 'flockbot'

client = Flockbot::Client.new(subdomain: "myparish", email: "me@example.com", password: "abc123")

group = client.groups.last
#=> #<Flockbot::Models::Group id=928649 name=Lectors>

# adding a new user with just an email
group.add_user(first_name: "New", last_name: "User", email: "newuser@example.com")
#=> true

# adding a new user with just a mobile phone
group.add_user(first_name: "New", last_name: "User", mobile_phone: "555-555-5555")
#=> true

# adding an existing user
group.add_user(first_name: "Existing", last_name: "User", email: "existinguser@example.com")
#=> true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/setonparish/flockbot.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
