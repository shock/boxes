# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.
#
#= require jquery
#= require jquery_ujs
#= require bootstrap-sprockets
#= require turbolinks
#= require jquery-ui
#= require jquery-cookie
#= require tree.jquery
#= require select2
#= require raj/base
#= require_tree .

Turbolinks.enableTransitionCache();

setTimeout ->
  $('.alert').fadeOut(1000)
, 3000

statusMsgShown = false
window.statusMsg = (msg) ->
  unless statusMsgShown
    statusMsgShown = true
    div = $('<div id="status-msg"></div>')
    div.css
      position: 'fixed'
      top: 0
      right: 0
      background: 'white'
      color: 'black'
    div.appendTo('body')
  el = $('#status-msg')
  el.html(msg)

$ ->
  # prevent touch to click delay on mobile devices
  Origami.fastclick(document.body)

$(document).on 'click', '.f-submit', ->
  form = $(this).parents('form')
  form.submit()
  false

$(document).on 'click', '#back-button', ->
  history.back()
  false

$(document).on 'click', '#forward-button', ->
  history.forward()
  false

$(document).on "ready page:load", ->
  raj_loader = $('.raj-loader').raj_loader()
  raj_loader.triggerLoad()
  window.raj_mt_loader = $('.raj-mt-loader').raj_loader()
  window.raj_mt_loader.triggerLoad()
