class Thing < ActiveRecord::Base
  acts_as_nested_set depth_column: :tree_depth
  include PrefixNameSearch
  include ThingsHelper

  audited
  has_associated_audits

  has_many :thing_tags, dependent: :destroy
  has_many :tags, through: :thing_tags

  ROOT_NAME = "<none>"

  cattr_accessor :world_name
  self.world_name = "The World"

  attr :override_destroy

  def self.root
    find_or_create_by(name: ROOT_NAME, parent_id: nil)
  end

  def self.world
    world = find_by(name: world_name)
    return world if world
    world = create(name: world_name, parent_id: self.root.id)
    world.move_to_child_of(self.root)
  end

  def self.orphaned
    orphaned = find_by(name:"Orphaned")
    return orphaned if orphaned
    orphaned = create(name: "Orphaned", description: "Objects whose parent was destroyed.", parent_id: self.world.id)
    orphaned.move_to_child_of(self.world)
  end

  before_save :default_root, :normalize_name, :protect_world
  after_save :move_to_parent, :touch_ancestors
  before_update :protect_world
  before_destroy :protect_world, :protect_parents, :touch_self, :touch_ancestors

  include FlagShihTzu
  include HstorePropertiesConcern

  validates :name, presence: true

  alias :container :parent

  def contained
    container_sort(self.children)
  end

  hstore_attr :width, :default => 0
  hstore_attr :height, :default => 0
  hstore_attr :depth, :default => 0
  hstore_attr :weight, :default => 0

  def num_contained
    children.count
  end

  has_flags 1 => :marked

  # def label
  #   "#{name} (#{children.count})"
  # end

  # def children_to_builder
  #   Jbuilder.new do |json|
  #     json.array! children do |thing|
  #       thing.json_ltree_builder( json, [] )
  #     end
  #   end
  # end

  # def parents_to_builder
  #   path = self.self_and_ancestors
  #   path_ids = path.map(&:id)
  #   Jbuilder.new do |json|
  #     json.array! path.first.children do |thing|
  #       thing.json_ltree_builder( json, path_ids )
  #     end
  #   end

  # end

  # def to_builder
  #   Jbuilder.new do |json|
  #     json.array! [self] do |thing|
  #       thing.json_ltree_builder( json, false )
  #     end
  #   end
  # end

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

  def touch_self
    self.updated_at = Time.now
  end

  def touch_ancestors
    self.ancestors.update_all(updated_at: self.updated_at)
    # this next line has to be here for the destroy case because acts_as_nested_set
    # destroys the parent relationship from the ancestors before our hook is called!
    Thing.where(id: self.parent_id).update_all(updated_at: self.updated_at) if self.parent_id
  end

  def protect_world
    raise "Can't modify The World!" if self.id == self.class.world.id
  end

  def protect_parents
    raise "Can't destroy a parent without override." unless self.children.empty? || self.override_destroy
  end
end
