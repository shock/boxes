class Audit < ActiveRecord::Base
  serialize :audited_changes
end