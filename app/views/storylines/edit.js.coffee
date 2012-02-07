$('.storyline[data-id=<%= @storyline.id %>]')
  .html("<%= escape_javascript(render 'form_edit') %>")
  .find('form').submit ->
    # $(this).append($(this).find('input[type=text]').val())
    $(this).find('input[type=submit]').hide()