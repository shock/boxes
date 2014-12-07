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

  def json_ltree_builder( json )
    json.id id
    json.label name
    children = self.children
    unless children.empty?
      json.children do
        json.array! children do |child|
          child.json_ltree_builder( json )
        end
      end
    end
    json
  end

  def to_builder
    Jbuilder.new do |json|
      json.array! [self] do |thing|
        thing.json_ltree_builder( json )
      end
    end
  end

  def to_tree
    tree = HashObj.new
    tree.id = id
    tree.label = name
    tree.description = description
    tree.children = children.map(&:to_tree)
    tree
  end

  def to_json
    to_tree.to_json
  end

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
