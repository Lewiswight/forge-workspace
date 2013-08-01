// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'jqm', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events', 'async!http://maps.google.com/maps/api/js?sensor=true'], function($, jqm, Backbone, _, Marionette, Meshable, Events) {
    var Map, MapView, geocoder, latlngbounds, locationmaps, mapOpts, markers, onMapBound, onMapRendered;

    Meshable.vent.on("showmap", function() {
      var bindmap, center;

      bindmap = function(center) {
        return Meshable.vent.trigger('maps:bind', {
          mapContainerId: 'mapwrapper',
          mapOpts: {
            center: center,
            zoom: 12,
            mapTypeId: google.maps.MapTypeId.ROADMAP
          },
          onMapRendered: function() {
            console.log('on onMapRendered callback');
            return forge.request.ajax({
              url: Meshable.rooturl + '/api/locations?term=',
              type: "GET",
              dataType: "json",
              timeout: "10000",
              contentType: 'application/json; charset=utf-8',
              error: function(e) {
                $("body").removeClass('ui-disabled');
                $.mobile.hidePageLoadingMsg();
                forge.notification.alert("Error", e.message);
                return Meshable.router.navigate("", {
                  trigger: true
                });
              },
              success: function(data) {
                return Meshable.vent.trigger('maps:addmarkers', {
                  items: data
                });
              }
            });
          }
        });
      };
      center = new google.maps.LatLng(59.3426606750, 18.0736160278);
      return bindmap(center);
    });
    locationmaps = null;
    geocoder = null;
    mapOpts = null;
    onMapBound = null;
    onMapRendered = null;
    markers = [];
    Meshable.vent.on('maps:bind', function(options) {
      var map, mapView;

      console.log('binding maps');
      mapOpts = options.mapOpts;
      onMapBound = options.onMapBound;
      onMapRendered = options.onMapRendered;
      map = new Map;
      mapView = new MapView({
        model: map
      });
      if (onMapBound !== null && onMapBound !== void 0) {
        onMapBound(mapView);
      }
      google.maps.event.addListener(map, "bounds_changed", function() {
        var bounds;

        bounds = map.getBounds();
        return google.maps.event.trigger(map, 'resize');
      });
      mapView.render();
      $('#mainDiv').empty();
      $('#map_canvas').append($(mapView.el));
      $("map_canvas").trigger('create');
      $.mobile.hidePageLoadingMsg();
      $("body").removeClass('ui-disabled');
      console.log('maps bound');
      return google.maps.event.trigger(map, 'resize');
    });
    Meshable.vent.on('maps:geocode', function(options) {
      var fromaddress, geocoderRequest, state;

      console.log('geocoding');
      state = '';
      if (options.address.country && options.address.country.toLowerCase() === 'us') {
        state = options.address.state;
      }
      fromaddress = [options.address.street1, ', ', options.address.street2, ', ', options.address.city, ', ', state, ', ', options.address.country, ', ', options.address.zip].join();
      geocoderRequest = {
        address: fromaddress
      };
      geocoder = new google.maps.Geocoder();
      return geocoder.geocode(geocoderRequest, options.callback);
    });
    latlngbounds = null;
    Meshable.vent.on('maps:addmarkers', function(obj) {
      var i, _i, _ref;

      if (obj.beforeAddMarkers !== null && obj.beforeAddMarkers !== void 0) {
        obj.beforeAddMarkers(locationmaps, markers);
      }
      console.log('adding ' + obj.items.length + ' markers');
      for (i = _i = 0, _ref = obj.items.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        Meshable.vent.trigger('maps:addmarker', obj.items[i]);
      }
    });
    Meshable.vent.on('maps:addmarker', function(obj) {
      var clickfunction, position, thisicon, thismarker, thisorigin;

      console.log('adding marker');
      console.log(obj);
      if (obj.address.latitude === 0 || obj.address.longitude === 0) {
        console.log('aborting marker addition, latlng is null');
        return false;
      }
      if (obj.nodecolors.statuscolor === "GREEN") {
        thisorigin = new google.maps.Point(0, 245);
      } else if (obj.nodecolors.statuscolor === "YELLOW") {
        thisorigin = new google.maps.Point(0, 298);
      } else if (obj.nodecolors.statuscolor === "RED") {
        thisorigin = new google.maps.Point(0, 187);
      } else if (obj.nodecolors.statuscolor === "BLUE") {
        thisorigin = new google.maps.Point(0, 351);
      } else {
        thisorigin = new google.maps.Point(0, 351);
      }
      thisicon = new Object({
        url: "https://s3.amazonaws.com/LynxMVC4-Bucket/themes/mistaway/sprite.png",
        size: new google.maps.Size(30, 40, "px", "px"),
        origin: thisorigin
      });
      position = new google.maps.LatLng(obj.address.latitude, obj.address.longitude);
      thismarker = new google.maps.Marker({
        map: locationmaps,
        position: position,
        icon: thisicon
      });
      markers.push(thismarker);
      if (latlngbounds) {
        latlngbounds.extend(position);
      }
      clickfunction = function(gmapMouseEvent) {
        return Meshable.vent.trigger('maps:marker:clicked', obj);
      };
      google.maps.event.addListener(thismarker, "click", clickfunction);
      return console.log('marker added');
    });
    Meshable.vent.on('maps:marker:clicked', function(model) {
      return alert("clicked");
    });
    Map = Backbone.Model.extend({
      defaults: {
        dummy: "dummy"
      }
    });
    return MapView = Backbone.Marionette.ItemView.extend({
      initialize: function() {
        return console.log('initialize map view');
      },
      onRender: function() {
        console.log('on MapView render');
        setTimeout((function() {
          var mapContainerId;

          mapContainerId = 'mapwrapper';
          locationmaps = new google.maps.Map(document.getElementById(mapContainerId), mapOpts);
          latlngbounds = new google.maps.LatLngBounds();
          if (onMapRendered !== null && onMapRendered !== void 0) {
            return onMapRendered();
          }
        }), 750);
        return console.log('after MapView render');
      },
      addmarker: function(obj) {
        return Meshable.vent.trigger('maps:addmarker', obj);
      },
      template: maptemplate,
      doGeocoding: function(obj, myfunc) {}
    });
  });

}).call(this);
