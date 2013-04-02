define ['jquery','backbone','underscore','marionette', 'Meshable', 'Events'], ($, Backbone, _, Marionette, Meshable, Events) ->		 
	dashboard = Backbone.Model.extend 		
		initialize: -> 
			@set
				trafficlight: Meshable.chooseLight @get('trafficlight')		
		defaults: 				 				
			channelname: "Energy Costs"
			status: ""
			address: "123 Main St." 
			value: "1100.50"
			pre: "$"		
			post: ""
			trafficlight: "green" 	
		
	dashboards = Backbone.Collection.extend
		model: dashboard	
		url: ->
			Meshable.rooturl + "/api/dashboard"
		initialize: (dashboards) ->
			@fetch()


	dashboardView = Backbone.Marionette.ItemView.extend
		#initialize: ->
		template: '#dashboarditem-template'
		tagName: 'li'
		#className: 'angry_cat'
		#events:
			#"click .rank_down img": "rankDown"

	#dashboardCollection = Backbone.Marionette.CollectionView.extend
		#itemView: dashboardView

	dashboardsView = Backbone.Marionette.CompositeView.extend
		itemView: dashboardView
		template: "#dashboard-template"
		itemViewContainer: "ul"

	myvent.on "router:appStart", ->
		Meshable.loginRegion.close()
		Meshable.addRegions
			themeRegion: "#csstheme"
			headerRegion: "#header"
			col1Region: ".col1"
			col2topRegion: ".col2top"
			col2bottomRegion: ".col2bottom"
			col3Region: ".col3"
			col4Region: ".col4"
			footerRegion: "#footer"
		$('#header').css 'display', 'block'		
		$('#footer').css 'display', 'block'
		$('.colmask').css 'display', 'block'
		dashboardsCollection = new dashboards
		dashboardCompositeView = new dashboardsView
			collection: dashboardsCollection
		Meshable.col1Region.show dashboardCompositeView
		Meshable.themeRegion.show 
		Meshable.headerRegion.show 
		Meshable.col2topRegion.show 
		Meshable.col2bottomRegion.show 
		Meshable.col3Region.show 
		Meshable.col4Region.show 
		Meshable.footerRegion.show 

		