# Groupie

[![Depfu](https://badges.depfu.com/badges/367956233b3b31a6fc19db4515263b9e/overview.svg)](https://depfu.com/github/Narnach/groupie?project_id=34004)

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

    bundle install

Or install it system-wide via:

    gem install groupie

## Usage

Here is an annotated console session that shows off the features available in Groupie.

```ruby
# Instantiate a new Groupie instance
groupie = Groupie.new

# Groups are defined as you use them, so let's get started by adding some pre-tokenized words
groupie[:spam].add(%w[this is obvious spam please buy our product])
groupie[:spam].add(%w[hello friend this is rich prince i have awesome bitcoin for you])
groupie[:ham].add(%w[you are invited to my awesome party just click the link to rsvp])

# Is your data less than clean? We've got a tokenizer for that!
tokens = Groupie.tokenize('Please give me your password so I can haxx0r you!')
# => ["please", "give", "me", "your", "password", "so", "i", "can", "haxx0r", "you"]
groupie[:spam].add(tokens)

# So, now let's attempt to classify a text and see if it's spam or ham:
test_tokens = %w[please click the link to reset your password for our awesome product]
groupie.classify_text(test_tokens)
# => {:spam=>0.5909090909090909, :ham=>0.4090909090909091}
# As you can see, this password reset email looks a little dodgy...
# We have multiple strategies for drawing conclusions about what group it belongs to.
# The default you saw above is :sum, it weighs each word by the total sum of occurrences.
# Let's see if it looks less bad by using a different classification strategies.

# Log reduces the weight of each word to the log10 of its occurrence count:
# - Count 1 is weight 0
# - Count 10 is weight 1
# - Count 100 is weight 2
groupie.classify_text(test_tokens, :log)
# => {:spam=>0.5, :ham=>0.5}
# This is even more even, most likely because it ignores all single-count words...

# Square root algorithm is less harsh, it reduces the weight of each word to the square root of the count:
# - Count 1 is weight 1
# - Count 4 is weight 2
# - Count 9 is weight 3
groupie.classify_text(test_tokens, :sqrt)
# => {:spam=>0.5909090909090909, :ham=>0.4090909090909091}
# This seems to result in the same value as :sum

# Unique uses the same weighting algorithm as the square root, but it modifies the word dictionary:
# it discards the 25% most common words, so less common words gain higher predictive power.
groupie.classify_text(test_tokens, :unique)
# => {:spam=>0.625, :ham=>0.375}
# This looks even worse for our poor password reset email.
# In case you're curious, the ignored words in this case are:
test_tokens - (test_tokens & groupie.unique_words)
# => ["please", "to", "reset", "awesome"]
# If you'd be classifying email, you can assume that common email headers will get ignored this way.

# If you're just starting out, your incomplete data could lead to dramatic misrepresentations of the data.
# To balance against this, you can enable smart weight:
groupie.smart_weight = true
# You could also set it during initialization via Groupie.new(smart_weight: true)
# What's so useful about it? It adds a default weight to _all_ words, even the ones you haven't
# seen yet, which counter-acts the data you have. This shines in low data situations,
# reducing the impact of the few words you have seen before.
groupie.default_weight
# => 1.2285714285714286
# Classifying the same text as before should consider all words, and add this default weight to all words
# It basically gives all groups the likelihood of "claiming" a word,
# unless there is strong data to suggest otherwise.
groupie.classify_text(test_tokens)
# => {:spam=>0.5241046831955923, :ham=>0.4758953168044077}
```

Persistence can be naively done by using YAML:

```ruby
# Instantiate a new Groupie instance
groupie = Groupie.new
groupie[:spam].add(%w[assume you have a lot of data you care about])

require 'yaml'
yaml = YAML.dump(groupie)
loaded = YAML.safe_load(yaml, permitted_classes: [Groupie, Groupie::Group, Symbol])
```

For I'm still experimenting with Groupie in [Infinity Feed](https://www.infinity-feed.com), so persistence is a Future Problem for me there. In development, I'm building (low data count) classifiers in memory and discarding them after use.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Rubocop is available via `bin/rubocop` with some friendly default settings.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org). For obvious reasons, only the project maintainer can do this.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Narnach/groupie.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
