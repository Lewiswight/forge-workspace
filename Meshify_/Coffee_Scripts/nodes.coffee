define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	
				
				
				
		
			
	
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
		
		
		#events:
		#	"click .ui-link-inherit": "displayNode"
			
		
		displayNode: ->
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			Meshable.router.navigate "/gateway/" + @model.attributes.macaddress + "/" + @model.attributes.node.NodeId, trigger: false
			Meshable.vent.trigger "goto:node", @model.attributes
			
		


	nodeCompView = Backbone.Marionette.CompositeView.extend
		itemView: nodeView
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		#id: "node-test"
		
		
		
		
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el) 

	
	
	Meshable.vent.on "goto:nodes", (macaddress) ->
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		window.forge.ajax
			url: Meshable.rooturl + "/api/gateway"
			data:  macaddress: macaddress
			dataType: "json"
			type: "GET"
			error: (e) -> 
				forge.notification.alert("Error", e.message) 
			success: (data) =>
				if data.isAuthenticated == false
					alert "auth:logout"
				else if data.length == 0
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					forge.notification.alert("No units at this location", "") 
					Backbone.history.navigate "gateways", trigger : false , replace: true
				else
					displayResults data
		
		
	

	
	
					
	displayResults = (data) ->
		nodeCollection = new nodes
		# here I check to see if you only have one unit at your location
		alert "at the spot"
		alert data.length()
		if data.length < 2
			for obj in data
				if obj.nodetemplate != "mainMistaway"
					$("body").addClass('ui-disabled')
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
		$('#mainDiv').empty()
		$('#mainDiv').append($(nodeCoView.el))
		$("#mainDiv").trigger('create')
		$("body").removeClass('ui-disabled')
		$.mobile.hidePageLoadingMsg()
		
		
		#Meshable.changePage nodeCoView, false
					
				
				
			
		
			
	