// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events'], function($, Backbone, _, Marionette, Meshable, Events) {
    return $(document).bind("mobileinit", function() {
      $.mobile.ajaxEnabled = false;
      $.mobile.linkBindingEnabled = false;
      $.mobile.hashListeningEnabled = false;
      $.mobile.pushStateEnabled = false;
      $("div[data-role=\"page\"]").live("pagehide", function(event, ui) {});
      return $(event.currentTarget).remove();
    });
  });

}).call(this);
