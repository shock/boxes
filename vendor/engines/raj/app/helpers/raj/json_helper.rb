module Raj::JsonHelper
  extend ActiveSupport::Concern
  included do
    before_filter :update_raj_json if respond_to?(:before_filter)
  end

private

  def update_raj_json(hash=nil)
    @raj_json ||= {
      :c => params[:controller],
      :a => params[:action]
    }
    hash ||= {}
    client_hash = @raj_json
    hash.each do |k,v|
      v = v.client_attributes rescue v
      v = v.map(&:client_attributes) rescue v
      if client_hash[k].is_a?(Array) && v.is_a?(Array)
        client_hash[k] = (client_hash[k] + v).uniq
      else
        client_hash[k] = v
      end
    end
  end

  def render_raj_json(*args)
    update_raj_json(args.shift)
    update_raj_json(
      :env => Rails.env.slice(0,1),
    )
    render :partial => 'raj/raj_json'
  end

end