class Tag < ActiveRecord::Base
  include PrefixNameSearch

  has_many :thing_tags, dependent: :destroy
  has_many :things, through: :thing_tags
  before_save :normalize_name

  audited

  def client_attributes
    {
      name: name,
      id: id
    }
  end

private
  def normalize_name
    self.name = name.squish.downcase
  end
end
