<% if @continuations.size > 0 %>
$original = $('section[data-id=<%= @storyline.id %>]')
$original.nextAll('section').remove()
$original.after("<%= escape_javascript(render 'continuations') %>") #.remove()
$original.next().click()
<% else %>
notice "No other branches!"
<% end %>