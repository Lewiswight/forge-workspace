define ['jquery','backbone','underscore','marionette', 'meshable', 'Events'], ($, Backbone, _, Marionette, Meshable, Events) ->  
		
	$(document).bind "mobileinit", ->
		$.mobile.ajaxEnabled = false
		$.mobile.linkBindingEnabled = true
		$.mobile.hashListeningEnabled = false
		$.mobile.pushStateEnabled = false
		  
		  # Remove page from DOM when it's being replaced
		$("div[data-role=\"page\"]").live "pagehide", (event, ui) ->
		$(event.currentTarget).remove()

