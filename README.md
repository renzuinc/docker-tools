# Docker::Tools

A set of tools for Rake and Docker workflows, including local use of Docker Compose for testing, style enforcement and security checking where appropriate.


## Installation

Add this line to your application's Gemfile:

```ruby
gem "docker-tools", require: false,
                    git: "git@github.com:MrJoy/docker-tools.git"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install docker-tools


## Usage

TODO: Write usage instructions here

### Setup

1. In `Rakefile`, add this -- replacing the domain name with the URL of your private Docker registry:
    ```ruby
    require "rubygems"
    require "bundler/setup"
    Bundler.require(:default, :development, :test)
    Dotenv.load(".common.env", ".env")

    require "docker/tools"

    # The first path should allow `docker push`, with authentication.
    # The second path should only allow `docker pull`, without authentication, and only from your private VPC.
    Docker::Tools.init!("registry.myorg.com:5000", "registry.myorg.com:5000")
    ```
1. Create a file named `.rubocop.local.yml` with your own Rubocop rules / configuration.
    * This will be merged with the saner defaults provided by `docker-tools` when running `rake lint:rubocop`.

### Running The Tools

```bash
rake lint # Run all `lint:*` tasks.  Includes `bundler-audit` and Rubocop by default.

rake docker:build docker:tag docker:push

# If you have a `docker-compose.yml` file:

rake compose:kill compose:rm compose:up
```

### Custom Lint Tasks

To add a task that gets executed when you run `rake lint`, simply create it in the `lint` namespace:

```ruby
namespace :lint do
  desc "Some sort of lint check for your project.  Will be included in `rake lint` automatically."
  task :my_check do
  end
end
```

### Loading App Code in Console Task

Add a task that loads your application code as a dependency of the `console` task:

```ruby
task console: [:my_env_loader_task]
```

### Making Your Own Auto-Discovery Task Groups

```ruby
desc "Run all `my_group:*` tasks."
parent_task :my_group

namespace :my_group do
  desc "Some task to include in `rake my_group`."
  task :some_task do
  end
end
```


## Contributing

1. Fork it ( https://github.com/MrJoy/docker-tools/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
