define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	make_collection = ->
		
		nodeCollection = new collections [
			new search_prop { 
				template: "#search-template" 
				
				}
			#new search_prop {
				#template: "#search-fileds-template" 
				#image_path: "images/cat2.jpg"
				#}
			#new search_prop {
				#template: "#search-fileds-template"
				#image_path: "images/cat3.jpg"
				#}
			
			]
		return nodeCollection
	
	search_prop = Backbone.Model.extend 		
		initialize: ->    
			
			
		
	collections = Backbone.Collection.extend
		model: search_prop	
	


	searchsView = Backbone.Marionette.ItemView.extend
		initialize: (options) ->
			@template = options.model.attributes.template
			
			@bindTo @model, "change", @render
			
			
		#template: '#dashboarditem-template'
		tagName: 'li'
		className: "list_item"
		
		
			
		
		


	searchView = Backbone.Marionette.CompositeView.extend
		itemView: searchsView
		
		itemViewOptions: @model
			
		
		template: "#wrapper_dashboard"
		itemViewContainer: "ul"
		id: "search"
		
		
		
		#events: 
			
			#"click #back-btn1": "back"
			#"click #menu_back_btn": "menu_back"

			
		#menu_back: ->
			#$("#popupPanel").popup("close")
		#back: ->
			#window.history.back()
		
		#popmenu: ->
			
			#$("#popupPanel").on popupbeforeposition: ->
				#h = $(window).height()
				#$("#popupPanel").css "height", h

			#$("#popupPanel").popup("open")
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#dashboard_insert").append(itemView.el) 

	
		
	return new searchView
		collection: make_collection()	
	
	
	 		
	 		
	###myvent.on "router:appStart", ->
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
		Meshable.footerRegion.show ###