// Generated by CoffeeScript 1.6.2
(function() {
  require(["jquery", "async", "propertyParser", "goog", "backbone"], function($, async, propertyParser, goog, Backbone) {
    return $(document).on("mobileinit", function() {
      $.mobile.linkBindingEnabled = false;
      return $.mobile.hashListeningEnabled = false;
    });
  });

  require(['jqmglobe', 'jqm', "underscore", "marionette", "Meshable", "Router", "Events", "login", 'dashboard', 'search', 'animate', 'slide', 'menu', 'gateways', 'nodes', 'node', 'units', 'contact', 'vendor/charts.js'], function(jqmglobe, jqm, _, Marionette, Meshable, Router, Events, login, dashboard, search, animate, slide, menu, gateways, nodes, node, units, contact) {
    return $(document).ready(function() {
      /*forge.request.ajax
      			url:"https://s3.amazonaws.com/LynxMVC4-Bucket/template-apgus.html"
      			dataType: "HTML"
      			type: "GET"
      			timeout: 15000
      			error: (e) -> 
      				forge.notification.alert("Error", e.message) 
      				$.mobile.hidePageLoadingMsg()
      				$("body").removeClass('ui-disabled')
      				Meshable.loading = false
      				window.history.back()
      			success: (data) =>
      				alert data
      				$('body').append data
      */
      google.load("visualization", "1", {
        packages: ["gauge", "corechart"]
      });
      Meshable.events = Events;
      Meshable.router = new Router();
      Backbone.history.navigate("", {
        replace: true,
        trigger: true
      });
      return Meshable.start({
        authModel: "login"
      });
    });
  });

}).call(this);
