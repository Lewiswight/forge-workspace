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
				@template = '#nodeitem-' + node.model.attributes.nodetemplate

			
			
			
			
		
		tagName: 'li'
		className: "list_item_node"
		onRender: ->
			$("#mainDiv").trigger('create')
		
		events:
			"click #add10": "add10Items"
			"click #list_item_node": "pop"
			
			
		
		
		pop: ->
			$("#popupBasic").popup()
		
		add10Items: ->
			if not forge.is.connection.connected()
				forge.notification.alert("Failed to Load", "No Internet Connection")
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
				return
			Meshable.current_index += 1
			LoadTenMore Meshable.current_index, Meshable.current_searchTerm
			@model.destroy()
		
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
		
		forge.topbar.show(
		  ->
			console.log "hi"
		, (e) ->
			console.log e
		)
		
		forge.tabbar.show(
		  ->
			console.log "hi"
		, (e) ->
			console.log e
		)
		
		
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		
		if routerObj != ""
			displayResults routerObj
			return
		
		if not refresh and Meshable.current_units != "" and Meshable.refreshUnits == false
			showResults Meshable.current_units
			return
		
		#if not refresh and Meshable.currentDataObj != ""
		#		displayResults Meshable.currentDataObj
		#		return
		
		
		
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		
		
		Meshable.current_index = 0
		
		
		if not forge.is.connection.connected()
			forge.notification.alert("Failed to Load", "No Internet Connection")
			$("body").removeClass('ui-disabled')
			$.mobile.hidePageLoadingMsg()
			window.history.back()
			return
		
		
		forge.request.ajax
			url: Meshable.rooturl + "/api/Locations"
			data: { term: Meshable.current_searchTerm, systemTypes: "", problemStatuses: "", customGroups: "", pageIndex: 0, pageSize: 10 }
			dataType: "json"
			type: "GET"
			timeout: 15000
			error: (e) -> 
				forge.notification.alert("Error", e.message) 
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
				window.history.back()
			success: (data) =>
				dataObj = new Object 
				dataObj.list = []
				data = data.CurrentPageListItems
				for node in data
					node.person.userRole = Meshable.userRole
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
				Meshable.currentDataObj = dataObj
				Meshable.refreshUnits = false
				if data.isAuthenticated == false
					Backbone.history.navigate "logout", replace: false, trigger: true
				else if data.length == 0
					forge.notification.alert("No Results", "") 
					$.mobile.hidePageLoadingMsg()
					$("body").removeClass('ui-disabled')
				else
					displayResults dataObj
					
	 

	
	displayResults = (dataObj) ->
		Meshable.refreshUnits = false
		Meshable.current_units = new nodes 
		listlen = dataObj.list.length
		count = 0
		
		if not forge.is.connection.connected()
			forge.notification.alert("Failed to Load", "No Internet Connection")
			$("body").removeClass('ui-disabled')
			$.mobile.hidePageLoadingMsg()
			return
		
		for obj in dataObj.list
			
			do (obj) ->
		
				$.mobile.showPageLoadingMsg("a", "Loading", false)
				forge.request.ajax
					url: Meshable.rooturl + "/api/gateway"
					data:  macaddress: obj.gateway.macaddress
					dataType: "json"
					type: "GET"
					timeout: 25000
					error: (e) -> 
						count += 1
						if count >= listlen
							tempNode = new nodea { 
								nodetemplate: "add"
								}
							Meshable.current_units.add tempNode
							showResults Meshable.current_units
					success: (data) =>
						if data.isAuthenticated == false
							Backbone.history.navigate "logout", replace: false, trigger: true
						else
							tempNode = new nodea { 
								first: obj.person.first
								nodetemplate: "header"
								last: obj.person.last
								phone1: obj.person.phone1
								mac: obj.gateway.macaddress
								}
							Meshable.current_units.add tempNode
							
							for obja in data
								obja.person = new Object
								obja.person = obj.person
								obja.address = new Object
								obja.address = obj.address
								if obja.nodetemplate != "mainMistaway"
									tempNode = new nodea
									Meshable.current_units.add tempNode.parse(obja)
							count += 1
							if count >= listlen
								if count > 1
									tempNode = new nodea { 
										nodetemplate: "add"
										}
									Meshable.current_units.add tempNode
								showResults Meshable.current_units
								
									
				
		
	
		
		
						
		
			
			
	showResults = (temp) ->
		hi = temp
		Meshable.nodeCoView = new nodeCompView
			collection: Meshable.current_units
	
		
		
 		
	
					
		Meshable.currentpage = "units"
		#$('#mainDiv').hide()
		
		Meshable.nodeCoView.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(Meshable.nodeCoView.el))
		$("#mainDiv").trigger('create')
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		
		Meshable.unitsButton.setActive()
		if Meshable.backplace != ""
				$('html, body').animate({scrollTop: $(Meshable.backplace).offset().top}, 0)
				Meshable.backplace = ""
		#Meshable.changePage nodeCoView, false

	
	LoadTenMore = (index, searchTerm) ->
		
		
		
		$("body").addClass('ui-disabled')
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		
		Meshable.current_searchTerm = searchTerm
		Meshable.current_index = index
		
		forge.request.ajax
			url: Meshable.rooturl + "/api/Locations"
			data: { term: searchTerm, systemTypes: "", problemStatuses: "", customGroups: "", pageIndex: index, pageSize: 10 }
			dataType: "json"
			type: "GET"
			timeout: 10000
			error: (e) -> 
				forge.notification.alert("Error", e.message) 
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
			success: (data) =>
				dataObj = new Object 
				dataObj.list = []
				data = data.CurrentPageListItems
				for node in data
					node.person.userRole = Meshable.userRole
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
				Meshable.currentDataObj = dataObj
				Meshable.refreshUnits = false
				if data.isAuthenticated == false
					Backbone.history.navigate "logout", replace: false, trigger: true
				else if data.length == 0
					forge.notification.alert("No More Results", "") 
					$.mobile.hidePageLoadingMsg()
					$("body").removeClass('ui-disabled')
				else
					Meshable.refreshUnits = false
					listlen = dataObj.list.length
					count = 0
					modelList =[]
					for obj in dataObj.list
						
						do (obj) ->
					
							$.mobile.showPageLoadingMsg("a", "Loading", false)
							forge.request.ajax
								url: Meshable.rooturl + "/api/gateway"
								data:  macaddress: obj.gateway.macaddress
								dataType: "json"
								type: "GET"
								timeout: 25000
								error: (e) -> 
									count += 1
									if count >= listlen
										tempNode = new nodea { 
											nodetemplate: "add"
											}
										modelList.push(tempNode)
										for model in modelList
											Meshable.current_units.add model
										showResults10 Meshable.current_units, true
								success: (data) =>
									if data.isAuthenticated == false
										Backbone.history.navigate "logout", replace: false, trigger: true
									else
										tempNode = new nodea { 
											first: obj.person.first
											nodetemplate: "header"
											last: obj.person.last
											phone1: obj.person.phone1
											mac: obj.gateway.macaddress
											}
										modelList.push(tempNode)
										#Meshable.current_units.add tempNode
										
										for obja in data
											obja.person = new Object
											obja.person = obj.person
											obja.address = new Object
											obja.address = obj.address
											if obja.nodetemplate != "mainMistaway"
												tempNode = new nodea
												tempNode1 = tempNode.parse(obja)
												modelList.push(tempNode1)
												
												
										count += 1
										if count >= listlen
											tempNode = new nodea { 
												nodetemplate: "add"
												}
											modelList.push(tempNode)
											for model in modelList
												Meshable.current_units.add model
											showResults10 Meshable.current_units, true
											
							
	showResults10 = (temp, go) ->
		hi = temp			
		Meshable.currentpage = "units"
		$('#mainDiv').empty()
		Meshable.nodeCoView.render()
		$('#mainDiv').append($(Meshable.nodeCoView.el))
		$("#mainDiv").trigger('create')
		#Meshable.unitsButton.setActive()
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		
		
		



	
