# Close popups if click is not on an element which is (within) a popup class
$(document).click (e) ->
  $('.popup').hide() unless $(e.target).parents().hasClass('popup')

# Display an overlay with a custom message that fades in quickly, then fades out
@notice = (message) ->
  $("<div />").addClass("overlay").html("<div>" + message + "</div>").hide().appendTo("body").fadeIn(300).delay(600).fadeOut(1800).queue ->
    $(this).remove()