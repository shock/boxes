module TagsHelper

  # returns HTML <option> list to embed within a select tag
  def options_for_tags_select(options = {})
    options[:selected] ||= []
    raise ":selected option must be an array" unless options[:selected].is_a?(Array)
    options[:selected].map!(&:to_i)
    tags = Tag.order(:name).all
    select_options = []
    tags.each do |tag|
      # select_options << %Q{<optgroup label="#{parent.name}">}
      # parent.descendants.each do |tag|
        selected = options[:selected].grep(tag.id).any? ? "selected" : nil
        # name = "#{tag.parent.name} - #{tag.name}"
        name = "#{tag.name}"
        select_options << %Q{<option value="#{tag.id}" #{selected}>#{name}</option>}
      # end
      # select_options << %Q{</optgroup>}
    end
    select_options.join("\n").html_safe
  end
end
