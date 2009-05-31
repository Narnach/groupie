require 'testy'
require 'lib/groupie'

Testy.testing 'Groupie' do
  test '100% certain spam' do |t|
    g = Groupie.new
    g[:spam].add %w[viagra]
    g[:ham].add %w[flowers]
    classification = g.classify 'viagra'
    t.check :name, :expect => [:spam], :actual => classification
  end
end
