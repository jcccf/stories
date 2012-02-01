ids = @ids_up_to $('form').parent().parent().parent(), true
$('.storyline[data-id=<%= @storyline.id %>]').html('<%= escape_javascript @storyline.line %>')
location.href = "<%= escape_javascript(storyline_path(@start_id)) %>" + "/" + ids + "<%= @rest_ids %>"