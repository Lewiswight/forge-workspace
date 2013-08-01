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
		onRender: ->
			for select in $(@.el).find("select")
				datasend = $('option:selected', select).attr 'data-send'
				if typeof datasend isnt 'undefined'
					#match the model property with the option
					selectedval = @model.get("channels")[$(select).attr("data-name")].value
					$(select).val($(select).find("[data-send=" + selectedval + "]").val())
				else
					if ($(select).attr("data-name"))
						selectedval = @model.get("channels")[$(select).attr("data-name")].value
						$(select).val($(select).find("[value=" + selectedval + "]").val())
            
            
			
			
		events:
			#"click #mistBtn": "mist"
			#"click #stopBtn": "stop"
			"click .setstatic": "setbutton"
			"slidestop .slider": "sliderSet"
			"change .select_set": "selectSet"
			
		selectSet:(e) ->
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			value = e.currentTarget.value
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

		sliderSet:(e) ->
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			value = e.currentTarget.value
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
		
		setbutton: (e) ->
			$('#mainDiv').removeClass($.mobile.activeBtnClass)
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

			forge.request.ajax
				url: Meshable.rooturl + "/api/channel"
				data:  JSON.stringify({macaddresses: [@model.attributes.macaddress], channelDTO: channels})
				dataType: "json"
				type: "POST"
				timeout: 15000
				contentType: 'application/json; charset=utf-8'
				error: (e) ->
					$("body").removeClass('ui-disabled') 
					$.mobile.hidePageLoadingMsg()
					forge.notification.alert("Error", e.message)
					$(".ui-btn-active").removeClass('ui-btn-active') 
				success: (data) =>
					if data[0].erroronset != null
						forge.notification.alert("Error", data[0].erroronset)
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					$(".ui-btn-active").removeClass('ui-btn-active')


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
		forge.request.ajax
			url: Meshable.rooturl + "/api/gateway"
			data: {  macaddress: mac, nodeid: idn  }
			dataType: "json"
			type: "GET"
			timeout: 15000
			error: (e) -> 
				forge.notification.alert("Error", e.message) 
				$.mobile.hidePageLoadingMsg()
				$("body").removeClass('ui-disabled')
				window.history.back()
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
	
	
	Meshable.vent.on "goto:node", (model) ->
		
	
		displayResults model
		
		
	

	
	
					
	displayResults = (data) ->
		
		# check here to see if we are a mc3, mc3z, mc13, or mc13z or gate and so on
		data[0].userRole = Meshable.userRole
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
		if data[0].problems.length > 0
			for problem in data[0].problems
				if problem.level == "RED"
					$("#results_insert").prepend("<li style='background-color: lightcoral;'>" + problem.message + "</li>")
				#else
				#	$("#results_insert").prepend("<li style='background-color: lightyellow;'>" + problem.message + "</li>")	
				$("#mainDiv").trigger('create')
		#$('html, body').animate({scrollTop: 0}, 0)
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')

	
				
		
		
		
					
				
				
				
		

		
			
	