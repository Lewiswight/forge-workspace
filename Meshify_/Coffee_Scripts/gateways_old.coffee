define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	make_collection = ->
		
		
		forge.request.ajax
			url: Meshable.rooturl + "/api/dashboard"
			dataType: "json"
			type: "GET"
			error: (e) ->
				forge.notification.alert("Error", e.message) 
				#alert e.content
			success: (data) ->
				
				
				
				nodeCollection = new dashboards
				for model in data
					cModel = new dashboard
					nodeCollection.add cModel.parse(model)
				
				return nodeCollection
				
				
				
		
		###models = JSON.parse """[{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"}]"""
		
		nodeCollection = new dashboards
		
		for model in models
			cModel = new dashboard
			nodeCollection.add cModel.parse(model)
		
		return nodeCollection###
	
	gateway = Backbone.Model.extend 
		initialize: -> 
				@set
					trafficlight: "green"		
			defaults: 				 				
				trafficlight: "green" 			
				
		
	gateways = Backbone.Collection.extend
		model: gateway	
	#	url: ->
	#		Meshable.rooturl + "/api/dashboard"
	#	initialize: (dashboards) ->
	#		@fetch()


	gatewayView = Backbone.Marionette.ItemView.extend
		initialize: (node) ->
			
			@bindTo @model, "change", @render
			if node.model.attributes.nodetemplate == "gateway"
				@template = '#gatewayitem-template'
			else 
				@template = '#nodeitem-' + node.model.attributes.nodetemplate
			
			
			
		template: '#gatewayitem-template'
		tagName: 'li'
		className: "list_item"
		id: "gatewayItm"
		
		events:
			"click #add10": "add10Items"
			
			
		
		
		
		add10Items: ->
			$("body").addClass('ui-disabled') 
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			if not forge.is.connection.connected()
				forge.notification.alert("Failed to Load", "No Internet Connection")
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
				return
			
			Meshable.current_index_gw += 1
			LoadTen Meshable.current_searchTerm, Meshable.current_index_gw
			@model.destroy()
		

		
		
			
			 
			
			
		
		


	gatewayCompView = Backbone.Marionette.CompositeView.extend
		itemView: gatewayView
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		#id: "gateway"
		
		
		
		#events: 
			
			#"click #back-btn1": "back"
			#"click #menu_back_btn": "menu_back"

			
		#menu_back: ->
			#$("#popupPanel").popup("close")
		#back: ->
			#window.history.back()
		
		#popmenu: ->
			
			#$("#popupPanel").on popupbeforeposition: ->
				#h = $(window).height()
				#$("#popupPanel").css "height", h

			#$("#popupPanel").popup("open")
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el) 

	
	
	Meshable.vent.on "goto:gateways", (refresh, searchField) ->
		
		
		
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		
		if not refresh and Meshable.current_gateways != ""
			Meshable.nodeCollection = new gateways
			displayResults Meshable.current_gateways
			
			return
		
		
		Meshable.current_index = 0
		
		Meshable.current_index_gw = 0
		
		Meshable.nodeCollection = new gateways
		
		Meshable.current_gateways = []
		
		Meshable.currentDataObj = ""
		
		if not forge.is.connection.connected()
			forge.notification.alert("Failed to Load", "No Internet Connection")
			$("body").removeClass('ui-disabled')
			$.mobile.hidePageLoadingMsg()
			window.history.back()
			return
		else
			LoadTen searchField, Meshable.current_index
		
		
	LoadTen = (searchField, index) ->		
		forge.request.ajax
			url: Meshable.rooturl + "/api/Locations"
			data: { term: searchField, systemTypes: "", problemStatuses: "", customGroups: "", pageIndex: index, pageSize: 10 }
			dataType: "json"
			type: "GET"
			timeout: 15000
			error: (e) -> 
				forge.notification.alert("Error", e.message) 
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
				if index == 0
					window.history.back()
			success: (data) =>
				dataObj = new Object 
				dataObj.list = []
				data = data.CurrentPageListItems
				for node in data
					if node.person.first == ""
						node.person.first = "Unknown" 
					if node.person.last == ""
						node.person.last = "Unknown"
					if node.person.phone1 == ""
						node.person.phone1 = "000-000-0000"
					if node.address.city == ""
						node.address.city = "Unknown"
					if node.address.state == ""
						node.address.state = "Unknown"
					if node.address.street1 == ""
						node.address.street1 = "unknown"
					if node.address.zip == ""
						node.address.zip = "unknown"
					TempObj = node
					dataObj.list.push(TempObj)
				
				if Meshable.currentDataObj != ""
					for item in dataObj.list
						Meshable.currentDataObj.list.push(item)
				else
					Meshable.currentDataObj = dataObj
				
				
				
				
				if data.isAuthenticated == false
					myvent.trigger "auth:logout"
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
				else if data.length == 0
					forge.notification.alert("No Results", "") 
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
				else
					for node in data
						node.nodetemplate = "gateway"
					
					
					
					
					for node in data
						Meshable.current_gateways.push(node)
					
					
					displayResults data
					
	
					
	displayResults = (data) ->

		
		for model in data
			cModel = new gateway
			Meshable.nodeCollection.add cModel.parse(model)
			
		tempNode = new gateway { 
			nodetemplate: "add"
			}
		Meshable.nodeCollection.add tempNode
		
		gateView = new gatewayCompView
			collection: Meshable.nodeCollection
	
		
		


			
		Meshable.currentpage = "gateways"
		gateView.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(gateView.el))
		$("#mainPage").trigger('create')
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		#$("[data-role=footer]").fixedtoolbar({ fullscreen: true })
		
		
	
				
				
				
		
	
		
			
	