$original = $('section[data-id=<%= @storyline.id %>]')
$original.nextAll('section').remove()
$original.after("<%= escape_javascript(render 'continuations') %>").remove()