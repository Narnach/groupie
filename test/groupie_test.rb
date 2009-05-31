require 'rubygems'
require 'testy'
require 'lib/groupie'

Testy.testing 'Groupie' do
  test 'classification is certain' do |t|
    g = Groupie.new
    g[:spam].add %w[viagra]
    g[:ham].add %w[flowers]
    classification = g.classify 'viagra'
    t.check 'viagra is',
      :expect => {:spam => 1.0},
      :actual => classification
  end

  test 'classification is split between two groups' do |t|
    g = Groupie.new
    g[:spam].add %w[buy viagra now]
    g[:ham].add %w[buy flowers for your mom]
    classification = g.classify 'buy'
    t.check 'buy is classified as',
      :expect => {:spam => 0.5, :ham => 0.5},
      :actual => classification
  end

  test 'classification is weighed more heavy in one group' do |t|
    g = Groupie.new
    g[:spam].add %w[buy viagra now]
    g[:spam].add %w[buy cialis now]
    g[:ham].add %w[buy flowers for your mom]
    t.check 'buy is classified as',
      :expect => {:spam => 2 / 3.0, :ham => 1 / 3.0},
      :actual => g.classify('buy')
  end

  test 'classification works fine with more than two groups' do |t|
    g = Groupie.new
    g[:weight].add 'pound'
    g[:currency].add 'pound'
    g[:phone_key].add 'pound'
    t.check 'pound is classified as',
      :expect => {:weight => 1/3.0, :currency => 1/3.0, :phone_key => 1/3.0},
      :actual => g.classify('pound')
  end
end
