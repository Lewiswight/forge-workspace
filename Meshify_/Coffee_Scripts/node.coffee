define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events', 'goog!visualization,1,packages:[corechart,geochart,gauge]'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	
		
	
			
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
			
		tagName: 'li'
		onRender: ->
			
  				
			Date::getHtml5String = ->
			 	year = @getFullYear() + "-"  
			 	month = (@getMonth()+1) + "-"  
			 	day = @getDate()
			 	day = day.toString()
			 	if month.length == 2
			 		month = ("0" + month)
			 	if day.length == 1
			 		day = ("0" + day)
			 	return (year + month + day)
			

			for input in $(@.el).find("input")
				
				if input.id == "toDate"
					$(input).val(new Date().getHtml5String())
				if input.id == "fromDate"
					daysBack = $(input).attr("data-daysofhistory")
					d = new Date()
					d = Math.floor(d)
					d = (d - (parseInt(daysBack) * 86400000))
					fromDate = new Date(d).getHtml5String()
					$(input).val(fromDate)

				
			
			for div in $(@.el).find("div")
				
				
				
				if $(div).attr("data-chart") == "chart"
					
					nodeName = $(div).attr("data-nodename")
					nodeId = @model.attributes.node.NodeId
					chanId = @model.attributes.channels[nodeName].ChannelId
					
					c1 = new Date()
					c = c1.toString()
					c = c.split(" ")
					#alert (c[2] + " " + c[1] + " " + c[3])
					c2 = (c1.getTime() / 1000)
					c2 = Math.floor( c2 )
					c2 = c2.toString()
		
					
					
					daysBack = $(div).attr("data-daysofhistory")
					
					d1 = new Date()
					d1 = (d1.getTime() / 1000)
					d1 = Math.floor( d1 )
					d1 = (d1 - (parseInt(daysBack) * 86400))
					d1 = d1.toString()
					
					
					
					drawChart(div, c2, d1, nodeId, chanId)	
					
					
					
				if $(div).attr("data-chart") == "gauge"
					
					drawGauge(div)

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
            
            
			
			
		setvalue: (val, data, chart, options) -> 
			data.setValue(0, 1, parseInt(val))
			chart.draw data, options
			
		events:
			#"click #mistBtn": "mist"
			#"click #stopBtn": "stop"
			"click .setstatic": "setbutton"
			"slidestop .slider": "sliderSet"
			"change .select_set": "selectSet"
			"click #chart-update": "chartUpdate"
			"click .print": "print"
			
		
		
		print: (e) ->
			
			param = new Object {
				set: (($(e.currentTarget).data "channel") + "-" + ($(e.currentTarget).data "setvalue"))
				
			}
			forge.flurry.customEvent(
				"start up"
				param
			, ->
				console.log "set sent to flury"
			, (e) ->
				console.log e
			)
			$('#mainDiv').removeClass($.mobile.activeBtnClass)
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			value = $('#printInput').val()
			alert value
			node_type = $(e.currentTarget).data "nodetype"	
			channel = $(e.currentTarget).data "channel" 
			full_name = node_type + "." + channel
			mistData = new Array
			#alert @model.attributes.channels[full_name].ChannelId
			#alert @model.attributes.node.NodeId
			localobj = 
				ChannelId: @model.attributes.channels[full_name].ChannelId
				value: value
				techName: @model.attributes.channels[full_name].techName
				name: full_name
				mqtt: "true"
			mistData[0] = localobj
			@setChannel mistData
		
		
		chartUpdate: (e) ->
			if $("#fromDate").val() == "" or $("#toDate").val() == ""
				forge.notification.alert("Error", "You must enter both a start and end date for the graph")
				return

			for div in $('div', @.el)
				if $(div).attr("data-chart") == "chart"
					
					$("body").addClass('ui-disabled') 
					$.mobile.showPageLoadingMsg("a", "Loading", false)
					
					dateString = $("#toDate").val().replace(/-/g, "/")	
					c1 = new Date(dateString)
					c2 = (c1.getTime() / 1000)
					c2 = Math.floor( c2 )
					c2 = c2.toString()
					
					dateString = $("#fromDate").val().replace(/-/g, "/")
					d1 = new Date(dateString)
					d1 = (d1.getTime() / 1000)
					d1 = Math.floor( d1 )
					d1 = d1.toString()
					
					nodeName = $(div).attr("data-nodename")
					
					nodeId = @model.attributes.node.NodeId
					chanId = @model.attributes.channels[nodeName].ChannelId
					
					drawChart(div, c2, d1, nodeId, chanId)
					
		
		selectSet:(e) ->
			param = new Object {
				set: (($(e.currentTarget).data) "channel" + "-" +  (e.currentTarget.value))
				
			}
			forge.flurry.customEvent(
				"start up"
				param
			, ->
				console.log "set sent to flury"
			, (e) ->
				console.log e
			)

			
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
			
			param = new Object {
				set: (($(e.currentTarget).data "channel") + "-" +  (e.currentTarget.value))
				
			}
			forge.flurry.customEvent(
				"start up"
				param
			, ->
				console.log "set sent to flury"
			, (e) ->
				console.log e
			)

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
			
			param = new Object {
				set: (($(e.currentTarget).data "channel") + "-" + ($(e.currentTarget).data "setvalue"))
				
			}
			forge.flurry.customEvent(
				"start up"
				param
			, ->
				console.log "set sent to flury"
			, (e) ->
				console.log e
			)
			$('#mainDiv').removeClass($.mobile.activeBtnClass)
			$("body").addClass('ui-disabled')
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			value = $(e.currentTarget).data "setvalue"
			node_type = $(e.currentTarget).data "nodetype"	
			channel = $(e.currentTarget).data "channel" 
			full_name = node_type + "." + channel
			mistData = new Array
			#alert @model.attributes.channels[full_name].ChannelId
			#alert @model.attributes.node.NodeId
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
				timeout: 25000
				contentType: 'application/json; charset=utf-8'
				error: (e) ->
					Meshable.loading = false
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
					Meshable.loading = false
					Meshable.vent.trigger "goto:refresh"


	nodeCompView = Backbone.Marionette.CompositeView.extend
		itemView: nodeView
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		id: "node"
		
		
		
		
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el) 

	
	Meshable.vent.on "goto:nodeRefresh", (mac, idn, first, last, phone1, city, state, street1, zip) ->
		
		
		
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
				Meshable.loading = false
				window.history.back()
			success: (data) =>
				if data.isAuthenticated == false
					alert "auth:logout"
				else if data.length == 0
					Meshable.loading = false
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					forge.notification.alert("No units at this location", "") 
					Backbone.history.navigate "gateways", trigger : false , replace: true
				else
					data[0].person = new Object {
						first: first
						last: last
						phone: phone1
						city: city
						state: state
						street: street1
						zip: zip
					}
					data[0].company = new Object {
						name: Meshable.company.name
						zip: Meshable.company.zip
						city: Meshable.company.city
						state: Meshable.company.state
						street: Meshable.company.street
						email: Meshable.company.email
						phone: Meshable.company.phone
						image: Meshable.company.image
					}
					displayResults data
	
	
	Meshable.vent.on "goto:node", (model) ->
		
	
		displayResults model
		
		
	
	drawGauge = (div) ->
		
		label1 = $(div).attr("data-label")
		duration1 = $(div).attr("data-duration")
		width1 = $(div).attr("data-width")
		height1 = $(div).attr("data-height")
		redFrom1 = $(div).attr("data-redfrom")
		redTo1 = $(div).attr("data-redto")
		yellowFrom1 = $(div).attr("data-yellowfrom")
		yellowTo1 = $(div).attr("data-yellowto")
		minorTicks1 = $(div).attr("data-minorticks")
		greenFrom1 = $(div).attr("data-greenfrom")
		greenTo1 = $(div).attr("data-greento")
		value = $(div).attr("data-value")
		min = $(div).attr("data-min")
		max = $(div).attr("data-max")
		
		
		data = google.visualization.arrayToDataTable([["Label", "Value"], [label1, 0]])
		options =
			animation:
				duration: parseInt(duration1)
				easing: 'inAndOut'
			width: parseInt(width1)
			height: parseInt(width1)
			redFrom: parseInt(redFrom1)
			redTo: parseInt(redTo1)
			yellowFrom: parseInt(yellowFrom1)
			yellowTo: parseInt(yellowTo1)
			minorTicks: parseInt(minorTicks1)
			greenFrom: parseInt(greenFrom1)
			greenTo: parseInt(greenTo1)
			min: parseInt(min)
			max: parseInt(max)
		    
		  
		# Create and draw the visualization.
		chart = new google.visualization.Gauge(div)
		chart.draw data, options
		
		data.setValue(0, 1, parseInt(value))
		chart.draw data, options
		
		Meshable.vent.on "update:guage", (val, timestamp) ->
			data.setValue 0, 1, parseInt(val)
			chart.draw data, options
			Meshable.vent.trigger "update:chart", val, timestamp

			IntVal = parseInt(val)
			
			percent = (IntVal / 1000)
			percent = percent * 100
			percent = Math.round(percent)
			

			#percent = parseInt(percent)
			#percent = percent.toSring()
			#alert percent
			$('#level-percent').html ("<b>Level: " + percent + "%</b>")

			$("#mainDiv").trigger('create')
			#d = new Date(0)
			#timeInt = parseInt(timestamp)
			#d.setUTCSeconds(timeInt)
		
		
		socket = io.connect("http://ws.meshify.com:80")
		socket.on "connect", ->
		
			socket.emit "subscribe",
		    	topic: "meshify/db/ctan/C49300007B94/apgus_[c4:93:00:00:7b:94:00:01]!/raw"
			socket.on "mqtt", (msg) =>
				msg.payload = $.parseJSON( msg.payload )
				
					
		    	#alert msg.topic + " " + msg.payload
		    	#dis = msg.payload.split(";")
		    	#alert parseInt(dis[0])
				Meshable.vent.trigger "update:guage", msg.payload[0].value, msg.payload[0].timestamp
		    	
		    	#data.setValue(0, 0, label1)
				#data.setValue(0, 1, parseInt(d[0]))
				#chart.draw data, options
	
	drawChart = (div, c2, d1, nodeId, chanId) ->
	
		
		dataLabel = $(div).attr("data-datalabel")
		chartLabel = $(div).attr("data-chartlabel")
		xLabel = $(div).attr("data-xlabel")
		
		data = new google.visualization.DataTable()
		data.addColumn('date', 'Date')
		data.addColumn('number', dataLabel)
		options =
			legend:
				position: "top"
			chartArea:{left:"15%",top:50,width:"80%",height:"50%"}
			animation:
				easing: "linear"
				duration: 1000
			title: chartLabel
			hAxis:
				title: xLabel
				titleTextStyle:
					color: "#333"
	
			vAxis:
				minValue: 0
	
		chart = new google.visualization.AreaChart(div)
		
		forge.request.ajax
			url: Meshable.rooturl + "/api/Nodechannels"
			data:  "nodelist[0][NodeId]=" + nodeId + "&nodelist[0][ChannelId]=" + chanId + "&start=" + d1 + "&end=" + c2
			dataType: "json"
			type: "GET"
			timeout: 15000
			error: (e) ->
				Meshable.loading = false
				$("body").removeClass('ui-disabled') 
				$.mobile.hidePageLoadingMsg()
				forge.notification.alert("Error", e.message)
				$(".ui-btn-active").removeClass('ui-btn-active') 
			success: (data1) =>
				first = true
				for sample in data1.listofstreams[0].Stream
					x = sample.x
					d = new Date(x*1000)
					#d.setTime(x*1000)
					y = sample.y
					#alert x
					#alert y
					
					
					data.addRow([d, y])
					if first
						first = false
						chart.draw data, options
						
				chart.draw data, options
				$("body").removeClass('ui-disabled') 
				$.mobile.hidePageLoadingMsg()
				
				Meshable.vent.on "update:chart", (val, timestamp) ->
					d = new Date(parseInt(timestamp)*1000)
					data.addRow([d, parseInt(val)])
					chart.draw data, options
					if data.getNumberOfRows() > 20
						data.removeRow(0)
					chart.draw data, options
				
				
			
	drawVisualization = ->
  
		# Create and populate the data table.
		data = google.visualization.arrayToDataTable([["Label", "Value"], ["Tank1", 80]])
		options =
		    width: 400
		    height: 120
		    redFrom: 95
		    redTo: 5
		    yellowFrom: 90
		    yellowTo: 10
		    minorTicks: 5
		  
		# Create and draw the visualization.
		chart = new google.visualization.Gauge($("#chart2")[0])
		return [chart, data, options]
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
		#chart = drawVisualization()
		#chart[0].draw chart[1], chart[2] 

		
		$("#mainDiv").trigger('create')
		if data[0].problems.length > 0
			for problem in data[0].problems
				if problem.level == "RED"
					$("#results_insert").prepend("<li style='background-color: lightcoral;'>" + problem.message + "</li>")
				else if Meshable.userRole == 1 and problem.level == "YELLOW"
					$("#results_insert").prepend("<li style='background-color: lightyellow;'>" + problem.message + "</li>")	
				else if Meshable.userRole == 1 and problem.level == "BLUE"
					$("#results_insert").prepend("<li style='background-color: lightblue;'>" + problem.message + "</li>")	
				$("#mainDiv").trigger('create')
		$('html, body').animate({scrollTop: 0}, 0)
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		Meshable.loading = false
		
	
				
		
		
		
					
				
				
				
		

		
			
	