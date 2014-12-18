# Javascript native object extensions

# tests for presence of element in an array
# if a function equal(a,b) is passesd, it will be used to test for equality instead of ===

Array::hasElement = (e, equal) ->
  if typeof equal == 'function'
    return true for _ in this when equal _, e
  else
    return true for e in this when _ == e

# removes the element e from an array
# if a function equal(a,b) is passed, it will be used to test for equality, otherwise Array::indexOf(e) is used
Array::removeIfEqual = (e, equal) ->
  try
    if typeof equal == 'function'
      i = 0
      while i < @.length
        _e = @[i]
        if equal(_e,e)
          @[i..i] = []
        else
          i++
    else
      @[t..t] = [] if (t = @indexOf(e)) > -1
  catch error

unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)
