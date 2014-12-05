class Thing < ActiveRecord::Base
  acts_as_nested_set
  include FlagShihTzu
  include HstorePropertiesConcern

  validates :name, presence: true

  alias :container :parent
  alias :contained :children

  hstore_attr :width, :default => 0
  hstore_attr :height, :default => 0
  hstore_attr :depth, :default => 0
  hstore_attr :weight, :default => 0

  def num_contained
    children.count
  end

  has_flags 1 => :marked
end
