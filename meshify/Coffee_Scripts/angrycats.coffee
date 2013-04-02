define ["jquery", "backbone", "underscore", "marionette", "Meshable", "Events"], ($, Backbone, _, Marionette, Meshable, Events) ->             
	
	$(document).ready ->
		cats_collection = new AngryCats [
			new AngryCat { 
				name: "Wet Cat" 
				image_path: "images/cat1.jpg"
				}
			new AngryCat {
				name: "Bitey Cat" 
				image_path: "images/cat2.jpg"
				}
			new AngryCat {
				name: "Surprised Cat"
				image_path: "images/cat3.jpg"
				}
		]
#		Meshable.start(
#			cats: cats_collection 
#			)

		cats_collection.add new AngryCat 
			name: "Another Cat"
			image_path: "images/cat4.jpg" 
			rank: cats_collection.size() + 1  
			
		Meshable.angryCatsView = new AngryCatsView
			collection: cats_collection 
	
		
			
				
	Meshable.start_up = ->
		Meshable.loginRegion.show Meshable.angryCatsView
	  

	    	 
    	
                        
	AngryCat = Backbone.Model.extend
		defaults: 
			votes : 0                     
		rankUp: ->
			@set( 
				rank: @get('rank') - 1
			)
		rankDown: ->
			@set(
				rank: @get('rank') + 1
			)
		addVote: -> 
			@set(
				votes: @get('votes') + 1 
			) 

	AngryCats = Backbone.Collection.extend
		model: AngryCat    
		rankUp: (cat) ->
			rankToSwap = cat.get('rank') - 1
			otherCat = @at(rankToSwap - 1) 
			cat.rankUp()
			otherCat.rankDown()
		rankDown: (cat) ->
			rankToSwap = cat.get('rank') + 1
			otherCat = @at(rankToSwap - 1)            
			cat.rankDown()
			otherCat.rankUp()
		comparator: (cat) ->
			cat.get('rank')                
		initialize: (cats) ->
			rank = 1
			for cat in cats
				cat.set('rank', rank)
				rank = rank + 1
			
			this.on "add", (cat) -> 
				if !cat.get 'rank'
					error = Error "Cat must have a rank defined before being added to the collection"
					throw error
			
			
			self = @
			
				
			Meshable.vent.on "rank:up", (cat) ->
				if cat.get("rank") == 1
					return true
				self.rankUp(cat)
				self.sort()          
			Meshable.vent.on "rank:down", (cat) ->
				if cat.get("rank") == self.size()
					return true
				self.rankDown(cat)    
				self.sort()
			Meshable.vent.on "cat:disqualify", (cat) ->
				dqrank = cat.get 'rank'
				catsToUprank = self.filter (localcat) -> 
					localcat.get('rank') > dqrank
				catsToUprank.forEach (cat) -> 
					cat.rankUp()
				self.trigger 'reset'
                        
	AngryCatView = Backbone.Marionette.ItemView.extend
		initialize: ->
			@bindTo @model, "change:votes", @render
		template: '#angry_cat-template'
		tagName: 'tr'
		className: 'angry_cat'
		events:
			"click .rank_down img": "rankDown"
			"click .rank_up img": "rankUp"
			"click a.disqualify": "disqualify"
		
		rankUp: ->
			Meshable.vent.trigger "rank:up", @model
			@model.addVote()
		rankDown: ->
			Meshable.vent.trigger "rank:down", @model
			@model.addVote()
		disqualify: -> 
			Meshable.vent.trigger "cat:disqualify", @model 
			@model.destroy()
			Meshable.router.navigate "somewhere", trigger : true

	AngryCatsView = Backbone.Marionette.CompositeView.extend
		tagName: "table"
		id: "angry_cats"
		className: "table-striped table-bordered"
		template: "#angry_cats-template"
		itemView: AngryCatView
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("tbody").append(itemView.el)    
                    
#	Meshable.addInitializer (options) ->
#		angryCatsView = new AngryCatsView
#			collection: options.cats
#		Meshable.mainRegion.show(angryCatsView)

