define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	make_collection = ->
		
		
		window.forge.ajax
			url: "http://devbuildinglynx.apphb.com/api/dashboard"
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
				
				
				
		
			
	
	node = Backbone.Model.extend 
		initialize: -> 
				@set
					trafficlight: "green"		
			defaults: 				 				
				trafficlight: "green" 			
				
		
	nodes = Backbone.Collection.extend
		model: node	
	


	nodeView = Backbone.Marionette.ItemView.extend
		initialize: (node) ->
			
			@bindTo @model, "change", @render
			
			
		template: '#nodeitem-template'
		tagName: 'li'
		className: "list_item_node"
		
		
		events:
			"click .node-item": "displayNode"
			
		
		displayNode: ->
			$.mobile.showPageLoadingMsg()
			Meshable.vent.trigger "goto:node", @model.attributes
			
		


	nodeCompView = Backbone.Marionette.CompositeView.extend
		itemView: nodeView
		template: "#wrapper_dashboard"
		itemViewContainer: "ul"
		#id: "node"
		
		
		
		
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#dashboard_insert").append(itemView.el) 

	
	
	Meshable.vent.on "goto:nodes", (macaddress) ->
		
		$.mobile.showPageLoadingMsg()
		window.forge.ajax
			url: "http://devbuildinglynx.apphb.com/api/gateway"
			data:  macaddress: macaddress
			dataType: "json"
			type: "GET"
			error: (e) -> 
				alert "An error occurred while getting node details... sorry!"
			success: (data) =>
				if data.isAuthenticated == false
					alert "auth:logout"
				else if data.length == 0
					$.mobile.hidePageLoadingMsg()
					alert "No nodes at this location"
					Backbone.history.navigate "gateways", trigger : false , replace: true
				else
					displayResults data
		
		
	

	
	
					
	displayResults = (data) ->
		nodeCollection = new nodes
		# here I check to see if you only have one unit at your location
		if data.length < 3
			for obj in data
				if obj.nodetemplate != "mainMistaway"
					$.mobile.showPageLoadingMsg()
					Meshable.vent.trigger "goto:node", obj
					return
		for obj in data
			if obj.nodetemplate != "mainMistaway"
				tempNode = new node
				nodeCollection.add tempNode.parse(obj)
		nodeCoView = new nodeCompView
			collection: nodeCollection
	
		
		


					
		Meshable.currentpage = "nodes"
		nodeCoView.render()
		$('#nodes').empty()
		$('#nodes').append($(nodeCoView.el))
	
		Meshable.changePage nodeCoView, false
					
				
				
			
		
			
	