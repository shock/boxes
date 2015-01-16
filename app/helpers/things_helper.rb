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
  def icon_move; 'arrow-circle-o-right'; end

  def thing_label(thing)
    "#{thing.name} <i class='c-count d-#{thing.id}-contained'>#{thing.children.count}</i>".html_safe
  end

  def thing_actions(thing)
    id = thing.id
    %Q{
      <em class="thing-actions action">
        <a title="Toggle Marked" class="#{id}_marked" data-remote="true" href="/things/#{id}/toggle_marked">
          <i class="fa fa-check-square dimmed #{"marked" if thing.marked}"></i>
        </a><a title="Edit #{thing.name}" class="a-edit-thing" href="/things/#{id}/edit">
          <i class="fa fa-pencil-square success"></i>
        </a><a title="Add Contained Thing" class="a-new-thing" href="/things/new?parent_id=#{id}">
          <i class="fa fa-cube primary"></i>
        </a>
      </em>
      <em class="show-actions">
        <a href="#"><i class="fa fa-bars"></i></a>
      </em>
    }
  end

  def json_ltree_builder( json, thing, children_to_open=[] )
    json.id thing.id
    actions = thing_actions(thing)
    # json.label "#{thing_label(thing)} #{actions}"
    json.label "#{thing.name} #{actions}"
    children = container_sort(thing.children)
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

  def tag_html(tag_name)
    "<span>•</span>#{tag_name}".html_safe
  end

  # primary sort of containers first, secondary alpha sort
  def container_sort(things)
    things = things.sort do |a,b|
      if a.children.length > 0
        if b.children.length > 0
          a.name < b.name ? -1 : 1
        else
          -1
        end
      else
        if b.children.length > 0
          1
        else
          a.name < b.name ? -1 : 1
        end
      end
    end
    things
  end
end