# Change window to a variable to namespace these functions
root = window

((root) ->
  # Date Utils
  #-----------------------------------------------------------------------------

  root.dayIDs = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
  root.vMINUTE_MS = 60000
  root.HOUR_MS = 3600000
  root.DAY_MS = 86400000
  root.WEEK_MS = DAY_MS * 7

  root.addMonths = (d, n, keepTime) -> # prevents day overflow/underflow
    if +d # prevent infinite looping on invalid dates
      m = d.getMonth() + n
      check = cloneDate(d)
      check.setDate 1
      check.setMonth m
      d.setMonth m
      clearTime d  unless keepTime
      d.setDate d.getDate() + ((if d < check then 1 else -1))  until d.getMonth() is check.getMonth()
    d

  root.addDays = (d, n, keepTime) -> # deals with daylight savings
    if +d
      dd = d.getDate() + n
      check = cloneDate(d)
      check.setHours 9 # set to middle of day
      check.setDate dd
      d.setDate dd
      clearTime d  unless keepTime
      fixDate d, check
    d

  root.addWeeks = (d, n, keepTime) -> # deals with daylight savings
    addDays d, n * 7, keepTime

  root.incDay = (d, keepTime) -> # deals with daylight savings
    addDays d, 1, keepTime

  root.decDay = (d, keepTime) -> # deals with daylight savings
    addDays d, -1, keepTime

  root.fixDate = (d, check) -> # force d to be on check's YMD, for daylight savings purposes
    # prevent infinite looping on invalid dates
    d.setTime +d + ((if d < check then 1 else -1)) * HOUR_MS  until d.getDate() is check.getDate()  if +d

  root.addMinutes = (d, n) ->
    d.setMinutes d.getMinutes() + n
    d

  root.addSeconds = (d, n) ->
    d.setSeconds d.getSeconds() + n
    d

  root.clearTime = (d) ->
    d.setHours 0
    d.setMinutes 0
    d.setSeconds 0
    d.setMilliseconds 0
    d

  root.cloneDate = (d, dontKeepTime) ->
    return clearTime(new Date(+d))  if dontKeepTime
    new Date(+d)

  root.today = ->
    clearTime new Date

  root.tomorrow = ->
    addDays(clearTime(new Date), 1)

  # Returns the next available date falling on the specified day of the week
  # +wday+ Integer day of the week (Sunday = 0)
  # +start_date+ Date to start searching from.
  root.nextDateForDotw = (wday, start_date) ->
    date = cloneDate(start_date)
    i = 0
    while i < 7
      break  if date.getDay() is wday
      incDay date
      i++
    date

  # returns the Sunday of the week containing date
  root.weekStartForDate = (date) ->
    date = cloneDate(date)
    addDays date, -date.getDay()
    date

  root.dateFromString = (string) ->
    comps = string.split("-")
    throw ("Invalid date string: '" + string + "'.  Must be 'YYYY-MM-DD'")  unless comps.length is 3
    new Date(comps[0], comps[1] - 1, comps[2])

  # Accepts a date string in the form of "YYYY-MM-DD" or Date object and ensures that the returned result
  # is a unique Date object.  If the object passed in is a Date, then a clone of it is returned.

  root.coerceNewDate = (datish) ->
    unless datish.constructor is Date
      dateFromString datish
    else
      cloneDate datish

  root.timeFromString = (string) ->
    new Date(string)

  root.utcDate = (date) ->
    Date.UTC date.getFullYear(), date.getMonth(), date.getDate()

  root.equivalentDates = (date1, date2) ->
    return true  if not date1? and not date2?
    return false  if not date1? or not date2?
    date1.getTime() is date2.getTime()

  # returns the difference in days from date1 to date 2.  clears time, timezone, and daylight savings before calculating
  # if date2 is past date1, a positive value is returned
  # a and b are javascript Date objects
  root.dateDiffInDays = (a, b) ->
    _MS_PER_DAY = 1000 * 60 * 60 * 24

    # Discard the time and time-zone information.
    utc1 = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate())
    utc2 = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate())
    Math.floor (utc2 - utc1) / _MS_PER_DAY

  root.addYears = (d, n, keepTime) ->
    d.setFullYear d.getFullYear() + n
    clearTime d  unless keepTime
    d

  root.dateToString = (date) ->
    "#{date.getFullYear()}-#{date.getMonth() + 1}-#{date.getDate()}"
)(root)