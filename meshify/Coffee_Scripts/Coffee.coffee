MyApp = new Backbone.Marionette.Application();

MyApp.addRegions  
	mainRegion: "#content"



AngryCat = Backbone.Model.extend {
	
	rankUp: ->
		this.set(
			rank: this.get("rank") - 1
		)
	rankDown: ->
		this.set(
			rank :this.get('rank') + 1  
		)
}
	


AngryCats = Backbone.Collection.extend
	model: AngryCat
	initialize: (cats) ->
		rank = 1
		_.each cats, (cat) ->
	    	cat.set "rank", rank
	    	++rank
		
		self = this
		
		MyApp.vent.on "rank:up", (cat) ->
			return true  if cat.get("rank") is 1
			self.rankUp cat
			self.sort()  		
		
		MyApp.vent.on "rank:down", (cat) ->
			if (cat.get('rank') == self.size)
				return true
			self.rankDown(cat)	
			self.sort()
		
		
			
	comparator: (cat) ->
    	cat.get "rank"
	
	rankUp: (cat) ->
		rankToSwap = cat.get('rank') - 1
		otherCat = this.at(rankToSwap - 1)
		
		cat.rankUp()
		otherCat.rankDown()
		
	rankDown: (cat) ->
		rankToSwap = cat.get('rank') + 1
		otherCat = this.at(rankToSwap - 1)
		
		cat.rankDown()
		otherCat.rankUp() 

			
			
			
	

AngryCatView = Backbone.Marionette.ItemView.extend
	template: "#angry_cat-template"
	tagName: 'tr'
	className: 'angry_cat'
	
	events:
		"click .rank_up img": "rankUp"
		"click .rank_down img": "rankDown"
		
	rankUp: ->
		MyApp.vent.trigger("rank:up", this.model)
		
	rankDown: ->
		MyApp.vent.trigger("rank:down", this.model)
		
	
AngryCatsView = Backbone.Marionette.CompositeView.extend
	tagName: "table"
	id: "angry_cats"
	className: "table-striped table-bordered"
	template: "#angry_cats-template"
	itemView: AngryCatView
	
	appendHtml: (collectionView, itemView) ->
		collectionView.$("tbody").append(itemView.el)
		
MyApp.addInitializer (options) ->
	angryCatsView = new AngryCatsView
		collection: options.cats
	MyApp.mainRegion.show(angryCatsView)




$(document).ready ->
    cats_list = new AngryCats [
        new AngryCat {
        	name: "Wet Cat" 
        	image_path: "assets/images/cat2.jpg"
        	}
        new AngryCat {
        	name: "Bitey Cat"
        	image_path: "assets/images/cat1.jpg"
        	}
        new AngryCat {
        	name: "Surprised Cat"
        	image_path: "assets/images/cat3.jpg"
        	}
    ]
    MyApp.start
      cats: cats_list
		
