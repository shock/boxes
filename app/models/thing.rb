class Thing < ActiveRecord::Base
  acts_as_nested_set depth_column: :tree_depth
  include PrefixNameSearch

  has_many :thing_tags
  has_many :tags, through: :thing_tags

  ROOT_NAME = "<none>"

  def self.root
    find_or_create_by(name: ROOT_NAME, parent_id: nil)
  end

  def self.world
    world = find_by(name:"The World")
    return world if world
    world = create(name: "The World", parent_id: self.root.id)
    world.move_to_child_of(self.root)
  end

  def self.orphaned
    orphaned = find_by(name:"Orphaned")
    return orphaned if orphaned
    orphaned = create(name: "Orphaned", description: "Objects whose parent was destroyed.", parent_id: self.world.id)
    orphaned.move_to_child_of(self.world)
  end

  before_save :default_root, :normalize_name
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

  def label
    "#{name} (#{children.count})"
  end

  def json_ltree_builder( json, children_to_open=[] )
    json.id id
    json.label label
    children = self.children
    unless children.empty?
      index = children_to_open.index(id)
      load_children_on_demand = index == nil
      # load_children_on_demand ||= (index == children_to_open.length - 1)
      json.load_on_demand load_children_on_demand
      unless load_children_on_demand
        json.children do
          json.array! children do |child|
            child.json_ltree_builder( json, children_to_open )
          end
        end
      end
    end
    json
  end

  def children_to_builder
    Jbuilder.new do |json|
      json.array! children do |thing|
        thing.json_ltree_builder( json, [] )
      end
    end
  end

  def parents_to_builder
    path = self.self_and_ancestors
    path_ids = path.map(&:id)
    Jbuilder.new do |json|
      json.array! path.first.children do |thing|
        thing.json_ltree_builder( json, path_ids )
      end
    end

  end

  def to_builder
    Jbuilder.new do |json|
      json.array! [self] do |thing|
        thing.json_ltree_builder( json, false )
      end
    end
  end

  # convert first character of each word to upper case
  # doesn't modify subsequent characters of the words
  def normalize_name
    self.name = self.name.squish
    self.name = self.name.split(/\s+/).map do |word|
      first_letter = word.slice(0,1)
      first_letter = first_letter.capitalize
      suffix = word.slice(1,word.length-1)
      "#{first_letter}#{suffix}"
    end.join(" ")
  end

  def normalize_name!
    self.normalize_name
    self.save!
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
