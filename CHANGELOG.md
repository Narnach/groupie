## Unreleased changes

The next release will be 0.5.0 due to a breaking change: removal of code that was deprecated in 0.4.0.

- Breaking: remove `String#tokenize` core extension; please use `Groupie.tokenize(string)` instead
- Deps: add Ruby 3.1 to list of tested & supported gems
- Chore: require multi-factor authentication to publish gem updates
- Chore: add Security.md to advertise a security policy
- Style: addressed Lint/AmbiguousOperatorPrecedence
- Dev: bump development dependencies multiple times
- Dev: switch to DepFu to manage development dependencies

## Version 0.4.1 -- 2021-09-08

Non-functional fixes to the CI config and Rubygems.org metadata.

- Fix: correct changelog uri for gem
- CI: fix dependabot config

## Version 0.4.0 -- 2021-09-07

Welcome to 2021, where Ruby version 2.6 is the lowest with official support, Bundler is the default for managing packages and RSpec version 3 is used to test things. This version updates Groupie into this decade.

- Refactor: update Groupie to 2021 standards
- Feat: raise Groupie::Error instead of RuntimeError
- Feat: deprecate String#tokenize in favor of Groupie.tokenize
- Doc: document API of Groupie
- Doc: update readme with examples
- Refactor: reorder Groupie methods by importance
- Refactor: simplify Groupie#classify
- Refactor: reduce complexity of Groupie#unique_words
- Refactor: simplify Groupie#classify\_text

## Version 0.3.0 -- 2010-07-29

Multiple changes to the 'unique words' strategy, hopefully improving the behavior.

- Cache unique words in an instance var to reduce time required to do subsequent lookups
- Sanity spec
- Unique strategy now includes all words except for the global 4th quartile
- Unique strategy changed yet again: only ignore words that occur more than their group's median
- Unique strategy now behaves like sqrt that only checks unique words
- Unique word finder uses less elegant but (hopefully) faster code
- Removed gemspec

## Version 0.2.3 -- 2010-07-29

Add a new 'unique words' strategy, which ignores words that occur in all categories.

- Added 'unique' classification strategy
- Added Group#<< as alias for Group#add
- Updated readme

## Version 0.2.2 -- 2010-07-25

Bugfix for log10 strategy.

- Fixed log10 strategy counting for Groupie.classify

## Version 0.2.1 -- 2010-07-25

Offer multiple ways to weigh word counts in calculating final scores.

- Added sqrt and log word counting strategies

## Version 0.2.0 -- 2010-07-25

Classification can't raise division by zero errors anymore.

- Groupie.classify_text ignores unclassified tokens

## Version 0.1.1 -- 2010-07-25

Swap test framework and tokenization improvements.

- Regenerated gemspec
- Strip quotes from tokens
- Replaced testy tests with rspec

## Version 0.1.0 -- 2010-07-25

The initial release as a gem, after working on this on/off over a year.

- Added gemspec
- Fixed text classification to properly average group scores
- Added test for classifying tokenized html email spam
- Classification of texts is now possible
- Added readme and MIT license
- Test the full html and headers of tokenized emails
- Support infix commas for tokenized strings
- Allow infix dots in tokenized strings
- Strip HTML tags when sanitizing a string
- Classify common words based on tokenized text from spam.la e-mails
- Added String#tokenize
- Ensure a Group will still work when loaded from YAML
- Added test helper file
- Refactored Group to maintain a Hash of words and counts instead of a list of words
- Removed obsolete method
- Added testcase for three groups
- Support multiple examples to add more weight to their grouping
- Renamed tests to reflect intent of content
- Classification now allows for a degree of certainty
- Implemented simple spam check
