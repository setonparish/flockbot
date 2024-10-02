# Flockbot Ruby Library

The Flockbot Ruby library provides convenient access to some limited features
of the [Flocknote](https://www.flocknote.com/) application. Flocknote does
not currently expose a public API, so this gem leverages parts of the
internal API in order to better integrate with external applications.

## Requirements

* Ruby 3.3

## Setup

Add the following to your `Gemfile`:

``` ruby
gem "flockbot", git: "git://github.com/setonparish/flockbot"
```

## Usage

### Create a `Flockbot::Client` with authenticated session

```ruby
#
# 1. Create a session
#
# Note: The `subdomain` is the first part of your Flocknote URL.  Example: https://myparish.flocknote.com
session = Flockbot::Session.new(subdomain: "myparish", email: "me@example.com")

#
# 2. Authenticate session using one of three ways:
#
# (A) using password
session.login!(password: "mypassword")

# (B) using one time code
session.send_one_time_code
session.login!(code: "1234") # from flocknote email

# (C) using a previous session token
token = some_prior_session.session_token
session.login!(token: token)

#
# 3. Create a client
#
client = Flockbot::Client.new(session: session)
```

### Client Usage

#### List all of your groups

```ruby
client.groups
=> [#<Flockbot::Models::Group {:id=>971110, :name=>"Everyone", :short_name=>"everyone", :everyone?=>true, :subscriber_count=>nil}>,
 #<Flockbot::Models::Group {:id=>977777, :name=>"Lectors", :short_name=>"LectorsGroup", :everyone?=>false, :subscriber_count=>nil}>,
 #<Flockbot::Models::Group {:id=>876666, :name=>"Alpha", :short_name=>"Alpha", :everyone?=>false, :subscriber_count=>nil}>]
```

#### Get a subscriber count for any group

```ruby
client.groups.first.subscriber_count
#=> 924
```

#### Find the `everyone` group

```ruby
client.everyone_group
=> #<Flockbot::Models::Group {:id=>971110, :name=>"Everyone", :short_name=>"everyone", :everyone?=>true, :subscriber_count=>nil}>
```

#### Add a new or existing user to any Flocknote group

A `first_name` and `last_name` are always required and then you must supply either an `email`, `mobile_phone`, or both.

If the user is not currently in Flocknote, they will be added to the group you specified as well as your "everyone" group.

If the user already exists in Flocknote, they will be automatically matched on either `email` or `mobile_phone` and added to the specified group.  This is true even if the name provided is not the exact one found in Flocknote.  As an example, if you already have a user named "James Smith" in Flocknote with email "jim@example.com" and you use Flockbot to add "Jimmy Smith" with email "jim@example.com" to your "Lectors" group, your existing user will added to the "RCIA group".  A duplicate user will not be created, nor will Flockbot change the existing user's name.

```ruby
group = client.groups.last
 #<Flockbot::Models::Group {:id=>977777, :name=>"Lectors", :short_name=>"LectorsGroup", :everyone?=>false, :subscriber_count=>nil}>

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

Tests can be run by running `bundle exec rspec`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).