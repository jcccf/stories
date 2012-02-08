$('body').append("<%= escape_javascript(render 'form') %>")
$('#feedback_url').val(window.location.pathname)