define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	make_collection = ->
		
		
		forge.request.ajax
			url: Meshable.rooturl + "/api/dashboard"
			dataType: "json"
			type: "GET"
			error: (e) -> 
				alert e.content
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
		initialize: (gateway) ->
			
			@bindTo @model, "change", @render
			
			
		template: '#gatewayitem-template'
		tagName: 'li'
		className: "list_item"
		id: "gatewayItm"
		

		
		
			
			 
			
			
		
		


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
			displayResults Meshable.current_gateways
			return
		
		
		forge.request.ajax
			url: Meshable.rooturl + "/api/Locations"
			data: { term: searchField, systemTypes: "", problemStatuses: "", customGroups: "", pageIndex: 0, pageSize: 10 }
			dataType: "json"
			type: "GET"
			error: (e) -> 
				alert "An error occurred on search... sorry!"
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
			success: (data) =>
				dataObj = new Object 
				dataObj.list = []
				data = data.CurrentPageListItems
				for node in data
					TempObj = node
					dataObj.list.push(TempObj)
				Meshable.currentDataObj = dataObj
				Meshable.refreshUnits = true
				if data.isAuthenticated == false
					myvent.trigger "auth:logout"
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
				else if data.length == 0
					alert "No Results" 
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
				else
					Meshable.current_gateways = data
					displayResults data
					
	Meshable.vent.on "search:gateways", (sdata) ->
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		forge.request.ajax
			url: Meshable.rooturl + "/api/Locations"
			data: { term: sdata, systemTypes: "", problemStatuses: "", customGroups: "", pageIndex: 0, pageSize: 10 }
			dataType: "json"
			type: "GET"
			error: (e) -> 
				alert "An error occurred on search... sorry!"
			success: (data) =>
				data = data.CurrentPageListItems
				if data.isAuthenticated == false
					myvent.trigger "auth:logout"
				else if data.length == 0
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					alert "No Results" 
					Backbone.history.navigate "search", replace: true, trigger: false
				else
					#Backbone.history.navigate "search-gateways", replace: false, trigger: false
					displayResults data

	
	
					
	displayResults = (data) ->
		nodeCollection = new gateways
		for model in data
			cModel = new gateway
			nodeCollection.add cModel.parse(model)
		gateView = new gatewayCompView
			collection: nodeCollection
	
		
		


			
		Meshable.currentpage = "gateways"
		gateView.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(gateView.el))
		$("#mainPage").trigger('create')
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		#$("[data-role=footer]").fixedtoolbar({ fullscreen: true })
		$("[data-role=footer]").fixedtoolbar({ tapToggle: true })
		$("[data-role=footer]").fixedtoolbar({ tapToggleBlacklist: "a, button, tap, div, img, input, select, textarea, .ui-header-fixed, .ui-footer-fixed" })
		$("#mainPage a").removeClass('ui-btn-active')
		$("#locationbtnn").addClass('ui-btn-active')
				
				
				
		
	
		
			
	