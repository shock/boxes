
class window.GeneralModal
  selector: '.modal.general.template'
  modal: null

  submit_handler: =>
    @options.submit_callback() if @options.submit_callback
    @hide() unless @options.dont_hide_on_submit
    false

  cancel_handler: =>
    if @options.no_cancel
      @options.submit_callback() if @options.submit_callback
      @hide()
    else
      @options.cancel_callback() if @options.cancel_callback
      @hide()
    false

  keyup_handler: (e) =>
    if e.keyCode == 13
      @submit_handler()
      return false
    if e.keyCode == 27
      @cancel_handler()
      return false
    return true

  updateCss: (css_obj) ->
    for k,v of css_obj
      if k = 'class'
        for klass in v.split(/\s+/)
          @modal.addClass(klass)
      else
        @modal.css(k, v)


  constructor: (options={}) ->
    @options = options

    @modal = $(@selector).clone()
    @modal.removeClass('template')

    if @options.actions == false
      @modal.find('.popup-actions').remove()

    if @content_or_callback
      if $.type(@content_or_callback) == "function"
        @content = @content_or_callback()
      else
        @content = @content_or_callback

    @updateCss(options.css)

    if @options.modal_header == false
      @modal.find('.modal-header').remove()

    options.show = false
    @modal.modal options

  loadContent: (content) ->
    body_content = @modal.find('.modal-body')
    body_content.html(content ? @content)
    submit_button = @modal.find('.popup-submit')
    submit_button.html(@options.submit) if @options.submit
    submit_button.click @submit_handler

    if @options.cancel
      cancel = @modal.find('.popup-cancel')
      cancel.show()
      cancel.click @cancel_handler


    if @options.title
      @setModalTitle(@options.title)
    else
      @modal.find('.popup-header').remove()

    @modal.find('.field_with_errors input').focus()


  setModalTitle: (title) ->
    @modal.find('.popup-header').html("<h5>#{title}</h5>")
    @modal.find('.modal-header .modal-title').html(title)

  show: ->
    $('.modal').modal('hide')
    @loadContent(@content)
    ActionBlocker.clearBlockers()
    @modal.modal('show')
    $(document).on 'keyup', @keyup_handler
    @modal.on 'hidden', ->
      $(document).off 'keyup', @keyup_handler

  hide: ->
    @modal.modal('hide')


class window.AlertModal extends GeneralModal
  constructor: (message, options={}) ->
    options.css ?= {}
    options.css.class = "#{options.css.class} modal-alert"
    options.submit = "OK"
    options.title ?= "Alert"
    sections = message.split /\n/
    paragraphs = sections.map (section) -> "<p>#{section}</p>"
    @content_or_callback = paragraphs.join("\n")
    super options

AlertModal.alert = (message, options={}) ->
  options.backdrop = false unless options.backdrop
  modal = new AlertModal(message, options)
  modal.show()

class window.ConfirmModal extends AlertModal
  constructor: (message, options={}) ->
    options.backdrop = 'static'
    options.cancel ?= true
    options.keyboard = true
    options.title ?= "Confirm"
    options.checkbox ?= false
    super message, options

ConfirmModal.confirm = (message, confirm_callback, cancel_callback, options={}) ->
  options.submit_callback = confirm_callback
  options.cancel_callback = cancel_callback
  modal = new ConfirmModal message, options
  modal.show()

# window.confirm = ConfirmModal.confirm
# window.alert = AlertModal.alert