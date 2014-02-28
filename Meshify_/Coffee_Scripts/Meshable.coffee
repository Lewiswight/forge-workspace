# We need to instantiate the app here
define ['jquery', 'jqm', 'backbone','marionette' ], ($, jqm, Backbone, Marionette) ->  
	#forge.enableDebug()
	#$.support.cors = true
	#$.mobile.allowCrossDomainPages = true
	Meshable = new Backbone.Marionette.Application()
	Meshable.company = new Object
	Meshable.user = new Object
	Meshable.location = new Object
	Meshable.theme = "a"
	Meshable.rooturl = "http://apg.meshify.com"
	Meshable.current-search = null 
	Meshable.current_units = ""
	Meshable.current_gateways = ""
	Meshable.currentDataObj = ""
	Meshable.current_searchTerm = ""
	Meshable.current_index_gw = 0
	Meshable.current_index = 0
	Meshable.nodeCoView = ""
	Meshable.backplace = ""
	Meshable.nodeCollection = ""
	Meshable.refreshUnits = false
	Meshable.currentMap = null
	Meshable.mapRefresh = false
	Meshable.loading = false
	Meshable.addRegions
		loginRegion: "#login"
		mainRegion: "#mainR"
		searchRegion: "#searchR"
		menuRegion: "#menuR"
	#$("[data-role=footer]").fixedtoolbar({ tapToggle: false })
	#$("[data-role=footer]").fixedtoolbar({ tapToggleBlacklist: "a, button, tap, div, img, input, select, textarea, .ui-header-fixed, .ui-footer-fixed" })
		
	$(document).on "click", "#newPas", ->
  		Meshable.vent.trigger "new:password"
  	
  	
	 		
	Meshable.changePage = (page, direction) ->
		$(page.el).attr "data-role", "page"
		$(page.el).attr "data-theme", Meshable.theme
		$.mobile.changePage $(page.el), changeHash: true, reverse: direction, transition: "fade"
		$("#locationbtnn").addClass('ui-btn-active')

	Meshable.on "initialize:after", (options) ->
		$.mobile.autoInitializePage = false
		$.mobile.pageContainer = $("body")
		$.mobile.ajaxEnabled = false
		$.mobile.linkBindingEnabled = false
		$.mobile.hashListeningEnabled = false
		$.mobile.pushStateEnabled = true
		$.mobile.loader.prototype.options.text = "loading"
		$.mobile.loader.prototype.options.textVisible = true
		$.mobile.loader.prototype.options.theme = "c"
		#$.mobile.loader.prototype.options.html = ""
		
		#$("div[data-role=\"page\"]").live "pagehide", (event, ui) ->
		#$(event.currentTarget).remove()
		
		Backbone.history.start
			root: window.location.protocol + "//" + window.location.host
			pushState: false

	
	forge.topbar.setTitle("Meshify")
	forge.topbar.addButton(
	  text: "Refresh"
	  position: "right"
	,  ->
		Meshable.vent.trigger "goto:refresh"
	
	)
	
	
	Meshable.vent.on "goto:refresh", ->
		route = Backbone.history.fragment
		if route == "units" 
			if Meshable.current_index > 0
				Meshable.currentDataObj = ""
			Meshable.current_units = ""
		else if route == "gateways"
			#Meshable.vent.trigger 'zoom:location'
			#return
			Meshable.mapRefresh = true
		else if route.substring(0, 10) == "searching/"
			Meshable.mapRefresh = true
			
		Meshable.router.navigate "nowhere", trigger : false, replace: true
		Meshable.router.navigate route, trigger : true, replace: true
  		#window.location.reload(false) 
  		
	forge.topbar.addButton(
	  text: "Back"
	  position: "left"
	,  ->
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		window.history.back()
		
	)
	 		
				
	

	
	forge.tabbar.addButton(
	  text: "Map"
	  icon: "img/compass.png"
	  index: 0
	, (button) ->
	  Meshable.locationButton = button
	  button.onPressed.addListener ->
	  	if Meshable.loading == false
	    	Meshable.router.navigate "gateways", trigger : true
	)
	 
	forge.tabbar.addButton(
	  text: "Units"
	  icon: "img/text-list.png"
	  index: 1
	, (button) ->
	  Meshable.unitsButton = button
	  button.onPressed.addListener ->
	  	if Meshable.loading == false
	    	Meshable.router.navigate "units", trigger : true
	  button.setActive()
	)
	forge.tabbar.addButton(
	  text: "Search"
	  icon: "img/search.png"
	  index: 2
	, (button) ->
	  Meshable.searchButton = button
	  button.onPressed.addListener ->
	  	if Meshable.loading == false
	    	Meshable.router.navigate "search", trigger : true

	)	
	
	forge.tabbar.addButton(
	  text: "Contact"
	  icon: "img/phone.png"
	  index: 3
	, (button) ->
	  Meshable.contactButton = button
	  button.onPressed.addListener ->
	  	if Meshable.loading == false
	    	Meshable.router.navigate "contact", trigger : true

	)
	forge.tabbar.addButton(
	  text: "Log Out"
	  icon: "img/power-button.png"
	  index: 4
	, (button) ->
	  button.onPressed.addListener ->
	    Meshable.router.navigate "logout", trigger : true

	)
	


	return Meshable