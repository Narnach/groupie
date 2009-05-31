require 'rubygems'
require 'testy'
require 'lib/groupie'

Testy.testing 'Groupie' do
  test 'viagra is certainly spam' do |t|
    g = Groupie.new
    g[:spam].add %w[viagra]
    g[:ham].add %w[flowers]
    classification = g.classify 'viagra'
    t.check 'viagra is',
      :expect => {:spam => 1.0},
      :actual => classification
  end

  test 'buying can be spam or ham' do |t|
    g = Groupie.new
    g[:spam].add %w[buy viagra now]
    g[:ham].add %w[buy flowers for your mom]
    classification = g.classify 'buy'
    t.check 'buy is classified as',
      :expect => {:spam => 0.5, :ham => 0.5},
      :actual => classification
  end
end
