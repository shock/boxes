# Helper to trigger Google Universal Analytics page views and events.
# Note, you must have GA's Javascript snippet installed in your layout

class window._Analytics
  constructor: (options={}) ->
    {@ga_queue, @uga_tracker} = options

  _ga_queue: ->
    window[@ga_queue]

  _uga_tracker: ->
    window[@uga_tracker]

  push: (options) ->
    ga_queue = @_ga_queue()
    ga_queue.push(options) if ga_queue

  send: (options) ->
    uga_tracker = @_uga_tracker()
    uga_tracker('send', options) if uga_tracker

  trackEvent: (options) ->
    @push ['_trackEvent', options.category, options.action, options.label, options.value]
    @send
      hitType: 'event'
      eventCategory: options.category
      eventAction: options.action
      eventLabel: options.label
      eventValue: options.value

  trackPageView: (options) ->
    @push ['_trackPageview', options.page]
    @send
      hitType: 'pageview'
      page: options.page
      title: options.title

  trackFooEvent: (foo_value) ->
    options =
      action: "foo"
      value: $.g.toInt(foo_value)
    options.category = 'EventCategory'
    @trackEvent(options)