# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  tree = $('#tree')
  tree.tree
    dragAndDrop: true
    autoOpen: 1000
    useContextMenu: false
    selectable: false

  tree.bind 'tree.click', (e) ->
    # e.preventDefault()
    node = e.node
    id = node.id
    window.location = "/things/#{id}"

$(document).on 'shown.bs.modal', '.modal', ->
  $('#thing_name').autoWordComplete()
  $('#thing_name').putCursorAtEnd()
  $('#show-more').click ->
    $('#more').toggle();
    $(this).hide();
    false

  modal = $(this)
  $(".tag-select select").each ->
    el = $(this)
    # select2_data = Greenling.get_select2_product_class_data()
    placeholder = "Click here to add tags"
    # el.select2
    #   placeholder: placeholder
    #   allowClear: true
    #   minimumInputLength: 0
    #   minimumResultsForSearch: -1
    #   multiple: true
    #   # data: select2_data
