// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'jqm', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events'], function($, jqm, Backbone, _, Marionette, Meshable, Events) {
    var menuCollection, menuComposite, menuItem, menuModel;

    menuModel = Backbone.Model.extend({
      defaults: {
        href: "#",
        image: "img/smico3.png",
        name: "Test"
      }
    });
    menuCollection = Backbone.Collection.extend({
      model: menuModel
    });
    menuItem = Backbone.Marionette.ItemView.extend({
      initialize: function(menuModel) {
        return this.bindTo(this.model, "change", this.render);
      },
      template: '#menuModel',
      tagName: 'li'
    });
    menuComposite = Backbone.Marionette.CompositeView.extend({
      itemView: menuItem,
      template: "#menuComposite",
      itemViewContainer: "ul",
      appendHtml: function(collectionView, itemView) {
        return collectionView.$("#menu-insert").append(itemView.el);
      }
    });
    return Meshable.vent.on("goto:menu", function() {
      /*window.forge.ajax
      			url: Meshable.rooturl + "/api/dashboard"
      			dataType: "json"
      			type: "GET"
      			error: (e) -> 
      				alert e.content
      			success: (data) ->
      				nodeCollection = new dashboards
      				for model in data
      					cModel = new dashboard
      					nodeCollection.add cModel.parse(model)
      				dashView = new dashboardsView
      					collection: nodeCollection
      */

      var menuCollect, menuCompView;

      menuCollect = new menuCollection([
        new menuModel({
          href: "#gateways",
          image: "img/smico3.png",
          name: "My Systems",
          id: "menu-gateways"
        }), new menuModel({
          href: "#search",
          image: "img/smico3.png",
          name: "Search",
          id: "menu-search"
        }), new menuModel({
          href: "#logout",
          image: "img/smico3.png",
          name: "Log Out",
          id: "menu-logout"
        })
      ]);
      menuCompView = new menuComposite({
        collection: menuCollect
      });
      menuCompView.render();
      $('#slidemenu').empty();
      return $('#slidemenu').append($(menuCompView.el));
    });
  });

}).call(this);
