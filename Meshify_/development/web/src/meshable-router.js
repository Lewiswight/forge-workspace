// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'jqm', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events', 'login', 'dashboard', 'search'], function($, jqm, Backbone, _, Marionette, Meshable, Events, login, dashboard, search) {
    var Routing;

    Routing = Backbone.Router.extend({
      routes: {
        "unit/:mac/:first/:last/:phone1/:city/:state/:street1/:zip": "unitsM",
        "units": "units",
        "gateway/:mac": "gateway",
        "gateway/:mac/:id/:first/:last/:phone1/:city/:state/:street1/:zip": "nodeDetails",
        "": "home",
        "dashboard": "dashboard",
        "menu": "menu",
        "back": "back",
        "popupPanel": "popupPanel",
        "menu_back_btn": "menu_back_btn",
        "search": "search",
        "searching/:id/:resultType": "searchterm",
        "gateways": "gateways",
        "page1": "page1",
        "ref-page": "refPage",
        "logout": "logout",
        "contact": "contact"
      },
      contact: function() {
        return Meshable.vent.trigger("goto:contact");
      },
      unitsM: function(mac, first, last, phone1, city, state, street1, zip) {
        var listObj, obj;

        obj = new Object;
        obj.list = [];
        listObj = new Object;
        listObj.person = new Object;
        listObj.gateway = new Object;
        listObj.gateway.macaddress = mac;
        listObj.person.userRole = Meshable.userRole;
        listObj.person.first = first;
        listObj.person.last = last;
        listObj.person.phone1 = phone1;
        listObj.address = new Object;
        listObj.address.city = city;
        listObj.address.state = state;
        listObj.address.street1 = street1;
        listObj.address.zip = zip;
        obj.list.push(listObj);
        return Meshable.vent.trigger("goto:units", false, obj);
      },
      units: function() {
        $("body").addClass('ui-disabled');
        $.mobile.showPageLoadingMsg("a", "Loading", false);
        return Meshable.vent.trigger("goto:units", false, "");
      },
      nodeDetails: function(mac, id, first, last, phone1, city, state, street1, zip) {
        if (first === "unknown" || first === null) {
          first = "";
        }
        if (last === "unknown" || last === null) {
          last = "";
        }
        if (phone1 === "unknown" || phone1 === null) {
          phone1 = "";
        }
        if (city === "unknown" || city === null) {
          city = "";
        }
        if (state === "unknown" || state === null) {
          state = "";
        }
        if (street1 === "unknown" || street1 === null) {
          street1 = "";
        }
        if (zip === "unknown" || zip === null) {
          zip = "";
        }
        if (!forge.is.connection.connected()) {
          forge.notification.alert("Failed to Load", "No Internet Connection");
          window.history.back();
          $("body").removeClass('ui-disabled');
          $.mobile.hidePageLoadingMsg();
          return;
        }
        Meshable.backplace = "#" + mac;
        return Meshable.vent.trigger("goto:nodeRefresh", mac, id, first, last, phone1, city, state, street1, zip);
      },
      logout: function() {
        $("body").addClass('ui-disabled');
        $.mobile.showPageLoadingMsg("a", "Loading", false);
        return forge.request.ajax({
          url: Meshable.rooturl + "/api/authentication?logmeoff=true",
          dataType: "json",
          type: "GET",
          error: function(e) {
            $("body").removeClass('ui-disabled');
            $.mobile.hidePageLoadingMsg();
            Meshable.current_index = 0;
            Meshable.current_units = "";
            Meshable.current_gateways = "";
            Meshable.current_searchTerm = "";
            Meshable.vent.trigger("goto:login");
            Meshable.currentMap = null;
            return $('#mainDiv').empty();
          },
          success: function(data) {
            Meshable.current_index = 0;
            Meshable.currentMap = null;
            Meshable.current_units = "";
            Meshable.current_gateways = "";
            Meshable.current_searchTerm = "";
            $.mobile.hidePageLoadingMsg();
            $("body").removeClass('ui-disabled');
            Meshable.vent.trigger("goto:login");
            return $('#mainDiv').empty();
          }
        });
      },
      refPage: function() {
        return $.mobile.changePage($('#ref-page'), {
          changeHash: false,
          transition: 'none',
          showLoadMsg: true
        });
      },
      gateway: function(macaddress) {
        Meshable.currentMac = macaddress;
        return Meshable.vent.trigger("goto:nodes", macaddress);
      },
      gateways: function() {
        Meshable.loading = true;
        $("body").addClass('ui-disabled');
        $.mobile.showPageLoadingMsg("a", "Loading", false);
        return Meshable.vent.trigger("showmap");
      },
      searchterm: function(searchField, resultType) {
        if (searchField === "_") {
          searchField = "";
        }
        if (searchField === Meshable.current_searchTerm) {
          if (resultType === "List") {
            Meshable.vent.trigger("goto:units", true, "");
            Meshable.router.navigate("units", {
              trigger: false,
              replace: true
            });
            return;
          } else {
            $.mobile.showPageLoadingMsg("a", "Loading", false);
            Meshable.vent.trigger("showmap");
            return;
          }
        }
        Meshable.current_searchTerm = searchField;
        Meshable.currentMap = null;
        Meshable.current_index = 0;
        Meshable.current_gateways = "";
        Meshable.refreshUnits = true;
        if (resultType === "List") {
          Meshable.vent.trigger("goto:units", true, "");
          return Meshable.router.navigate("units", {
            trigger: false,
            replace: true
          });
        } else {
          $.mobile.showPageLoadingMsg("a", "Loading", false);
          return Meshable.vent.trigger("showmap");
        }
      },
      search: function() {
        return Meshable.vent.trigger("goto:search");
      },
      menu_back_btn: function() {
        return $("#popupPanel").popup("close");
      },
      popupPanel: function() {
        return $("#popupPanel").popup("open");
      },
      back: function() {
        return window.history.back();
      },
      home: function() {
        return Meshable.vent.trigger("goto:login");
      },
      dashboard: function() {
        return Meshable.vent.trigger("goto:dashboard");
      },
      menu: function() {
        var h;

        $("#popupPanel").on({
          popupbeforeposition: function() {}
        });
        h = $(window).height();
        $("#popupPanel").css("height", h);
        $("#popupPanel").bind({
          popupafterclose: function() {
            return Meshable.vent.trigger("menu:close");
          }
        });
        $("#popupPanel").popup("open");
        $("#menu_back_btn").tap(function() {
          return $("#popupPanel").popup("close");
        });
        return $("#menu_search_btn").tap(function() {
          $("#popupPanel").popup("close");
          return window.setTimeout((function() {
            return Meshable.vent.trigger("open:search");
          }), 600);
        });
      },
      changePage: function(page, direction) {
        $(page.el).attr("data-role", "page");
        $(page.el).attr("data-theme", Meshable.theme);
        return $.mobile.changePage($(page.el), {
          changeHash: true,
          reverse: direction,
          transition: "none"
        });
      },
      initialize: function() {
        this.firstPage = true;
        return this.firstDash = true;
      }
    });
    return Routing;
  });

}).call(this);
