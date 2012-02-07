# Close popups if click is not on an element which is (within) a popup class
$(document).click (e) ->
  $('.popup').hide() unless $(e.target).parents().hasClass('popup')