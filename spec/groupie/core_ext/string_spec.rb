# frozen_string_literal: false

require 'spec_helper'

RSpec.describe String do
  describe '#tokenize' do
    it 'warns that it is deprecated' do
      string = 'test'
      allow(string).to receive(:warn)
      string.tokenize
    end

    it 'delegates to Groupie.tokenize' do
      string = 'test'
      allow(Groupie).to receive(:tokenize).with(string)
      string.tokenize
    end
  end
end
