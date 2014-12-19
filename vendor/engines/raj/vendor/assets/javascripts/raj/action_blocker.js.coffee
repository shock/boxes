class _ActionBlocker
  constructor: ->
    @blocked = []

  blocker: (top, left, width, height) ->
    spinner = $ '<div/>',
      class: 'action-blocker'
    spinner.css('width', width)
    spinner.css('height', height)
    spinner.css('top', top)
    spinner.css('left', left)
    spinner.css('position', 'absolute')
    blocker = $ '<div/>',
      class: 'action-blocker-wrapper'
    blocker.append(spinner)
    blocker

  showBlocker: (el, whole_screen) =>
    if whole_screen
      $('a').disableClicks()
      overlay = $ '<div/>',
        class: 'action-blocker-overlay'
      overlay.css('width', '100%')
      overlay.css('height', '2000px')
      overlay.css('top', 0)
      overlay.css('left', 0)
      overlay.css('position', 'absolute')
      $('body').append(overlay)
      $('body').css('overflow', 'hidden')

    elem = $(el)
    width = elem.innerWidth()
    height = elem.innerHeight()
    container = _.find elem.parents(), (e) ->
      $(e).css('position') == 'relative'
    container ?= $("body")
    container = $(container)
    container_position = container.offset()
    position = elem.offset()
    left = position.left - container_position.left
    top = position.top - container_position.top
    blocker = @blocker(top, left, width, height)
    container.append(blocker)
    elem.data('blocker', blocker)
    blocker

  hideBlocker: (el) =>
    elem = $(el)
    blocker = elem.data('blocker')
    elem.data('blocker', null)
    blocker.remove() if blocker

  blockAction: ->

  withBlocking: ->

  clearBlockers: ->
    $('.action-blocker-wrapper').remove()
    $('.action-blocker-overlay').fadeOut(200)
    $('.please-wait-div').fadeOut(200)
    $('body').css('overflow', 'visible')
    $('a').enableClicks()

$.fn.showBlocker = (opts) ->
  this.each ->
    ActionBlocker.showBlocker(this, opts)


$.fn.hideBlocker = ->
  this.each ->
    ActionBlocker.hideBlocker(this)

window.ActionBlocker = new _ActionBlocker

please_wait_timer = null

$(document).on 'click', '.action-blocker-overlay, .action-blocker', (event) ->
  clearTimeout please_wait_timer

  $(".please-wait-div").css({
    top: event.pageY + 10,
    left: event.pageX - 70
  }).fadeIn(200);

  please_wait_timer = setTimeout ->
    $('.please-wait-div').fadeOut(700)
  , 2500

  false