( ($)->

  #  ==============================
  #  = jQuery selector extensions =
  #  ==============================

  # Cross-browser function for putting the cursor at the end of
  # an input.
  $.fn.putCursorAtEnd = ->
    @each ->
      $(this).focus()

      # If this function exists...
      if @setSelectionRange

        # ... then use it
        # (Doesn't work in IE)

        # Double the length because Opera is inconsistent about whether a carriage return is one character or two. Sigh.
        len = $(this).val().length * 2
        @setSelectionRange len, len
      else

        # ... otherwise replace the contents with itself
        # (Doesn't work in Google Chrome)
        $(this).val $(this).val()

      # Scroll to the bottom, in case we're in a tall textarea
      # (Necessary for Firefox and Google Chrome)
      @scrollTop = 999999
      return

  $.fn.focusFirstInput = ->
    input = this.find("input[type='text']")[0]
    input && $(input).putCursorAtEnd()
    this

  # gets form fields as a Javascript Object
  $.fn.getObject = (name_space) ->
    arr = this.serializeArray()
    paramObj = {}
    for kv in arr
      name = kv.name
      if name_space
        pattern = ///^#{name_space}\[(.*)\](.*)///
        if name
          if matches = name.match(pattern)
            name = "#{matches[1]}#{matches[2]}"
          else
            name = null
      if name
        pattern = ///(.*)\[\]///
        if matches = name.match(pattern)
          name = matches[1]
          paramObj[name] ?= []
        if paramObj.hasOwnProperty(name)
          paramObj[name] = $.makeArray(paramObj[name])
          paramObj[name].push kv.value
        else
          paramObj[name] = kv.value
    paramObj

  $.fn.ismouseover = (x,y) ->
    result = false
    @.each ->
      elem = $(this)
      offset = elem.offset()
      result = offset.left <= x and offset.left + elem.outerWidth() > x and offset.top <= y and offset.top + elem.outerHeight() > y
      return
    result

  # auto remove prompts from form elements on focus, and removes the prompt_class
  # On blur, restores the prompt if the form element is empty and adds the prompt_class
  # if prompt_class is not supplied, the default is 'form-prompt'
  # the prompt is pulled from the 'data-prompt' attribute of the element
  $.fn.removeFormPrompt = (prompt_class) ->
    prompt_class ?= 'form-prompt'
    this.each ->
      el = $(this)
      prompt = el.attr('data-prompt')
      if el.val() == prompt
        el.val('')
        el.removeClass(prompt_class)

  $.fn.restoreFormPrompt = (prompt_class) ->
    prompt_class ?= 'form-prompt'
    this.each ->
      el = $(this)
      prompt = el.attr('data-prompt')
      if $.trim(el.val()) == ''
        el.val(prompt)
        el.addClass(prompt_class)
      else
        el.removeClass(prompt_class)

  $.fn.formPrompt = (prompt_class) ->
    prompt_class ?= 'form-prompt'
    this.each ->
      el = $(this)
      el.on 'focus', ->
        el.removeFormPrompt(prompt_class)
      .on 'blur', ->
        el.restoreFormPrompt(prompt_class)
      .trigger('blur')

  # auto selects form element contents on focus
  $.fn.autoSelectOnFocus = (prompt_class) ->
    prompt_class ?= 'auto-select'
    this.each ->
      el = $(this)
      el.on 'focus', ->
        setTimeout ->
          el.select()
        0

  nullClickHandler = ->
    return false

  $.fn.disableClicks = ->
    $(this).on 'click', nullClickHandler

  $.fn.enableClicks = ->
    $(this).off 'click', nullClickHandler

)(jQuery)
