module PrefixNameSearch
  extend ActiveSupport::Concern

  module ClassMethods
    def find_by_prefix(prefix)
      matches = self.where("name iLIKE '#{prefix}%'").all
      matches = matches.map{|e| e.name}
      if prefix.downcase != prefix
        matches = matches.map{|e| e.gsub(/#{prefix}/i, prefix)} + matches
      end
      matches
    end
  end
end