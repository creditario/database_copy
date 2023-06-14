# Database Copy

This gem simplifies the process of database migration or replication by providing a straightforward interface to copy tables and their data, while allowing fine-grained control over the selection of tables and attributes.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add database_copy

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install database_copy

## Usage

After gem is installed copy a source database to a target. Provide the two params, source and target, as database URL.

    $ database_copy postgres://source postgres://target

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/creditario/database_copy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/database_copy/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/creditario/database_copy/blob/main/LICENSE.txt).

## Code of Conduct

Everyone interacting in the DatabaseCopy project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/creditario/database_copy/blob/main/CODE_OF_CONDUCT.md).
