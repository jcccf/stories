ids_up_to = ($section, exclude = false) ->
  last_id = $section.attr('data-id')
  rest_ids = ""
  is_first_also_last = ($('section:eq(0)').attr('data-id') == last_id)
  if not is_first_also_last 
    $('section:not(:first)').each ->
      curr = $(this).attr('data-id')
      if curr != last_id
        rest_ids += curr + ","
      else
        return false
  rest_ids += last_id + ',' unless exclude or is_first_also_last 
  
  real_rest = "<%= @rest_ids %>"
  if $('section:eq(0)').attr('data-id') == real_rest.split(',')[0]
    real_rest = real_rest.split(',')
    real_rest.shift()
    real_rest = real_rest.join(',')
  rest_ids += real_rest
  
  return rest_ids

ids = ids_up_to $('form').parent().parent().parent(), true
$('.storyline[data-id=<%= @storyline.id %>]').html('<%= escape_javascript @storyline.line %>')
location.href = "<%= escape_javascript(storyline_path(@start_id)) %>" + "/" + ids