define ['jquery','jqm', 'backbone','underscore','marionette', 'Meshable', 'Events', 'login', 'dashboard', 'search'], ($, jqm, Backbone, _, Marionette, Meshable, Events, login, dashboard, search) ->  




	
	
	Routing = Backbone.Router.extend
		
		routes:
			"unit/:mac/:first/:last/:phone1/:city/:state/:street1/:zip": "unitsM"
			"units": "units"
			"gateway/:mac": "gateway"
			"gateway/:mac/:id/:first/:last/:phone1/:city/:state/:street1/:zip": "nodeDetails"
			"": "home"
			"dashboard": "dashboard"
			"menu": "menu"
			"back": "back"
			"popupPanel": "popupPanel"
			"menu_back_btn": "menu_back_btn"
			"search": "search"
			"searching/:id/:resultType": "searchterm"
			"gateways": "gateways"
			"page1": "page1"
			"ref-page": "refPage"
			"logout": "logout"
			"contact": "contact"
		
		contact: ->
			Meshable.vent.trigger "goto:contact"
			
		unitsM: (mac, first, last, phone1, city, state, street1, zip) ->	
			obj = new Object
			obj.list = []
			listObj = new Object
			listObj.person = new Object
			listObj.gateway = new Object
			listObj.gateway.macaddress = mac
			listObj.person.userRole = Meshable.userRole
			listObj.person.first = first
			listObj.person.last = last
			listObj.person.phone1 = phone1
			listObj.address = new Object
			listObj.address.city = city
			listObj.address.state = state
			listObj.address.street1 = street1
			listObj.address.zip = zip
			obj.list.push(listObj)
			Meshable.vent.trigger "goto:units", false, obj
			
		units: ->
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			Meshable.vent.trigger "goto:units", false, ""
			
		nodeDetails: (mac, id, first, last, phone1, city, state, street1, zip) ->
			
			if first == "unknown" or first == null
				first = ""
			if last == "unknown" or last == null
				last = ""
			if phone1 == "unknown" or phone1 == null
				phone1 = ""
			if city == "unknown" or city == null
				city = ""
			if state == "unknown" or state == null
				state = ""
			if street1 == "unknown" or street1 == null 
				street1 = ""
			if zip == "unknown" or zip == null
				zip = ""
			if not forge.is.connection.connected()
				forge.notification.alert("Failed to Load", "No Internet Connection")
				window.history.back()
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
				return
			
			Meshable.backplace = "#" + mac
			Meshable.vent.trigger "goto:nodeRefresh", mac, id, first, last, phone1, city, state, street1, zip

			
		logout: ->
			$("body").addClass('ui-disabled') 
			$.mobile.showPageLoadingMsg("a", "Loading", false)

			
			forge.request.ajax
				url: Meshable.rooturl + "/api/authentication?logmeoff=true"
				dataType: "json"
				type: "GET"
				error: (e) ->
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					Meshable.current_index = 0
					Meshable.current_units = ""
					Meshable.current_gateways = ""
					Meshable.current_searchTerm = ""
					Meshable.vent.trigger "goto:login"
					Meshable.currentMap = null 
					$('#mainDiv').empty()
				success: (data) ->
					Meshable.current_index = 0
					Meshable.currentMap = null
					Meshable.current_units = ""
					Meshable.current_gateways = ""
					Meshable.current_searchTerm = ""
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
			Meshable.loading = true
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			Meshable.vent.trigger "showmap"
		
		searchterm: (searchField, resultType) ->
			if searchField == "_"
				searchField = ""
			if searchField == Meshable.current_searchTerm
				if resultType == "List"
					Meshable.vent.trigger "goto:units", true, "" 
					Meshable.router.navigate "units", trigger : false, replace: true
					return
				else
					$.mobile.showPageLoadingMsg("a", "Loading", false)
					Meshable.vent.trigger "showmap"
					return
			
			Meshable.current_searchTerm = searchField
			Meshable.currentMap = null
			Meshable.current_index = 0
			Meshable.current_gateways = ""
			Meshable.refreshUnits = true
			if resultType == "List"
				Meshable.vent.trigger "goto:units", true, "" 
				Meshable.router.navigate "units", trigger : false, replace: true
			else
				$.mobile.showPageLoadingMsg("a", "Loading", false)
				Meshable.vent.trigger "showmap"		
		
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
