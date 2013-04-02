define ['jquery','backbone','underscore','marionette', 'Meshable', 'Events'], ($, Backbone, _, Marionette, Meshable, Events) ->  
		
	$(document).bind "mobileinit", ->
		$.mobile.ajaxEnabled = false
		$.mobile.linkBindingEnabled = false
		$.mobile.hashListeningEnabled = false
		$.mobile.pushStateEnabled = false
		  
		  # Remove page from DOM when it's being replaced
		$("div[data-role=\"page\"]").live "pagehide", (event, ui) -> 
		$(event.currentTarget).remove()

