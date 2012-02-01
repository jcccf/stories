ids = @ids_up_to $('form').parent().parent().parent()
location.href = "<%= escape_javascript(storyline_path(@start_id)) %>/" + ids + "," + <%= @storyline.id %>