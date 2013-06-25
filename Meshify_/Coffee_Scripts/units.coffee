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
			if node.model.attributes.nodetemplate == "header"
				@template = "#label-template"
				@.$el.attr('data-role', 'list-divider')
			else 
				@template = '#nodeitem-template'

			
			
			
			
		
		tagName: 'li'
		className: "list_item_node"
		onRender: ->
			$("#mainDiv").trigger('create')
			$("#mainPage").trigger('create')
		
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
				
	
	

	
	
	Meshable.vent.on "goto:units", (refresh, routerObj) ->
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		
		if routerObj != ""
			displayResults routerObj
			return
		
		if not refresh and Meshable.current_units != "" and Meshable.refreshUnits == false
			showResults Meshable.current_units
			return
		
		if Meshable.currentDataObj != ""
				displayResults Meshable.currentDataObj
				return
				
		
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		forge.request.ajax
			url: Meshable.rooturl + "/api/Locations"
			data: { term: "", systemTypes: "", problemStatuses: "", customGroups: "", pageIndex: 0, pageSize: 10 }
			dataType: "json"
			type: "GET"
			error: (e) -> 
				alert "An error occurred on search... sorry!"
			success: (data) =>
				dataObj = new Object 
				dataObj.list = []
				data = data.CurrentPageListItems
				for node in data
					TempObj = node
					dataObj.list.push(TempObj)
					#dataObj.list.push(node.gateway.macaddress)
					#dataObj.first = node.person.first
					#dataObj.last = node.person.last
				#alert list
				if data.isAuthenticated == false
					Backbone.history.navigate "logout", replace: false, trigger: true
				else if data.length == 0
					alert "No Results"
				else
					displayResults dataObj
					
	 

	
	displayResults = (dataObj) ->
		Meshable.refreshUnits = false
		nodeCollection = new nodes 
		listlen = dataObj.list.length
		count = 0
		for obj in dataObj.list
			
			do (obj) ->
		
				$.mobile.showPageLoadingMsg("a", "Loading", false)
				forge.request.ajax
					url: Meshable.rooturl + "/api/gateway"
					data:  macaddress: obj.gateway.macaddress
					dataType: "json"
					type: "GET"
					error: (e) -> 
						alert "An error occurred while getting node details... sorry!"
					success: (data) =>
						if data.isAuthenticated == false
							Backbone.history.navigate "logout", replace: false, trigger: true
						else
							tempNode = new nodea { 
								first: obj.person.first
								nodetemplate: "header"
								last: obj.person.last
								}
							nodeCollection.add tempNode
							
							for obja in data
								if obja.nodetemplate != "mainMistaway"
									tempNode = new nodea
									nodeCollection.add tempNode.parse(obja)
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
				
				
				
		
	
		
			
	