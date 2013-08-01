# We need to instantiate the app here
define ['jquery', 'jqm', 'backbone','marionette' ], ($, jqm, Backbone, Marionette) ->  

	#$.support.cors = true
	#$.mobile.allowCrossDomainPages = true

	Meshable = new Backbone.Marionette.Application()
	Meshable.theme = "a"
	Meshable.rooturl = "http://imistaway.com"
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
	Meshable.addRegions
		loginRegion: "#login"
		mainRegion: "#mainR"
		searchRegion: "#searchR"
		menuRegion: "#menuR"
	#$("[data-role=footer]").fixedtoolbar({ tapToggle: false })
	#$("[data-role=footer]").fixedtoolbar({ tapToggleBlacklist: "a, button, tap, div, img, input, select, textarea, .ui-header-fixed, .ui-footer-fixed" })
		
	#$(document).on "click", "#menu-btn", ->
  		#Meshable.vent.trigger "click:menu"
  		
 		
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


	
	Meshable.refreshButton = forge.topbar.addButton(
	  text: "Refresh"
	  position: "right"
	,  ->
		route = Backbone.history.fragment
		if route == "units" or route == "gateways"
			if Meshable.current_index > 0
				Meshable.currentDataObj = ""
			Meshable.current_units = ""
			Meshable.current_gateways = ""
		Meshable.router.navigate "nowhere", trigger : false, replace: true
		Meshable.router.navigate route, trigger : true, replace: true
  		#window.location.reload(false) 
	
	
	
	)
	Meshable.backButton = forge.topbar.addButton(
	  text: "Back"
	  position: "left"
	,  ->
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		window.history.back()
		
	)
	 		
				
	

	
	forge.tabbar.addButton(
	  text: "Location"
	  icon: "img/compass.png"
	  index: 0
	, (button) ->
	  Meshable.locationButton = button
	  button.onPressed.addListener ->
	    Meshable.router.navigate "gateways", trigger : true
	)
	 
	forge.tabbar.addButton(
	  text: "Units"
	  icon: "img/text-list.png"
	  index: 1
	, (button) ->
	  Meshable.unitsButton = button
	  button.onPressed.addListener ->
	    Meshable.router.navigate "units", trigger : true
	  button.setActive()
	)
	Meshable.searchButton = forge.tabbar.addButton(
	  text: "Search"
	  icon: "img/search.png"
	  index: 2
	, (button) ->
	  button.onPressed.addListener ->
	    Meshable.router.navigate "search", trigger : true

	)	
	
	Meshable.ContactButton = forge.tabbar.addButton(
	  text: "Contact"
	  icon: "img/phone.png"
	  index: 3
	, (button) ->
	  button.onPressed.addListener ->
	    Meshable.router.navigate "contact", trigger : true

	)
	Meshable.logoutButton = forge.tabbar.addButton(
	  text: "Log Out"
	  icon: "img/power-button.png"
	  index: 4
	, (button) ->
	  button.onPressed.addListener ->
	    Meshable.router.navigate "logout", trigger : true

	)



	return Meshable