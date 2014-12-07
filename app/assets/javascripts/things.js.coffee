# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $('#tree').tree
    dragAndDrop: true
    autoOpen: 2

$(document).on 'click', '.a-form-commit', ->
  $(@).parents('form').submit()