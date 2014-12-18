# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $tree = $('#tree')
  $tree.tree
    dragAndDrop: true
    autoOpen: 1000
    useContextMenu: false
    selectable: true

  $tree.bind 'tree.click', (e) ->
    isOpen = (node) ->
      for open_id in $tree.tree('getState')['open_nodes']
        return true if open_id == node.id
      return false

    node = e.node

    if selected_node = $tree.tree('getSelectedNode')
      if selected_node.id == node.id
        window.location = "/things/#{node.id}"
        return

    if parent = node.parent
      for sibling in parent.children
        continue if sibling.id == node.id
        $tree.tree('toggle', sibling) if isOpen(sibling)

    $tree.tree('toggle', node) unless isOpen(node)

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
