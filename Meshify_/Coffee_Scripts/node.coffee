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
			@template = "#template-" + node.model.attributes.nodetemplate
			
			
		#template: '#node-template'
		tagName: 'li'
		
			
		events:
			#"click #mistBtn": "mist"
			#"click #stopBtn": "stop"
			"click .setstatic": "setbutton"
			
		
		setbutton: (e) ->
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			value = $(e.currentTarget).data "setvalue"
			node_type = $(e.currentTarget).data "nodetype"	
			channel = $(e.currentTarget).data "channel" 
			full_name = node_type + "." + channel
			mistData = new Array
			localobj = 
				ChannelId: @model.attributes.channels[full_name].ChannelId
				value: value
				techName: @model.attributes.channels[full_name].techName
				name: full_name
			mistData[0] = localobj
			@setChannel mistData
			
		
		
		
		setChannel: (channels) -> 
			mac = new Array
			mac[0] = @model.attributes.macaddress
			#add validation
			#find the channels that need to be set 

			window.forge.ajax
				url: Meshable.rooturl + "/api/channel"
				data:  JSON.stringify({macaddresses: [@model.attributes.macaddress], channelDTO: channels})
				dataType: "json"
				type: "POST"
				contentType: 'application/json; charset=utf-8'
				error: (e) ->
					$("body").removeClass('ui-disabled') 
					$.mobile.hidePageLoadingMsg()
					#alert "An error occurred while getting node details... sorry!"
				success: (data) =>
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()


	nodeCompView = Backbone.Marionette.CompositeView.extend
		itemView: nodeView
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		id: "node"
		
		
		
		
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el) 

	
	Meshable.vent.on "goto:nodeRefresh", (mac, idn) ->
		
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		window.forge.ajax
			url: Meshable.rooturl + "/api/gateway"
			data: {  macaddress: mac, nodeid: idn  }
			dataType: "json"
			type: "GET"
			error: (e) -> 
				alert "An error occurred while getting node details... sorry!"
			success: (data) =>
				if data.isAuthenticated == false
					alert "auth:logout"
				else if data.length == 0
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					alert "No nodes at this location"
					Backbone.history.navigate "gateways", trigger : false , replace: true
				else
					displayResults data
	
	
	Meshable.vent.on "goto:node", (model) ->
		
	
		displayResults model
		
		
	

	
	
					
	displayResults = (data) ->
		
		# check here to see if we are a mc3, mc3z, mc13, or mc13z or gate and so on
		
		nodeCollection = new nodes

		tempNode = new node
		nodeCollection.add tempNode.parse(data)
		nodeCoView = new nodeCompView
			collection: nodeCollection
	
		
		
		

			
		Meshable.currentpage = "node"
		
		nodeCoView.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(nodeCoView.el))
		$("#mainDiv").trigger('create')
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		$("#mainPage a").removeClass('ui-btn-active')
		$("#nodesbtnn").addClass('ui-btn-active')
				
		
		
		
					
				
				
				
		

		
			
	