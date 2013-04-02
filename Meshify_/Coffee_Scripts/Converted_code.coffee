MyApp = new Backbone.Marionette.Application()
MyApp.addRegions mainRegion: "#content"
AngryCat = Backbone.Model.extend(
  defaults:
    votes: 0

  addVote: ->
    @set "votes", @get("votes") + 1

  rankUp: ->
    @set rank: @get("rank") - 1

  rankDown: ->
    @set rank: @get("rank") + 1
)
AngryCats = Backbone.Collection.extend(
  model: AngryCat
  initialize: (cats) ->
    rank = 1
    _.each cats, (cat) ->
      cat.set "rank", rank
      ++rank

    @on "add", (cat) ->
      unless cat.get("rank")
        error = Error("Cat must have a rank defined before being added to the collection")
        error.name = "NoRankError"
        throw error

    self = this
    MyApp.vent.on "rank:up", (cat) ->
      
      # can't increase rank of top-ranked cat
      return true  if cat.get("rank") is 1
      self.rankUp cat
      self.sort()

    MyApp.vent.on "rank:down", (cat) ->
      
      # can't decrease rank of lowest ranked cat
      return true  if cat.get("rank") is self.size()
      self.rankDown cat
      self.sort()

    MyApp.vent.on "cat:disqualify", (cat) ->
      disqualifiedRank = cat.get("rank")
      catsToUprank = self.filter((cat) ->
        cat.get("rank") > disqualifiedRank
      )
      catsToUprank.forEach (cat) ->
        cat.rankUp()

      self.trigger "reset"


  comparator: (cat) ->
    cat.get "rank"

  rankUp: (cat) ->
    
    # find the cat we're going to swap ranks with
    rankToSwap = cat.get("rank") - 1
    otherCat = @at(rankToSwap - 1)
    
    # swap ranks
    cat.rankUp()
    otherCat.rankDown()

  rankDown: (cat) ->
    
    # find the cat we're going to swap ranks with
    rankToSwap = cat.get("rank") + 1
    otherCat = @at(rankToSwap - 1)
    
    # swap ranks
    cat.rankDown()
    otherCat.rankUp()
)
AngryCatView = Backbone.Marionette.ItemView.extend(
  template: "#angry_cat-template"
  tagName: "tr"
  className: "angry_cat"
  events:
    "click .rank_up img": "rankUp"
    "click .rank_down img": "rankDown"
    "click a.disqualify": "disqualify"

  initialize: ->
    @bindTo @model, "change:votes", @render

  rankUp: ->
    @model.addVote()
    MyApp.vent.trigger "rank:up", @model

  rankDown: ->
    @model.addVote()
    MyApp.vent.trigger "rank:down", @model

  disqualify: ->
    MyApp.vent.trigger "cat:disqualify", @model
    @model.destroy()
)
AngryCatsView = Backbone.Marionette.CompositeView.extend(
  tagName: "table"
  id: "angry_cats"
  className: "table-striped table-bordered"
  template: "#angry_cats-template"
  itemView: AngryCatView
  
  	
  appendHtml: (collectionView, itemView) ->
    collectionView.$("tbody").append itemView.el
)
MyApp.addInitializer (options) ->
  angryCatsView = new AngryCatsView(collection: options.cats)
  MyApp.mainRegion.show angryCatsView

$(document).ready ->
  cats = new AngryCats([new AngryCat(
    name: "Wet Cat"
    image_path: "assets/images/cat2.jpg"
  ), new AngryCat(
    name: "Bitey Cat"
    image_path: "assets/images/cat1.jpg"
  ), new AngryCat(
    name: "Surprised Cat"
    image_path: "assets/images/cat3.jpg"
  )])
  MyApp.start cats: cats
  cats.add new AngryCat(
    name: "Cranky Cat"
    image_path: "assets/images/cat4.jpg"
    rank: cats.size() + 1
  )
