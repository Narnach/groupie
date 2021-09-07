# Groupie

Groupie is a simple way to group texts and classify new texts as being a likely member of one of the defined groups. Think of bayesian spam filters.

The eventual goal is to have Groupie work as a sort of bayesian spam filter, where you feed it spam and ham (non-spam) and ask it to classify new texts as spam or ham. Applications for this are e-mail spam filtering and blog spam filtering. Other sorts of categorizing might be interesting as well, such as finding suitable tags for a blog post or bookmark.

Started and forgotten in 2009 as a short-lived experiment, in 2010 Groupie got new features when I started using it on a RSS reader project that classified news items into "Interesting" and "Not interesting" categories.

## Current functionality

Current funcionality includes:
* Tokenize an input text to prepare it for grouping.
    * Strip XML and HTML tag.
    * Keep certain infix characters, such as period and comma.
* Add texts (as an Array of Strings) to any number of groups.
* Classify a single word to check the likelihood it belongs to each group.
* Do classification for complete (tokenized) texts.
* Pick classification strategy to weigh repeat words differently (weigh by sum, square root or log10 of words in group)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'groupie'
```

You can also perform this to do this for you:

    bundle add groupie

And then execute:

    $ bundle install

Or install it system-wide via:

    $ gem install groupie

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Narnach/groupie.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
