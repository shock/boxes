# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

class _Tags
  setupSelect2Tags: ->
    $("div.tag-select input").each ->
      el = $(this)
      select2_data = Boxes.get_select2_tags_data()
      placeholder = "Click here to select tags"
      el.select2
        placeholder: placeholder
        allowClear: true
        minimumInputLength: 0
        minimumResultsForSearch: -1
        multiple: true
        data: select2_data

window.Tags = new _Tags