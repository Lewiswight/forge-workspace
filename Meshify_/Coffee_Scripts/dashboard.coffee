define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	make_collection = ->
		
		
		window.forge.ajax
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
	
	dashboard = Backbone.Model.extend 		
		initialize: -> 
			@set
				trafficlight: Meshable.chooseLight @get('trafficlight')		
		defaults: 				 				
			channelname: "Energy Costs"
			status: ""
			address: "123 Main St." 
			value: "1100.50"
			pre: "$"		
			post: ""
			trafficlight: "green" 	
		
	dashboards = Backbone.Collection.extend
		model: dashboard	
	#	url: ->
	#		Meshable.rooturl + "/api/dashboard"
	#	initialize: (dashboards) ->
	#		@fetch()


	dashboardView = Backbone.Marionette.ItemView.extend
		initialize: (dashboard) ->
			
			@bindTo @model, "change", @render
			
			
		template: '#dashboarditem-template'
		tagName: 'li'
		className: "list_item"
		
		
			
		
		


	dashboardsView = Backbone.Marionette.CompositeView.extend
		itemView: dashboardView
		template: "#wrapper_dashboard"
		itemViewContainer: "ul"
		id: "dashboard"
		
		
		
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
			collectionView.$("#dashboard_insert").append(itemView.el) 

	
	
	Meshable.vent.on "goto:dashboard", ->
		
		
		window.forge.ajax
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
				dashView = new dashboardsView
					collection: nodeCollection
					
					
				###models = JSON.parse """[{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"}]"""
				
				dashCol = new dashboards
			 	
				for model in models
					cModel = new dashboard
					dashCol.add cModel.parse(model)
				
				dashView = new dashboardsView
							collection: dashCol###
			
		
					
				Meshable.currentpage = "dashboard"
				$.mobile.changePage $('#splash'), changeHash: false,  transition: 'none', showLoadMsg: false
				Meshable.loginRegion.close()
				Meshable.mainRegion.close()
			
				Meshable.mainRegion.show(dashView)
		
				$("#dashboard").attr "data-role", "listview"
				$("#dashboard").attr "data-insert", "true" 
		
			
				changePage dashView, false
				
				
				
				
		
	changePage = (page, direction) ->
			$(page.el).attr "data-role", "page"
			
		
			
			trans = "slide"
			
			if @firstPage
				trans = "none"
				@firstPage = false
			#$.mobile.loading "show",
			#	theme: 'e'
			$.mobile.changePage $(page.el), changeHash: true, reverse: direction, transition: "none"
		
			
	