# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

# Helper to get all ids of storylines on a page up to the given section, excluding the very first one
@ids_up_to = ($section, exclude = false) ->
  last_id = $section.find('.storyid').text()
  rest_ids = ""
  $('section:not(:first)').each ->
    curr = $(this).attr('data-id')
    if curr != last_id
      rest_ids += curr + ","
    else
      return false
  rest_ids += last_id unless exclude
  return rest_ids

# Fade out rest of story when hovering over a separating line
$ ->
  $('.storyins_wrapper').hover (-> 
    $(this).parent().parent().nextAll().css("opacity", "0.1") #.animate({opacity: 0.25}, 200)
  ), (-> 
    $(this).parent().parent().nextAll().css("opacity", "1.0") #.animate({opacity: 1}, 100)
  )

# Clicking the pen icon results in a field becoming editable as well
$ ->
  $('.storyline_pen').click ->
    $(this).parent().parent().find('.best_in_place').click()