# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'shown.bs.modal', '.modal', ->
  $('#thing_name').autoWordComplete()
  $('#thing_name').putCursorAtEnd()
  $('#show-more').click ->
    $('#more').toggle()
    $(this).hide()
    false

  modal = $(this)
  $("div.tag-select input").each ->
    el = $(this)
    select2_data = Boxes.get_select2_tags_data()
    placeholder = "Click here to add tags"
    el.select2
      placeholder: placeholder
      allowClear: true
      minimumInputLength: 0
      minimumResultsForSearch: -1
      multiple: true
      data: select2_data

  # $("select#thing_parent_id").each ->
  #   el = $(this)
  #   # select2_data = Boxes.get_select2_tags_data()
  #   # placeholder = "Click here to add tags"
  #   el.select2
  #     # placeholder: placeholder
  #     allowClear: false
  #     minimumInputLength: 0
  #     minimumResultsForSearch: -1
  #     # multiple: true
  #     # data: select2_data

$('a.a-move-to').click ->
  $tree = $('#tree')
  if selected_node = $tree.tree('getSelectedNode')
    container_id = selected_node.id
    $.ajax
      type: 'post'
      url: "/marked_things/move"
      data:
        parent_id: container_id
      success: ->
        window.location = window.location
  else
    alert("Choose a container using the tree control to move selected objects inside of it.")
  return false

