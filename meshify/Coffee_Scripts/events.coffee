define ['jquery','jqm', 'backbone','underscore','marionette', 'meshable', 'login', 'dashboard'], ($, jqm, Backbone, _, Marionette, Meshable, login, dashboard) ->  
	
	Events = new Backbone.Marionette.EventAggregator
		
	Events.on "rerender:login", -> 
		$.mobile.changePage $('#splash'), changeHash: false,  transition: 'none', showLoadMsg: false
		Meshable.loginRegion.close()
		Meshable.loginRegion.show(login)
		$("#password-input").hide()
		$.mobile.changePage $(login.el), changeHash: false,  transition: "none", showLoadMsg: true
	
	Meshable.vent.on "open:search", ->
		Backbone.history.navigate "search", trigger : true , replace: false
		
		#window.setTimeout (->
					#Backbone.history.navigate "search", trigger : false , replace: false
				#), 500
		
	
	Meshable.vent.on "click:menu", ->
		
		
		$("#popupPanel").on popupbeforeposition: ->
			h = $(window).height()
			$("#popupPanel").css "height", h
			
		$("#popupPanel").bind popupafterclose:  ->
			Meshable.vent.trigger "menu:close"

		$("#popupPanel").popup("open")
	
		$("#menu_back_btn").tap ->
			$("#popupPanel").popup("close")

			
		$("#menu_search_btn").tap ->
			$("#popupPanel").popup("close")
			
			window.setTimeout (->
				Meshable.vent.trigger "open:search"
			), 600
	Meshable.vent.on "menu:close", ->
		
		Backbone.history.navigate Meshable.currentpage, replace: true, trigger: false
		window.history.back()
		
	
	Meshable.vent.on "go:back", ->	
		
			
	Events.on "start:auth", ->
		Meshable.loginRegion.show Meshable.authview
			
	Events.on "start:angrycats",  ->
		Meshable.loginRegion.show Meshable.angryCatsView
	
	return Events
	
	