$('section[data-id=<%= @storyline.id %>] .storytools .votes').html('<%= @storyline.upvotes %>')
$('section[data-id=<%= @storyline.id %>] .storytools a[href*=upvote] img').unwrap()