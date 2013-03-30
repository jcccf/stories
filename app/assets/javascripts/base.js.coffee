# Close popups if click is not on an element which is (within) a popup class
$(document).click (e) ->
  $('.popup').hide() unless $(e.target).parents().hasClass('popup')

# Display an overlay with a custom message that fades in quickly, then fades out
@notice = (message) ->
  $("<div />").addClass("overlay").html("<div>" + message + "</div>").hide().appendTo("body").fadeIn(300).delay(600).fadeOut(1800).queue ->
    $(this).remove()

# Show a tooltip with a custom message when hovering on specific icons
$ ->
  $('body').on 'mouseenter', '[data-tooltip]', ->
    pos = $(this).offset()
    widthoffset = $(this).width()/2
    $('#tooltip').css('top', (pos.top-40)+"px").css('left', (pos.left-21+widthoffset)+"px").show()
    $('#tooltip_text').html $(this).attr('data-tooltip')

  $('body').on 'mouseleave', '[data-tooltip]', ->
    $('#tooltip').hide()

  $('.must_login').on 'click', ->
    notice "Sorry, but you can only do this if you log in!"
