module ThingsHelper
  # def icon_marked; 'check-square'; end
  # def icon_edit; 'pencil-square'; end
  # def icon_add; 'plus-square'; end
  # def icon_delete; 'minus-square'; end
  def icon_marked; 'check-square'; end
  def icon_edit; 'pencil-square'; end
  def icon_add; 'cube'; end
  def icon_delete; 'minus-square'; end
  def icon_home; 'home'; end

  def thing_label(thing)
    "#{thing.name} <i class='c-count d-#{thing.id}-contained'>#{thing.children.count}</i>".html_safe
  end

  def json_ltree_builder( json, thing, children_to_open=[] )
    json.id thing.id
    json.label thing_label(thing)
    children = thing.children
    unless children.empty?
      index = children_to_open.index(thing.id)
      load_children_on_demand = index == nil
      # load_children_on_demand ||= (index == children_to_open.length - 1)
      json.load_on_demand load_children_on_demand
      unless load_children_on_demand
        json.children do
          json.array! children do |child|
            json_ltree_builder( json, child, children_to_open )
          end
        end
      end
    end
    json
  end

end