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
		#initialize: ->
		defaults:
			searchInput: ""
		setInput: (msg) ->
			@set
				searchInput: msg
			    
			
			
		
	collections = Backbone.Collection.extend
		model: search_prop	
	


	searchsView = Backbone.Marionette.ItemView.extend
		initialize: (options) ->
			

				
			
			@template = options.model.attributes.template
			
			@bindTo @model, "change", @render
			
		
			
		#template: '#dashboarditem-template'
		tagName: 'li'
		className: "list_item"
		
		
		events: 
			
			"click #search-btn": "update"
			#"click #menu_back_btn": "menu_back"

			
		update: ->
			searchField = $('#search-main').val()
			if searchField.length < 1
				alert "Please Enter Text"
			else
				href = "#searching/" + searchField
				window.location = href
				#route = "searching/" + searchField
				#Backbone.history.navigate route, trigger : true , replace: false, pushState: false
				#Meshable.vent.trigger "search:gateways", searchField
		
		
			
		
		


	searchView = Backbone.Marionette.CompositeView.extend
		itemView: searchsView
		
		itemViewOptions: @model
			
		
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		#id: "search"				
					
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el) 

	
		
	Meshable.vent.on "goto:search", ->
		
		
	
		search = new searchView
			collection: make_collection()
			

				
		Meshable.currentpage = "search"
		
		search.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(search.el))
		$("#mainDiv").trigger('create')
		#$("#body").trigger("create")
		#Meshable.changePage search, false
		$("#mainPage a").removeClass('ui-btn-active')
		$("#searchbtnn").addClass('ui-btn-active')
		
		
	
		
	
	
	
		
	
	
	 		
	 		
