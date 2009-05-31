require File.join(File.dirname(__FILE__), %w[.. test_helper])

Testy.testing 'Groupie::Group' do
  test 'can be serialized and loaded through YAML' do |t|
    require 'yaml'

    g = Groupie::Group.new 'group'
    g.add %w[buy flowers]
    g2 = YAML.load(g.to_yaml)
    g2.add %w[buy candy]
    t.check 'default value works for new entries',
      :expect => 1,
      :actual => g2.count('candy')
  end
end
