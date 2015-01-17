require 'rails_helper'

describe Thing do

  describe "validations" do
    it "should require name" do
      thing = Thing.new
      expect(thing.valid?).to eq false
      expect(thing.errors[:name].size).to eq 1
    end
  end

  describe "AR callbacks" do
    describe "#touch_ancestors" do
      it "should update all ancestors updated_at to it's own after save" do
        orig_time = Time.now - 1.hour
        grand_pappy = Thing.create!(name: "grand_pappy")
        pops = Thing.create!(name: "pops", parent: grand_pappy)
        pops.move_to_child_of(grand_pappy)
        son = Thing.create!(name: "son", parent: pops)
        son.move_to_child_of(pops)
        aunt = Thing.create!(name: "aunt", parent: grand_pappy)
        aunt.move_to_child_of(grand_pappy)
        Thing.update_all(updated_at: (orig_time))
        Thing.all.map(&:updated_at).each do |updated_at|
          expect(updated_at.utc).to eq (orig_time).utc
        end
        son.save!
        son.ancestors.map(&:updated_at).each do |updated_at|
          expect(updated_at.utc).to eq son.updated_at.utc
        end
        expect(son.updated_at).to eq(son.parent.updated_at)
        expect(aunt.reload.updated_at).to eq(orig_time)
      end
      it "should update all ancestors updated_at to it's destroyed" do
        orig_time = Time.now - 1.hour
        grand_pappy = Thing.create!(name: "grand_pappy")
        pops = Thing.create!(name: "pops", parent: grand_pappy)
        pops.move_to_child_of(grand_pappy)
        son = Thing.create!(name: "son", parent: pops)
        son.move_to_child_of(pops)
        aunt = Thing.create!(name: "aunt", parent: grand_pappy)
        aunt.move_to_child_of(grand_pappy)
        Thing.update_all(updated_at: (orig_time))
        Thing.all.map(&:updated_at).each do |updated_at|
          expect(updated_at.utc).to eq (orig_time).utc
        end
        son.destroy
        expect(son.updated_at).to be > orig_time
        son.ancestors.each do |thing|
          expect(thing.updated_at.utc).to eq son.updated_at.utc
        end
        expect(son.updated_at).to eq(son.parent.updated_at)
        expect(aunt.reload.updated_at).to eq(orig_time)
      end
    end
  end
end