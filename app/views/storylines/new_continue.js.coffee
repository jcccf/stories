$('.active').click() # Hide any other open forms

# Return form to write a new line, and hide all subsequent storylines
<% if @hide_rest %>
$('.storyins[data-id=<%= @storyline_next.prev %>]')
	.html('').addClass('ins').show().append("<%= escape_javascript(render 'form_next') %>")
	.parents('section').nextAll('section').hide()
<% else %>
$('.storyins[data-id=<%= @storyline_next.prev %>]')
	.html('').addClass('ins').show().append("<%= escape_javascript(render 'form_next') %>")
<% end %>

$(document).click (e) ->
  if not ($(e.target).is(".storyins") or $(e.target).parents().is(".storyins"))
    $('.storyins[data-id=<%= @storyline_next.prev %>]').html('')
    $('section').show()

$('.storyins[data-id=<%= @storyline_next.prev %>]').find('form').submit ->
  $(this).find('input[type=submit]').hide()