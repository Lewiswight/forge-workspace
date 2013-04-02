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
			$.mobile.showPageLoadingMsg()
			value = $(e.target).parent().data 'setvalue'		
			node_type = $(e.target).parent().data 'nodetype'
			channel = $(e.target).parent().data 'channel'
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
			mac[0] = Meshable.currentMac
			#add validation
			#find the channels that need to be set 

			window.forge.ajax
				url: Meshable.rooturl + "/api/channel"
				data:  JSON.stringify({macaddresses: [Meshable.currentMac], channelDTO: channels})
				dataType: "json"
				type: "POST"
				contentType: 'application/json; charset=utf-8'
				error: (e) -> 
					$.mobile.hidePageLoadingMsg()
					#alert "An error occurred while getting node details... sorry!"
				success: (data) =>
					$.mobile.hidePageLoadingMsg()


	nodeCompView = Backbone.Marionette.CompositeView.extend
		itemView: nodeView
		template: "#wrapper_dashboard"
		itemViewContainer: "ul"
		id: "node"
		
		
		
		
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#dashboard_insert").append(itemView.el) 

	
	
	Meshable.vent.on "goto:node", (model) ->
		
					
		displayResults model
		
		
	

	
	
					
	displayResults = (data) ->
		
		# check here to see if we are a mc3, mc3z, mc13, or mc13z
		
		nodeCollection = new nodes

		tempNode = new node
		nodeCollection.add tempNode.parse(data)
		nodeCoView = new nodeCompView
			collection: nodeCollection
	
		
		
		

			
		Meshable.currentpage = "node"
		
		nodeCoView.render()
		$('#node').empty()
		$('#node').append($(nodeCoView.el))
		Meshable.changePage nodeCoView, false
		
		
		
					
				
				
				
		

		
			
	