require ["jquery", 'jqmglobe', 'jqm', "backbone", "underscore", "marionette", "Meshable", "Router", "Events", "login", 'dashboard', 'search', 'animate', 'slide', 'menu', 'gateways', 'nodes', 'node'], ($, jqmglobe, jqm, Backbone, _, Marionette, Meshable, Router, Events, login, dashboard, search, animate, slide, menu, gateways, nodes, node) ->
  
  # The "app" dependency is passed in as "Meshable"

	#$(document).bind "pagechange", ->
  	#			$(".ui-page-active .ui-listview").listview "refresh"
  	#			$(".ui-page-active :jqmData(role=content)").trigger "create"

	$(document).ready ->

		Meshable.events = Events
		Meshable.router = new Router()
		
		Meshable.router.on "route:searchterm", (searchField) ->	
			$.mobile.showPageLoadingMsg()
			Meshable.vent.trigger "search:gateways", searchField
		
		Backbone.history.navigate "", replace: true, trigger: true
		#Backbone.history.start
		
		
		#Meshable.loginRegion.show(login)
		
		
		
		
		
		Meshable.start
			authModel: "login"
		
		

		

	#^	Backbone.history.start()
		
		
		
	    

  
    

    
  
