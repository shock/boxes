class AsyncHtmlLoader
  constructor: (elements) ->
    @elements = elements

  loadContent: (el) =>
    el = $(el)
    path = el.data('raj-url')
    # params = JSON.parse(el.data('raj-params') ? '{}')
    params = el.data('raj-params') ? {}
    jqXHR = $.raj.handleAjaxRequest
      url: path
      type: 'get'
      dataType: 'json'
      data: params
    jqXHR.success (data) =>
      html = data.html
      el.html(html)
    jqXHR.error =>
      el.html("<span>Error loading content.</span>")

  triggerLoad: =>
    self = @
    $(@elements).each ->
      self.loadContent(@)


$.fn.raj_loader = ->
  new AsyncHtmlLoader(this)