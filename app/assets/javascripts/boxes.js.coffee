class Boxes
  data: {}

  select2_tags_data: null
  get_select2_tags_data: ->
    return @select2_tags_data if @select2_tags_data
    select2_tags_data = for id, name of $RAJ.data.tags
      id: id, text: name
    @select2_tags_data = select2_tags_data.sort (a,b) ->
      a.text.localeCompare(b.text)

window.Boxes = new Boxes