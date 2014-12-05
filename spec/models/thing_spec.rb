require 'rails_helper'

describe Thing do

  describe "validations" do
    it "should require name" do
      thing = Thing.new
      expect(thing.valid?).to eq false
      expect(thing.errors[:name].size).to eq 1
    end
  end
end