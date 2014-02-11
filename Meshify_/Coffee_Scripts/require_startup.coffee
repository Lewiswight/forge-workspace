require ["jquery", "async", "propertyParser", "goog", "backbone"], ( $, async, propertyParser, goog, Backbone) ->
	# Set up the "mobileinit" handler before requiring jQuery Mobile's module
	$(document).on "mobileinit", ->
	  
		# Prevents all anchor click handling including the addition of active button state and alternate link bluring.
		$.mobile.linkBindingEnabled = false
		  
		# Disabling this will prevent jQuery Mobile from handling hash changes
		$.mobile.hashListeningEnabled = false
	
		
			
require [ 'jqmglobe', 'jqm',  "underscore", "marionette", "Meshable", "Router", "Events", "login", 'dashboard', 'search', 'animate', 'slide', 'menu', 'gateways', 'nodes', 'node', 'units', 'contact', 'vendor/charts.js'], ( jqmglobe, jqm, _, Marionette, Meshable, Router, Events, login, dashboard, search, animate, slide, menu, gateways, nodes, node, units, contact) ->
  
  # The "app" dependency is passed in as "Meshable"

	#$(document).bind "pagechange", ->
  	#			$(".ui-page-active .ui-listview").listview "refresh"
  	#			$(".ui-page-active :jqmData(role=content)").trigger "create"

		
	
	$(document).ready ->
		
		
		
		
		###forge.request.ajax
			url:"https://s3.amazonaws.com/LynxMVC4-Bucket/template-apgus.html"
			dataType: "HTML"
			type: "GET"
			timeout: 15000
			error: (e) -> 
				forge.notification.alert("Error", e.message) 
				$.mobile.hidePageLoadingMsg()
				$("body").removeClass('ui-disabled')
				Meshable.loading = false
				window.history.back()
			success: (data) =>
				alert data
				$('body').append data###
		
		google.load "visualization", "1",
  			packages: ["gauge", "corechart"]
		
		Meshable.events = Events
		Meshable.router = new Router()
		
		
		Backbone.history.navigate "", replace: true, trigger: true
		#Backbone.history.start
		
		
		#Meshable.loginRegion.show(login)
		
		
		
		
		
		Meshable.start
			authModel: "login"
		
		

		

	#^	Backbone.history.start()
		
		
		
	    

  
    

    
  

