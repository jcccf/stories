ids_up_to = ($section, exclude = false) ->
  last_id = $section.attr('data-id')
  rest_ids = ""
  if $('section:eq(0)').attr('data-id') != last_id
    $('section:not(:first)').each ->
      curr = $(this).attr('data-id')
      if curr != last_id
        rest_ids += curr + ","
      else
        return false
  rest_ids += last_id + ',' unless exclude or $('section:eq(0)').attr('data-id') == last_id
  return rest_ids

ids = ids_up_to $('form').parent().parent().parent()
location.href = "<%= escape_javascript(storyline_path(@start_id)) %>/" + ids + <%= @storyline.id %>