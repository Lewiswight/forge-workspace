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
	Meshable.refreshUnits = false
	Meshable.addRegions
		loginRegion: "#login"
		mainRegion: "#mainR"
		searchRegion: "#searchR"
		menuRegion: "#menuR"
	
		
	#$(document).on "click", "#menu-btn", ->
  		#Meshable.vent.trigger "click:menu"
	$(document).on "click", "#refresh-btn", ->
  		window.history.refresh()
	
	$(document).on "click", "#back-btn", ->
  		window.history.back()
	
	#$(document).bind('pagechange', ->
	#	$('.ui-page-active .ui-listview').listview('refresh')
	#	$('.ui-page-active :jqmData(role=content)').trigger('create')
		
	#	)

	
	
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

	Meshable.changePage = (page, direction) ->
		$(page.el).attr "data-role", "page"
		$(page.el).attr "data-theme", Meshable.theme
		$.mobile.changePage $(page.el), changeHash: true, reverse: direction, transition: "fade"
		$("#locationbtnn").addClass('ui-btn-active')

	Meshable.chooseLight = (light) -> 
		if light == "green"
			return "https://s3.amazonaws.com/LynxMVC4-Bucket/green-light.png"
		else if light == "yellow" 
			return "https://s3.amazonaws.com/LynxMVC4-Bucket/yellow-light.png"
		else if light == "red"
			return "https://s3.amazonaws.com/LynxMVC4-Bucket/red-light.png"
		else 
			return "https://s3.amazonaws.com/LynxMVC4-Bucket/no-light.png"

	return Meshable