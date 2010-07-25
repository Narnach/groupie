# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{groupie}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Wes Oldenbeuving"]
  s.date = %q{2010-07-25}
  s.description = %q{Group and classify text based on likelyhood of being included in a text of a specific category}
  s.email = %q{narnach@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE"
  ]
  s.files = [
    ".document",
     "LICENSE",
     "Rakefile",
     "VERSION",
     "groupie.gemspec",
     "lib/groupie.rb",
     "lib/groupie/core_ext/string.rb",
     "lib/groupie/group.rb",
     "readme.rdoc",
     "spec/fixtures/ham/email_ham1.txt",
     "spec/fixtures/ham/spam.la-44116217.txt",
     "spec/fixtures/spam/email_spam1.txt",
     "spec/fixtures/spam/email_spam2.txt",
     "spec/fixtures/spam/spam.la-44118014.txt",
     "spec/groupie/core_ext/string_spec.rb",
     "spec/groupie/group_spec.rb",
     "spec/groupie_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/Narnach/groupie}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Group and classify text}
  s.test_files = [
    "spec/groupie/core_ext/string_spec.rb",
     "spec/groupie/group_spec.rb",
     "spec/groupie_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<testy>, [">= 0"])
    else
      s.add_dependency(%q<testy>, [">= 0"])
    end
  else
    s.add_dependency(%q<testy>, [">= 0"])
  end
end

