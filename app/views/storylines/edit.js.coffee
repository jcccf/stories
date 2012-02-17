$('.active').click() # Hide any other open forms

$storyline = $('.storyline[data-id=<%= @storyline.id %>]')

$storyline.data('prev-html', $storyline.html())
  .html("<%= escape_javascript(render 'form_edit') %>")
  .find('form').submit ->
    # $(this).append($(this).find('input[type=text]').val())
    $(this).find('input[type=submit]').hide()
    
$(document).click (e) ->
  if not ($(e.target).is(".storyline") or $(e.target).parents().is(".storyline"))
    $storyline.html($storyline.data('prev-html'))