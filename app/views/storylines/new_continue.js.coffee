# Return form to write a new line, and hide all subsequent storylines
$('.storyins[data-id=<%= @storyline_next.prev %>]')
	.html('').addClass('ins').show().append("<%= escape_javascript(render 'form_next') %>")
	.parent().parent().parent().nextAll('section').hide()

$('.storyins[data-id=<%= @storyline_next.prev %>]').find('form').submit ->
  $(this).find('input[type=submit]').hide()

# Remove the wrapping <a> to avoid continuously reloading the form
$('a .storyins_wrapper').unwrap()