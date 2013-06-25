require ["jquery", "backbone"], ( $, Backbone) ->
	# Set up the "mobileinit" handler before requiring jQuery Mobile's module
	$(document).on "mobileinit", ->
	  
		# Prevents all anchor click handling including the addition of active button state and alternate link bluring.
		$.mobile.linkBindingEnabled = false
		  
		# Disabling this will prevent jQuery Mobile from handling hash changes
		$.mobile.hashListeningEnabled = false
	
		
			
require [ 'jqmglobe', 'jqm',  "underscore", "marionette", "Meshable", "Router", "Events", "login", 'dashboard', 'search', 'animate', 'slide', 'menu', 'gateways', 'nodes', 'node', 'units'], ( jqmglobe, jqm, _, Marionette, Meshable, Router, Events, login, dashboard, search, animate, slide, menu, gateways, nodes, node, units) ->
  
  # The "app" dependency is passed in as "Meshable"

	#$(document).bind "pagechange", ->
  	#			$(".ui-page-active .ui-listview").listview "refresh"
  	#			$(".ui-page-active :jqmData(role=content)").trigger "create"

		
			
	$(document).ready ->

		Meshable.events = Events
		Meshable.router = new Router()
		
		Meshable.router.on "route:searchterm", (searchField) ->	
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			Meshable.vent.trigger "goto:gateways", true, searchField
		
		Backbone.history.navigate "", replace: true, trigger: true
		#Backbone.history.start
		
		
		#Meshable.loginRegion.show(login)
		
		
		
		
		
		Meshable.start
			authModel: "login"
		
		

		

	#^	Backbone.history.start()
		
		
		
	    

  
    

    
  

