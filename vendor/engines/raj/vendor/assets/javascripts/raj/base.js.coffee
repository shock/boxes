#= require_tree .
#= require_self

class _RAJ
  constructor: ->

  loadFromJson: ->
    # convert all JSON dates to real Javascript Date instances
    json_datenames = []
    for json_datename in json_datenames
      date = window.RAJ.data[json_datename]
      window.RAJ.data[json_datename] = dateFromString(date) if date? && !$.raj.isDate(date)
    json_timenames = []
    for json_timename in json_timenames
      time = window.RAJ.data[json_timename]
      window.RAJ.data[json_timename] = timeFromString(time) if time? && !$.raj.isDate(time)

  today: new Date

  for_controller_action: (c, a, callback) ->
    $(document).ready ->
      if RAJ.data.c == c && RAJ.data.a == a
        callback()

  data: {}

window.RAJ = new _RAJ

_withErrorReporting = ->
  try
    caller = "#{_withErrorReporting.caller}".split("\n")
    RAJ.data.exception_caller = caller
  catch _e
    if RAJ?.data?.env == 'd'
      throw _e
    else
      RAJ.data.exception_caller = _e.name
  args = Array.prototype.slice.call(arguments, 0)
  reraise = true
  for arg in args
    switch $.type(arg)
      when "boolean"
        reraise = arg
      when "function"
        callback = arg
      when "object"
        jqXHR = arg
  if RAJ?.data?.env == 'd'
    callback.call()
  else
    try
      callback.call()
    catch e
      $.raj.reportJsError(e, jqXHR)
      throw e if reraise

( ($)->
  #  ========================
  #  = RAJ extensions =
  #  ========================

  throw new Error("$.raj is already defined") if $.raj && $.raj?._signature? != 'RAJ'
  $.raj ?= {_signature: 'RAJ'}

  user_show_container = user_hide_callback = user_show_trigger = null

  _ =

    touchDevice: ->
      $('html').hasClass('touch')

    # coerces object to integer
    toInt: (o) ->
      parseInt(''+o)

    # coerces object to float
    toFloat: (o) ->
      parseFloat(''+o)

    # coerces object to String
    toString: (o) ->
      ''+o

    # coerces boolean or boolean String into a boolean
    toBoolean: (o) ->
      return o if $.raj.isBoolean(o)
      return true if o == "true"
      return false if o == "false"
      return null

    # validates object is a non-NaN Number and an integer
    isInt: (o) ->
      return false unless $.type(o) == "number"
      return false unless isNaN(o) == false
      o % 1 == 0

    # validates object is a non-NaN Number
    isNumber: (o) ->
      return false unless $.type(o) == "number"
      isNaN(o) == false

    # validates object is a Date
    isDate: (o) ->
      $.type(o) == "date" && o != "Invalid Date"

    # validates object is a non-empty String
    isString: (o) ->
      $.type(o) == "string"

    # validates object is a Boolean
    isBoolean: (o) ->
      $.type(o) == "boolean"

    # validates object is a Function
    isFunction: (o) ->
      $.type(o) == "function"

    getURLParameter: (name) ->
      regex = RegExp(name + '=' + '(.+?)(&|$)')
      match = regex.exec(location.search) || [0,null]
      decodeURI match[1]

    reportJsError: (error, j, t, e) ->
      data = {}
      try
        data.name = error.name
      catch _error
        data.name = '' + error
      try
        data.message = error.message
      catch _error
        data.message = '' + error
      try
        data.stack = error.stack
      catch _error

      if error.ajax_params
        try
          data.params = JSON.stringify(error.ajax_params)
        catch _error
          data.params = '' + error.ajax_params

      if j
        try
          data.j = JSON.stringify(j)
        catch _error
          data.j = '' + j
      data.t = t if t
      data.e = e if e

      try
        data.dump = JSON.stringify
          RAJ: window.RAJ.data ? {}
          location: window.location.href
          userAgent: navigator.userAgent
      catch _error
        data.dump = {}


      if RAJ?.data?.env == 'd'
        alert("#{JSON.stringify(data)}")
      else
        $.ajax "/system/js_error",
          method: "POST"
          beforeSend: null
          data:
            exception: data

    hide_on_esc_callback: (e) ->
      if e.keyCode == 27
        user_hide_callback()
        $.raj.hide_on_user_intent(e)
        return false

    hide_on_mouseout_click_callback: (e) ->
      # if the target of the click isn't the user_show_container...
      # ... nor a descendant of the user_show_container
      if !user_show_trigger.is(e.target) and !user_show_container.is(e.target) and user_show_container.has(e.target).length is 0
        $.raj.hide_on_user_intent(e)
        return false

    hide_on_touchstart_out_callback: (e) ->
      # if the target of the touch start isn't the user_show_container...
      # ... nor a descendant of the user_show_container
      if !user_show_trigger.is(e.target) and !user_show_container.is(e.target) and user_show_container.has(e.target).length is 0
        $.raj.hide_on_user_intent(e)
        return false

    bind_hide_on_user_intent_events: (trigger, container, callback) ->
      user_show_trigger = $(trigger)
      user_show_container = $(container)
      user_hide_callback = callback
      $(document).on 'keyup', $.raj.hide_on_esc_callback
      $(document).on 'mouseup', $.raj.hide_on_mouseout_click_callback
      # $(document).on 'touchstart', $.raj.hide_on_touchstart_out_callback

    hide_on_user_intent: (e) ->
      e.stopImmediatePropagation()
      $(document).off 'keyup', $.raj.hide_on_esc_callback
      $(document).off 'mouseup', $.raj.hide_on_mouseout_click_callback
      # $(document).off 'touchstart', $.raj.hide_on_touchstart_out_callback
      user_hide_callback()
      user_show_container = user_show_trigger = user_hide_callback = null
      return false

    reloadWindow: ->
      $.raj.blockAllActions()
      window.location.href = window.location.href

    blockAction: (el, blockAll) ->
      ActionBlocker.showBlocker(el, blockAll)

    blockAllActions: ->
      ActionBlocker.showBlocker($('body'), true)

    unblockAllActions: ->
      ActionBlocker.clearBlockers()

    showErrorAlert: (error_message, options={}) ->
      options.backdrop = 'static'
      options.css ?= {}
      options.css.class = "#{options.css.class} error #{options.style}"
      options.no_cancel = true
      if options.redirect_to
        redirect_url = options.redirect_to.split('#')[0]
        options.submit_callback = ->
          setTimeout ->
            window.location.href = redirect_url
          , 100
          $.raj.blockAllActions()
      AlertModal.alert error_message, options

    showSuccessAlert: (message, options={}) ->
      options.css ?= {}
      options.css.class = "#{options.css.class} #{options.style}"
      if options.redirect_to
        options.submit_callback = ->
          setTimeout ->
            window.location.href = options.redirect_to
          , 100
          $.raj.blockAllActions()
      AlertModal.alert message, options

    loadModal: (data) ->

      switch data.load_modal
        when 'zipcode'
          modal = new window.ZipcodesModal data
        when 'user'
          modal = new window.UsersModal data
        when 'customer'
          modal = new window.CustomersModal data
        when 'delivery_location'
          modal = new window.DeliveryLocationsModal data
        when 'payment_method'
          modal = new window.PaymentMethodsModal data
      modal.show() if modal


    # A proxy to jQuery.ajax that adds default success and error
    # handling for standardized RAJ Ajax requests
    handleAjaxRequest: ->
      if $.type(arguments[0]) == "object"
        settings = arguments[0]
        url = settings.url
      else
        settings = arguments[1]
        url = arguments[0]

      settings.cache = false # Disable caching for all Ajax requests.  The default for 'json' is true

      # Explicitly set the Rails format parameter because some clients
      # don't set the request's Accept headers correctly
      format = (settings.dataType ? 'html').toLowerCase()
      if $.raj.isString(settings.data)
        settings.data = "#{settings.data}&format=#{format}"
      else
        settings.data ?= {}
        settings.data.format = format

      # Call the jQuery ajax method with the massaged settings
      jqXHR = $.ajax url, settings

      # Build a memo of the request so we can report the details
      # in an error notification to the application if an error
      # occurs
      url_parts = url.split("?")
      if string_params = url_parts[1]
        url = url_parts[0]
      else
        string_params = ""

      if $.raj.isString(settings.data)
        string_params = "#{string_params}&#{settings.data}"
        data = {}
      else
        data = settings.data || {}

      if string_params.length > 0
        string_data = settings.data
        for param in string_params.split("&")
          continue unless param.match /\=/
          key_value = param.split("=")
          data[unescape(key_value[0])] = key_value[1]

      try
        throw new Error "Ajax #{settings.method || settings.type || "GET"} #{url} format=#{format.toUpperCase()}"
      catch _error
        try
          backtrace = _error.stack.split("\n")
          backtrace.shift()
          backtrace.shift()
          filtered_backtrace = backtrace.filter (e) ->
            !e.match /jQuery/
          _error.stack = filtered_backtrace.join("\n")
          _error.ajax_params = data
        catch e # In case some browsers don't support .stack or .filter

        g_ajax_memo = _error

      error_message = "Something wrong happened while trying to process your request.\n\n\
        Don't worry, it's not your fault.  Our web team has been notified and is \
        probably already working on fixing the problem.  \n\nIf you continue to have \
        problems, please contact customer service.  \n\nClick 'OK' to reload the page."

      # Default success handling for standardized RAJ Ajax requests
      jqXHR.success (data) ->
        $.raj.withErrorReporting $.extend(jqXHR, g_ajax_memo), =>
          if data.success == true
            if data.data?.products
              try
                for product_attrs in data.data.products
                  product = new Product(product_attrs)
                  window.Products.add(product)
              catch e
            if data.data?.load_modal
              $.raj.loadModal data.data
            else if data.alert
              message = data.success_messages.join("\n") if data.success_messages
              message ?= data.html
              options = {}
              options.redirect_to = data.redirect_to
              $.extend(options, {tite: 'Success'}, data.alert)
              $.raj.showSuccessAlert message, options
            else if data.redirect_to
              load_location = data.redirect_to
            else if data.reload
              load_location = window.location.href
            if load_location
              $('.modal').modal('hide')
              $.raj.blockAllActions()
              data.abort_callbacks = true
              window.location.href = load_location
            return
          if data.success == false
            if data.error_messages
              error_message = data.error_messages.join("\n")
            options = {}
            options.redirect_to = window.location.href if data.reload
            $.extend(options, {title: 'Error'}, data.alert)
            $.raj.showErrorAlert error_message, options
            data.abort_callbacks = true

      # Default error handling for standardized RAJ Ajax requests
      jqXHR.error (j,t,e) ->
        if j.readyState == 4
          if RAJ.data.env == 'd' #&& false
            throw g_ajax_memo
          else
            $.raj.showErrorAlert error_message,
              redirect_to: window.location.href
              title: "On no!"
            $.raj.reportJsError(g_ajax_memo, jqXHR, t, e)

    withErrorReporting: _withErrorReporting

    # attribute validation methods
    validateAttr:
      int: (name, o) ->
        throw new Error("#{name} (#{o}) must be an integer Number") unless $.raj.isInt(o)
      boolean: (name, o) ->
        throw new Error("#{name} (#{o}) must be aboolean") unless $.raj.isBoolean(o)
      number: (name, o) ->
        throw new Error("#{name} (#{o}) must be a Number") unless $.raj.isNumber(o)
      string: (name, o) ->
        throw new Error("#{name} (#{o}) must be a String") unless $.raj.isString(o)
        throw new Error("#{name} (#{o}) must be a non-empty String") if o == ""
      date: (name, o) ->
        throw new Error("#{name} (#{o}) must be a valid Date") unless $.raj.isDate(o)
      type: (name, type, o) ->
        throw new Error("#{name} (#{o}) must be a #{type}") unless o instanceof type

  $.extend($.raj, _)

)(jQuery)
