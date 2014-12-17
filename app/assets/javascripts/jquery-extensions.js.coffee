# Cross-browser function for putting the cursor at the end of
# an input.
jQuery.fn.putCursorAtEnd = ->
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

jQuery.fn.focusFirstInput = ->
  input = this.find("input[type='text']")[0]
  input && $(input).putCursorAtEnd()
  this
