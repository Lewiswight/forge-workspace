define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	
				
	nodea = Backbone.Model.extend 
		initialize: -> 
				@set
					trafficlight: "green"		
			defaults: 				 				
				trafficlight: "green" 			
				
		
	nodes = Backbone.Collection.extend
		model: nodea	
	


	nodeView = Backbone.Marionette.ItemView.extend
		initialize: (node) ->
			
			@bindTo @model, "change", @render
			
			
		template: '#nodeitem-template'
		tagName: 'li'
		className: "list_item_node"
		onRender: ->
			$("#mainDiv").trigger('create')
			$("#mainPage").trigger('create')
		
		events:
			"click .ui-link-inherit": "displayNode"
			
		
		displayNode: ->
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			#Meshable.router.navigate "/#gateway/" + @model.attributes.macaddress + "/" + @model.attributes.node.NodeId, trigger: false
			#Meshable.vent.trigger "goto:node", @model.attributes
			
		


	nodeCompView = Backbone.Marionette.CompositeView.extend
		itemView: nodeView
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		#id: "node-test"
		
		
		
		
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el)			
				
	
	

	
	
	Meshable.vent.on "goto:units", (refresh) ->
		
		if not refresh and Meshable.current_units != ""
			showResults Meshable.current_units
			return
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		window.forge.ajax
			url: "http://devbuildinglynx.apphb.com/api/Locations"
			data: { term: "", systemTypes: "", problemStatuses: "", customGroups: "", pageIndex: 0, pageSize: 30 }
			dataType: "json"
			type: "GET"
			error: (e) -> 
				alert "An error occurred on search... sorry!"
			success: (data) =>
				list = []
				data = data.CurrentPageListItems
				for node in data
					list.push(node.gateway.macaddress)
				#alert list
				if data.isAuthenticated == false
					Backbone.history.navigate "logout", replace: false, trigger: true
				else if data.length == 0
					alert "No Results" 
				else
					displayResults list
					
	 

	
	displayResults = (list) ->
		nodeCollection = new nodes
		listlen = list.length
		count = 0
		for macaddress in list
			do (macaddress) ->
		
				$.mobile.showPageLoadingMsg("a", "Loading", false)
				window.forge.ajax
					url: "http://devbuildinglynx.apphb.com/api/gateway"
					data:  macaddress: macaddress
					dataType: "json"
					type: "GET"
					error: (e) -> 
						alert "An error occurred while getting node details... sorry!"
					success: (data) =>
						if data.isAuthenticated == false
							Backbone.history.navigate "logout", replace: false, trigger: true
						else
							
							for obj in data
								if obj.nodetemplate != "mainMistaway"
									tempNode = new nodea
									nodeCollection.add tempNode.parse(obj)
							count += 1
							if count >= listlen
								Meshable.current_units = nodeCollection
								showResults nodeCollection
								
									
				
		
	
		
		
						
		
			
			
	showResults = (nodeCollection) ->	
			
		nodeCoView = new nodeCompView
			collection: nodeCollection
	
		
		
 		
	
					
		Meshable.currentpage = "units"
		nodeCoView.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(nodeCoView.el))
		$("#mainDiv").trigger('create')
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		$("body").removeClass('ui-disabled')
		$("#mainPage a").removeClass('ui-btn-active')
		$("#nodesbtnn").addClass('ui-btn-active')
		#Meshable.changePage nodeCoView, false
				
				
				
		
	
		
			
	