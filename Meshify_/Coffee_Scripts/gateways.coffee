define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events', 'async!http://maps.google.com/maps/api/js?sensor=true'], ($, jqm, Backbone, _, Marionette, Meshable, Events ) ->									 
	
	Meshable.vent.on "showmap", ->
		if Meshable.currentMap is null
			Meshable.locationButton.setActive()
			bindmap = (center) ->
				Meshable.vent.trigger 'maps:bind', 
					mapContainerId: 'mapwrapper'
					mapOpts: 
						center: center
						zoom: 12
						mapTypeId: google.maps.MapTypeId.ROADMAP 
					#onMapBound: (mapview) ->
					#	console.log('on onMapBound callback')
					#	mainlocationlayoutglobal.listmapRegion.show mapview
					#	console.log('after onMapBound callback')
					onMapRendered: () ->
						console.log('on onMapRendered callback')
						forge.request.ajax
							url: Meshable.rooturl + '/api/locations?term=' + Meshable.current_searchTerm 
							type: "GET"
							dataType: "json"
							timeout: "10000"
							contentType: 'application/json; charset=utf-8'
							error: (e) -> 
								$("body").removeClass('ui-disabled')
								$.mobile.hidePageLoadingMsg()
								forge.notification.alert("Error", e.message) 
								Meshable.router.navigate "", trigger : true
							success: (data) ->
								Meshable.vent.trigger('maps:addmarkers', { items: data })
								
					
			
			 
			forge.geolocation.getCurrentPosition(
				"enableHighAccuracy": true 
			,  (position) ->
				#alert position.coords.latitude
				#alert position.coords.longitude
				#alert position.timestamp
				center = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
				bindmap(center)
				
			,  (e) ->
				center = new google.maps.LatLng(29.7631, -95.3631)
				bindmap(center)
					 
			)
		else
			$('#mainDiv').empty()
			$('#mainDiv').append(Meshable.currentMap)
			$("mainDiv").trigger('create')
			$.mobile.hidePageLoadingMsg()
			$("body").removeClass('ui-disabled')
			console.log('maps bound')
			google.maps.event.trigger(map, 'resize')
			

		
	locationmaps = null
	geocoder = null
	mapOpts = null
	onMapBound = null
	onMapRendered = null
	markers = []


	#possible options attributes: onMapBound, onMapRendered, onAddingMarker, containerEl, mapContainerId, mapOpts
	Meshable.vent.on 'maps:bind', (options) ->
		console.log('binding maps')
		mapOpts = options.mapOpts
		onMapBound = options.onMapBound
		onMapRendered = options.onMapRendered
		map = new Map
		mapView = new MapView
			model: map

		
		
		#mc = new MarkerClusterer(locationmaps)
		#mapRegion.show(mapView) 
		
			
		if onMapBound != null && onMapBound != undefined
			onMapBound(mapView)
		google.maps.event.addListener map, "bounds_changed", ->
  			bounds = map.getBounds()
  			google.maps.event.trigger(map, 'resize')
		
		
		mapView.render()
		Meshable.currentMap = $(mapView.el)
		$('#mainDiv').empty()
		$('#mainDiv').append($(mapView.el))
		$("mainDiv").trigger('create')
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		console.log('maps bound')
		google.maps.event.trigger(map, 'resize')


	Meshable.vent.on 'maps:geocode', (options) ->
		console.log('geocoding')
		state = ''
		if options.address.country && options.address.country.toLowerCase() == 'us' then state = options.address.state
		fromaddress = [ options.address.street1, ', ', options.address.street2, ', ', options.address.city, ', ', state, ', ', options.address.country, ', ', options.address.zip ].join()
		geocoderRequest = 
			address: fromaddress 
		geocoder = new google.maps.Geocoder()
		geocoder.geocode(geocoderRequest, options.callback)

	latlngbounds = null;

	Meshable.vent.on 'maps:addmarkers', (obj) ->
		if obj.beforeAddMarkers != null && obj.beforeAddMarkers != undefined
			obj.beforeAddMarkers(locationmaps, markers) 

		console.log('adding ' + obj.items.length + ' markers')
		for i in [0...obj.items.length]
			Meshable.vent.trigger('maps:addmarker', obj.items[i])
		#Uncomment to have the map clusters, DOTO: get all grey images for the clusters and set the max zoom and cluster size pretty big
		#mc = new MarkerClusterer(locationmaps, markers)
		return

	Meshable.vent.on 'maps:addmarker', (obj) ->
		console.log('adding marker')
		console.log(obj)
		if (obj.address.latitude == 0 || obj.address.longitude == 0)
			console.log('aborting marker addition, latlng is null')
			return false

		if obj.nodecolors.statuscolor == "GREEN"
			thisorigin = new google.maps.Point 4, 290
		else if obj.nodecolors.statuscolor == "YELLOW"
			thisorigin = new google.maps.Point 4, 345
		else if obj.nodecolors.statuscolor == "RED"
			thisorigin = new google.maps.Point 4, 231
		#TO DO: implement blue in the sprite
		else if obj.nodecolors.statuscolor == "BLUE"
			thisorigin = new google.maps.Point 4, 398
		else
			thisorigin = new google.maps.Point 4, 398

		thisicon = new Object
			url: "https://s3.amazonaws.com/LynxMVC4-Bucket/themes/mistaway/sprite.png"
			#url: "http://localhost:22164/Content/sprite.png"
			size: new google.maps.Size 33, 44, "px", "px"
			origin: thisorigin
			#scaledSize: new google.maps.Size 450, 450, "px", "px"								
		
		position = new google.maps.LatLng(obj.address.latitude, obj.address.longitude)
		thismarker = new google.maps.Marker
			map: locationmaps
			position: position
			icon: thisicon
		#console.log(thismarker)
		markers.push(thismarker)
		if latlngbounds
			latlngbounds.extend(position);

		clickfunction = (gmapMouseEvent)->
			Meshable.vent.trigger 'maps:marker:clicked', obj
		#clickfunction = ->
		#	Meshable.vent.trigger "mapclicked", obj.gateway.macaddress
		google.maps.event.addListener thismarker, "click", clickfunction
		##locationmapsMarkers.push thismarker
		console.log('marker added')


	Meshable.vent.on 'maps:marker:clicked', (model) ->
		alert "clicked"
		#Meshable.vent.trigger 'locationList:showDetail',
			#model: model
	

	Map = Backbone.Model.extend
		defaults:
			dummy: "dummy"

	MapView = Backbone.Marionette.ItemView.extend
		initialize: ->
			console.log('initialize map view')
		onRender: ->
			console.log('on MapView render')
			setTimeout (->
				mapContainerId = 'mapwrapper'
				locationmaps = new google.maps.Map(document.getElementById(mapContainerId), mapOpts)
				latlngbounds = new google.maps.LatLngBounds()
				if onMapRendered != null && onMapRendered != undefined
					onMapRendered()

			), 750
			console.log('after MapView render')
			
		addmarker: (obj) ->
			Meshable.vent.trigger 'maps:addmarker', obj
		template: maptemplate
		doGeocoding: (obj, myfunc) ->