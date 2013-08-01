# convert Google Maps into an AMD module
define "gmap", ["async!https://raw.github.com/HPNeo/gmaps/master/gmaps.js"], ->
  
  # return the gmaps namespace for brevity
  window.gmap