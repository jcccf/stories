<% if @continuations.size > 1 %>
$original = $('section[data-id=<%= @storyline.id %>]')
$original.nextAll('section').remove()
$original.after("<%= escape_javascript(render 'continuations') %>").remove()
<% else %>
notice "No other branches!"
<% end %>