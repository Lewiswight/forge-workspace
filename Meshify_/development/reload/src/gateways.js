// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'jqm', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events'], function($, jqm, Backbone, _, Marionette, Meshable, Events) {
    var displayResults, gateway, gatewayCompView, gatewayView, gateways, make_collection;

    make_collection = function() {
      return window.forge.ajax({
        url: "http://devbuildinglynx.apphb.com/api/dashboard",
        dataType: "json",
        type: "GET",
        error: function(e) {
          return alert(e.content);
        },
        success: function(data) {
          var cModel, model, nodeCollection, _i, _len;

          nodeCollection = new dashboards;
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            model = data[_i];
            cModel = new dashboard;
            nodeCollection.add(cModel.parse(model));
          }
          return nodeCollection;
        }
      });
      /*models = JSON.parse """[{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"},{"address":"123 Main Ave","channelname":"energy cost","post":"","pre":"$","status":"The status","trafficlight":"green","value":"1232"}]"""
      		
      		nodeCollection = new dashboards
      		
      		for model in models
      			cModel = new dashboard
      			nodeCollection.add cModel.parse(model)
      		
      		return nodeCollection
      */

    };
    gateway = Backbone.Model.extend({
      initialize: function() {
        return this.set({
          trafficlight: "green"
        });
      },
      defaults: {
        trafficlight: "green"
      }
    });
    gateways = Backbone.Collection.extend({
      model: gateway
    });
    gatewayView = Backbone.Marionette.ItemView.extend({
      initialize: function(gateway) {
        return this.bindTo(this.model, "change", this.render);
      },
      template: '#gatewayitem-template',
      tagName: 'li',
      className: "list_item",
      id: "gatewayItm",
      events: {
        "click #gatewayItm": "get_gateway"
      },
      get_gateway: function() {
        var _this = this;

        window.forge.ajax;
        return {
          url: "http://devbuildinglynx.apphb.com/api/gateway",
          data: {
            macaddress: "00409DFF-FF45871E"
          },
          dataType: "json",
          type: "GET",
          error: function(e) {
            return alert("An error occurred while getting node details... sorry!");
          },
          success: function(data) {
            if (data.isAuthenticated === false) {
              return alert("auth:logout");
            } else if (data.length === 0) {
              return alert("No Results");
            } else {
              return alert("you did it, now start debugging");
            }
          }
        };
      }
    });
    gatewayCompView = Backbone.Marionette.CompositeView.extend({
      itemView: gatewayView,
      template: "#wrapper_dashboard",
      itemViewContainer: "ul",
      appendHtml: function(collectionView, itemView) {
        return collectionView.$("#dashboard_insert").append(itemView.el);
      }
    });
    Meshable.vent.on("goto:gateways", function() {
      var _this = this;

      $.mobile.showPageLoadingMsg();
      return window.forge.ajax({
        url: "http://devbuildinglynx.apphb.com/api/address",
        data: {
          term: "Search",
          pagenum: 0
        },
        dataType: "json",
        type: "GET",
        error: function(e) {
          return alert("An error occurred on search... sorry!");
        },
        success: function(data) {
          if (data.isAuthenticated === false) {
            return myvent.trigger("auth:logout");
          } else if (data.length === 0) {
            return alert("No Results");
          } else {
            return displayResults(data);
          }
        }
      });
    });
    Meshable.vent.on("search:gateways", function(sdata) {
      var _this = this;

      $.mobile.showPageLoadingMsg();
      return window.forge.ajax({
        url: "http://devbuildinglynx.apphb.com/api/address",
        data: {
          term: sdata,
          pagenum: 0
        },
        dataType: "json",
        type: "GET",
        error: function(e) {
          return alert("An error occurred on search... sorry!");
        },
        success: function(data) {
          if (data.isAuthenticated === false) {
            return myvent.trigger("auth:logout");
          } else if (data.length === 0) {
            $.mobile.hidePageLoadingMsg();
            return alert("No Results");
          } else {
            return displayResults(data);
          }
        }
      });
    });
    return displayResults = function(data) {
      var cModel, gateView, model, nodeCollection, _i, _len;

      nodeCollection = new gateways;
      for (_i = 0, _len = data.length; _i < _len; _i++) {
        model = data[_i];
        cModel = new gateway;
        nodeCollection.add(cModel.parse(model));
      }
      gateView = new gatewayCompView({
        collection: nodeCollection
      });
      Meshable.currentpage = "gateways";
      gateView.render();
      $('#gateways').empty();
      $('#gateways').append($(gateView.el));
      return Meshable.changePage(gateView, false);
    };
  });

}).call(this);