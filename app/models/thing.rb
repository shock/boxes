class Thing < ActiveRecord::Base
  acts_as_nested_set depth_column: :tree_depth

  ROOT_NAME = "<none>"

  def self.root
    find_or_create_by(name: ROOT_NAME, parent_id: nil)
  end

  before_save :default_root
  after_save :move_to_parent

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

private

  def default_root
    self.parent_id ||= self.root.id unless self.name == ROOT_NAME
  end

  def move_to_parent
    return unless parent_id_changed?
    parent = self.class.find(self.parent_id)
    self.move_to_child_of parent
  end
end
