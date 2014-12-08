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