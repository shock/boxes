class ThingTag < ActiveRecord::Base
  belongs_to :thing
  belongs_to :tag

  audited associated_with: :thing

  after_save :touch_thing
  before_destroy :touch_self
  after_destroy :touch_thing

  def touch_self
    self.touch
  end

  def touch_thing
    self.thing.updated_at = self.updated_at
    self.thing.save!
  end

end
