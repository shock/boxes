$(document).on 'hidden.bs.modal', '.modal', ->
  $(this).find('.modal-content').html('')
  $(this).removeData('bs.modal')
  $('a:focus').blur();
