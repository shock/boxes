getCaret = (el) ->
  if el.selectionStart
    return el.selectionStart
  else if document.selection
    el.focus()
    r = document.selection.createRange()
    return 0  unless r?
    re = el.createTextRange()
    rc = re.duplicate()
    re.moveToBookmark r.getBookmark()
    rc.setEndPoint "EndToStart", re
    return rc.text.length
  0

split = (val) ->
  val.split RegExp(" \\s*")

extractLast = (term) ->
  split(term).pop()

availableTags = [
  "Action Script"
  "AppleScript"
  "Asp"
  "BASIC"
  "C"
  "C++"
  "Clojure"
  "COBOL"
  "ColdFusion"
  "Erlang"
  "Fortran"
  "Groovy"
  "Haskell"
  "Java"
  "JavaScript"
  "Lisp"
  "Perl"
  "PHP"
  "Python"
  "Ruby"
  "Scala"
  "Scheme"
]


$.fn.autoWordComplete = ->

  faux = undefined
  arrayused = undefined
  calcfaux = undefined
  retresult = undefined
  checkspace = undefined
  contents = $(this)[0]
  carpos = undefined
  fauxpos = undefined
  tier = undefined
  startss = undefined
  endss = undefined

  #mouse caret position dropdown

  initFaux = (el) ->
    widget =  el.parents('.ui-widget')
    faux = widget.siblings('.ui-autocomplete-faux')
    unless faux[0]
      faux = $('<span/>')
      faux.css('display', 'none')
      faux.addClass('ui-autocomplete-faux')
      faux.insertAfter(widget)

  keydownHandler = (event) ->
    if event.keyCode is $.ui.keyCode.TAB
      if $(this).data("uiAutocomplete").menu.activeMenu
        event.preventDefault()
    return

  clickHandler = (event) ->
    carpos = getCaret(contents)
    fauxpos = faux.text().length
    if carpos < fauxpos
      tier = "close"
      $(this).autocomplete "close"
      startss = @selectionStart
      endss = @selectionEnd
      $(this).val $(this).val().replace(RegExp(" *$"), "")
      @setSelectionRange startss, endss
    else
      tier = "open"
    return

  keyupHandler = (event) ->
    calcfaux = faux.text($(this).val())
    fauxpos = faux.text().length
    if RegExp(" $").test(faux.text()) or tier is "close"
      checkspace = "space"
    else
      checkspace = "nospace"
    tier = "open"  if fauxpos <= 1
    carpos = getCaret(contents)
    if carpos < fauxpos
      tier = "close"
      $(this).autocomplete "close"
      startss = @selectionStart
      endss = @selectionEnd
      $(this).val $(this).val().replace(RegExp(" *$"), "")
      @setSelectionRange startss, endss
    else
      tier = "open"
    return

  autocomplete_options =
    minLength: 2
    search: (event, ui) ->
      input = $(event.target)

      # custom minLength
      if checkspace is "space"
        input.autocomplete "close"
        false

    source: (request, response) ->
      term = $.ui.autocomplete.escapeRegex(extractLast(request.term))
      if term.length < 2
        response([])
        return

      processMatches = (availableTags) ->

        # Create two regular expressions, one to find suggestions starting with the user's input:
        startsWithMatcher = new RegExp("^" + term, "i")
        startsWith = $.grep(availableTags, (value) ->
          startsWithMatcher.test value.label or value.value or value
        )

        # ... And another to find suggestions that just contain the user's input:
        containsMatcher = new RegExp(term, "i")
        contains = $.grep(availableTags, (value) ->
          $.inArray(value, startsWith) < 0 and containsMatcher.test(value.label or value.value or value)
        )

        # Supply the widget with an array containing the suggestions that start with the user's input,
        # followed by those that just contain the user's input.
        response startsWith.concat(contains)

      PrefixNameSearch.search(term, processMatches)
      return

    open: (event, ui) ->
      input = $(event.target)
      widget = input.autocomplete("widget")
      style = $.extend(input.css([
        "font"
        "border-left"
        "padding-left"
      ]),
        position: "absolute"
        visibility: "hidden"
        "padding-right": 0
        "border-right": 0
        "white-space": "pre"
      )
      div = $("<div/>")
      pos =
        my: "left top"
        collision: "none"

      offset = -7 # magic number to align the first letter
      # in the text field with the first letter
      # of suggestions
      # depends on how you style the autocomplete box
      widget.css "width", ""
      div.text(input.val().replace(/\S*$/, "")).css(style).insertAfter input
      offset = Math.min(Math.max(offset + div.width(), 0), input.width() - widget.width())
      div.remove()
      pos.at = "left+" + offset + " bottom"
      input.autocomplete "option", "position", pos
      widget.position $.extend(
        of: input
      , pos)
      return

    focus: ->

      # prevent value inserted on focus
      false

    select: (event, ui) ->
      terms = split(@value)
      startss = @selectionStart
      endss = @selectionEnd

      # remove the current input
      terms.pop()

      # add the selected item
      terms.push ui.item.value

      # add placeholder to get the comma-and-space at the end
      terms.push ""
      @setSelectionRange startss, endss
      @value = terms.join(" ")
      calcfaux = faux.text($(this).val())
      if RegExp(" $").test(faux.text())
        checkspace = "space"
      else
        checkspace = "nospace"
      carpos = getCaret(contents)
      fauxpos = faux.text().length
      false

  bindHandlers = (el) ->
    el = $(el)
    initFaux(el)
    el.on "keydown", keydownHandler
    el.click clickHandler
    el.on "keyup", keyupHandler
    el.autocomplete autocomplete_options

  bindHandlers $(this)
