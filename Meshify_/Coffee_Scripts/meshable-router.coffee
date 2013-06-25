define ['jquery','jqm', 'backbone','underscore','marionette', 'Meshable', 'Events', 'login', 'dashboard', 'search'], ($, jqm, Backbone, _, Marionette, Meshable, Events, login, dashboard, search) ->  




	
	
	Routing = Backbone.Router.extend
	
	
		routes:
			"unit/:mac/:first/:last": "unitsM"
			"units": "units"
			"gateway/:mac": "gateway"
			"gateway/:mac/:id": "nodeDetails"
			"": "home"
			"dashboard": "dashboard"
			"menu": "menu"
			"back": "back"
			"popupPanel": "popupPanel"
			"menu_back_btn": "menu_back_btn"
			"search": "search"
			"searching/:id": "searchterm"
			"gateways": "gateways"
			"page1": "page1"
			"ref-page": "refPage"
			"logout": "logout"
			
		unitsM: (mac, first, last) ->
			obj = new Object
			obj.list = []
			listObj = new Object
			listObj.person = new Object
			listObj.gateway = new Object
			listObj.gateway.macaddress = mac
			listObj.person.first = first
			listObj.person.last = last
			obj.list.push(listObj)
			Meshable.vent.trigger "goto:units", false, obj
			
		units: ->
			Meshable.vent.trigger "goto:units", false, ""
			
		nodeDetails: (mac, id) ->
			Meshable.vent.trigger "goto:nodeRefresh", mac, id
			
		logout: ->
			$("body").addClass('ui-disabled') 
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			
			forge.request.ajax
				url: Meshable.rooturl + "/api/authentication?logmeoff=true"
				dataType: "json"
				type: "GET"
				error: (e) ->
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					Meshable.vent.trigger "goto:login" 
					alert "error logging out"
				success: (data) ->
					
					Meshable.current_units = ""
					Meshable.current_gateways = ""
					$.mobile.hidePageLoadingMsg()
					$("body").removeClass('ui-disabled')
					Meshable.vent.trigger "goto:login"
					$('#mainDiv').empty()
		
		refPage: ->
			$.mobile.changePage $('#ref-page'), changeHash: false,  transition: 'none', showLoadMsg: true
		
		
		gateway: (macaddress) ->
			Meshable.currentMac = macaddress
			Meshable.vent.trigger "goto:nodes", macaddress
				
		gateways: ->
			Meshable.vent.trigger "goto:gateways", false, ""	
		
		#searchterm: (searchField) -> 
		#	$.mobile.showPageLoadingMsg()
		#	Meshable.vent.trigger "search:gateways", searchField		
		
		search: ->
			Meshable.vent.trigger "goto:search"
			
			
		menu_back_btn: ->
			$("#popupPanel").popup("close")
			
			
		popupPanel: ->
			#Meshable.router.navigate "#&ui-state=dialog", trigger: true
			$("#popupPanel").popup("open")
			
			
		back: ->
			
			window.history.back()
		
			#Meshable.vent.trigger "go:back"
			
			
		home: ->
			Meshable.vent.trigger "goto:login"
			#login.render()
			#$('#login').empty()
			#$('#login').append($(login.el))

			#Meshable.changePage login, false
			
		
		
		dashboard: ->
			#Meshable.vent.trigger "goto:menu"
			Meshable.vent.trigger "goto:dashboard"
			
			
			

		menu: ->
			
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
			
		
				
		changePage: (page, direction) ->
			$(page.el).attr "data-role", "page"
			$(page.el).attr "data-theme", Meshable.theme
			#$(page.el).attr "id", id
			$.mobile.changePage $(page.el), changeHash: true, reverse: direction, transition: "none"

	
	
		initialize: ->
			@firstPage = true
			@firstDash = true
		
			
		
			
			


	return Routing
