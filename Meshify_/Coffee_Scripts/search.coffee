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
			if not forge.is.connection.connected()
				forge.notification.alert("Failed to Load", "No Internet Connection")
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
				return
			
			includeUnits =  $('#include-units').prop("checked")
			resultType = $('#flip-3').val()
			searchField = $('#search-main').val()
			
			param = new Object {
				search: searchField
				
			}
			forge.flurry.customEvent(
				"start up"
				param
			, ->
				console.log "set sent to flury"
			, (e) ->
				console.log e
			)
			
			
			if searchField == ""
				searchField = "_"
			route = "#searching/" + searchField + "/" + resultType
			Backbone.history.navigate route, trigger : true , replace: false, pushState: false

		
		
			
		
		


	searchView = Backbone.Marionette.CompositeView.extend
		itemView: searchsView
		
		itemViewOptions: @model
			
		
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		#id: "search"				
					
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el) 

	
		
	Meshable.vent.on "goto:search", ->
		
		
		Meshable.searchButton.setActive()
		search = new searchView
			collection: make_collection()
			

				
		Meshable.currentpage = "search"
		
		search.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(search.el))
		$("#mainDiv").trigger('create')
		#$("#body").trigger("create")
		#Meshable.changePage search, false
		
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		
		
	
		
	
	
	
		
	
	
	 		
	 		
