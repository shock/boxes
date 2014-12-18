class _RAJ
  constructor: ->

  loadFromJson: ->
    # convert all JSON dates to real Javascript Date instances
    json_datenames = []
    for json_datename in json_datenames
      date = window.$RAJ.data[json_datename]
      window.$RAJ.data[json_datename] = dateFromString(date) if date? && !$.g.isDate(date)
    json_timenames = []
    for json_timename in json_timenames
      time = window.$RAJ.data[json_timename]
      window.$RAJ.data[json_timename] = timeFromString(time) if time? && !$.g.isDate(time)

  today: new Date

  for_controller_action: (c, a, callback) ->
    $(document).ready ->
      if $RAJ.data.c == c && $RAJ.data.a == a
        callback()

window.$RAJ = new _RAJ
