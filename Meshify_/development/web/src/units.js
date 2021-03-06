// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'jqm', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events'], function($, jqm, Backbone, _, Marionette, Meshable, Events) {
    var LoadTenMore, build10Views, buildViews, displayResults, nodeCompView, nodeView, nodea, nodes, showResults, showResults10;

    nodea = Backbone.Model.extend({
      initialize: function() {
        return this.set({
          trafficlight: "green"
        });
      },
      defaults: {
        trafficlight: "green"
      }
    });
    nodes = Backbone.Collection.extend({
      model: nodea
    });
    nodeView = Backbone.Marionette.ItemView.extend({
      initialize: function(node) {
        this.bindTo(this.model, "change", this.render);
        if (node.model.attributes.nodetemplate === "header") {
          this.template = "#label-template";
          return this.$el.attr('data-role', 'list-divider');
        } else if (node.model.attributes.nodetemplate === "resultsIndictor") {
          this.template = '#nodeitem-' + node.model.attributes.nodetemplate;
          this.$el.attr('data-role', 'list-divider');
          return this.$el.attr('data-theme', 'c');
        } else {
          return this.template = '#nodeitem-' + node.model.attributes.nodetemplate;
        }
      },
      tagName: 'li',
      className: "list_item_node",
      onRender: function() {
        return $("#mainDiv").trigger('create');
      },
      events: {
        "click #add10": "add10Items",
        "click #list_item_node": "pop"
      },
      pop: function() {
        return $("#popupBasic").popup();
      },
      add10Items: function() {
        if (!forge.is.connection.connected()) {
          forge.notification.alert("Failed to Load", "No Internet Connection");
          $("body").removeClass('ui-disabled');
          $.mobile.hidePageLoadingMsg();
          Meshable.loading = false;
          return;
        }
        Meshable.current_index += 1;
        LoadTenMore(Meshable.current_index, Meshable.current_searchTerm);
        return this.model.destroy();
      },
      displayNode: function() {
        $("body").addClass('ui-disabled');
        $.mobile.showPageLoadingMsg("a", "Loading", false);
        Meshable.router.navigate("/gateway/" + this.model.attributes.macaddress + "/" + this.model.attributes.node.NodeId, {
          trigger: false
        });
        return Meshable.vent.trigger("goto:node", this.model.attributes);
      }
    });
    nodeCompView = Backbone.Marionette.CompositeView.extend({
      itemView: nodeView,
      template: "#wrapper_ul",
      itemViewContainer: "ul",
      appendHtml: function(collectionView, itemView) {
        return collectionView.$("#placeholder").append(itemView.el);
      }
    });
    Meshable.vent.on("goto:units", function(refresh, routerObj) {
      /*
      		forge.topbar.show(
      		  ->
      			console.log "hi"
      		, (e) ->
      			console.log e
      		)
      		
      		forge.tabbar.show(
      		  ->
      			console.log "hi"
      		, (e) ->
      			console.log e
      		)
      */

      var _this = this;

      $("body").addClass('ui-disabled');
      $.mobile.showPageLoadingMsg("a", "Loading", false);
      Meshable.loading = true;
      if (routerObj !== "") {
        displayResults(routerObj);
        return;
      }
      if (!refresh && Meshable.current_units !== "" && Meshable.refreshUnits === false) {
        showResults();
        return;
      }
      $("body").addClass('ui-disabled');
      $.mobile.showPageLoadingMsg("a", "Loading", false);
      Meshable.current_index = 0;
      if (!forge.is.connection.connected()) {
        forge.notification.alert("Failed to Load", "No Internet Connection");
        $("body").removeClass('ui-disabled');
        $.mobile.hidePageLoadingMsg();
        Meshable.loading = false;
        window.history.back();
        return;
      }
      return forge.request.ajax({
        url: Meshable.rooturl + "/api/Locations",
        data: {
          term: Meshable.current_searchTerm,
          systemTypes: "",
          problemStatuses: "",
          customGroups: "",
          pageIndex: 0,
          pageSize: 10
        },
        dataType: "json",
        type: "GET",
        timeout: 15000,
        error: function(e) {
          forge.notification.alert("Error", e.message);
          $("body").removeClass('ui-disabled');
          $.mobile.hidePageLoadingMsg();
          Meshable.loading = false;
        },
        success: function(data) {
          var TempObj, dataObj, node, _i, _len;

          dataObj = new Object;
          dataObj.list = [];
          data = data.CurrentPageListItems;
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            node = data[_i];
            node.person.userRole = Meshable.userRole;
            if (node.person.first === "") {
              node.person.first = "unknown";
            }
            if (node.person.last === "") {
              node.person.last = "unknown";
            }
            if (node.person.phone1 === "") {
              node.person.phone1 = "000-000-0000";
            }
            if (node.address.city === "") {
              node.address.city = "unknown";
            }
            if (node.address.state === "") {
              node.address.state = "unknown";
            }
            if (node.address.street1 === "") {
              node.address.street1 = "unknown";
            }
            if (node.address.zip === "") {
              node.address.zip = "unknown";
            }
            TempObj = node;
            dataObj.list.push(TempObj);
          }
          Meshable.currentDataObj = dataObj;
          Meshable.refreshUnits = false;
          if (data.isAuthenticated === false) {
            return Backbone.history.navigate("logout", {
              replace: false,
              trigger: true
            });
          } else if (data.length === 0) {
            forge.notification.alert("No Results", "");
            $.mobile.hidePageLoadingMsg();
            $("body").removeClass('ui-disabled');
            return Meshable.loading = false;
          } else {
            return displayResults(dataObj);
          }
        }
      });
    });
    displayResults = function(dataObj) {
      var count, listlen, obj, _i, _len, _ref, _results;

      Meshable.refreshUnits = false;
      Meshable.current_units = new nodes;
      listlen = dataObj.list.length;
      count = 0;
      if (!forge.is.connection.connected()) {
        forge.notification.alert("Failed to Load", "No Internet Connection");
        $("body").removeClass('ui-disabled');
        $.mobile.hidePageLoadingMsg();
        Meshable.loading = false;
        return;
      }
      Meshable.headers = 0;
      _ref = dataObj.list;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obj = _ref[_i];
        _results.push((function(obj) {
          var _this = this;

          obj.models = new Array();
          $.mobile.showPageLoadingMsg("a", "Loading", false);
          return forge.request.ajax({
            url: Meshable.rooturl + "/api/gateway",
            data: {
              macaddress: obj.gateway.macaddress
            },
            dataType: "json",
            type: "GET",
            timeout: 25000,
            error: function(e) {
              var tempNode;

              count += 1;
              if (count >= listlen) {
                tempNode = new nodea({
                  nodetemplate: "add"
                });
                obj.models.push(tempNode);
                return buildViews(dataObj.list);
              }
            },
            success: function(data) {
              var obja, tempNode, _j, _len1;

              if (data.isAuthenticated === false) {
                return Backbone.history.navigate("logout", {
                  replace: false,
                  trigger: true
                });
              } else {
                tempNode = new nodea({
                  zip: obj.address.zip,
                  state: obj.address.state,
                  address: obj.address.street1,
                  city: obj.address.city,
                  first: obj.person.first,
                  nodetemplate: "header",
                  last: obj.person.last,
                  phone1: obj.person.phone1,
                  mac: obj.gateway.macaddress
                });
                Meshable.headers += 1;
                obj.models.push(tempNode);
                for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
                  obja = data[_j];
                  obja.person = new Object;
                  obja.person = obj.person;
                  obja.address = new Object;
                  obja.address = obj.address;
                  if (obja.nodetemplate !== "mainMistaway") {
                    tempNode = new nodea;
                    obj.models.push(tempNode.parse(obja));
                  }
                }
                count += 1;
                if (count >= listlen) {
                  /*if count > 1
                  									tempNode = new nodea { 
                  										nodetemplate: "add"
                  										}
                  									Meshable.current_units.add tempNode
                  */

                  return buildViews(dataObj.list);
                }
              }
            }
          });
        })(obj));
      }
      return _results;
    };
    buildViews = function(obj) {
      var model, resIndicator, tempNode, unit, _i, _j, _len, _len1, _ref;

      for (_i = 0, _len = obj.length; _i < _len; _i++) {
        unit = obj[_i];
        _ref = unit.models;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          model = _ref[_j];
          Meshable.current_units.add(model);
        }
      }
      if (Meshable.current_units.size() >= 20) {
        tempNode = new nodea({
          nodetemplate: "add"
        });
        Meshable.current_units.add(tempNode);
      }
      if (Meshable.headers !== 1) {
        if (Meshable.current_searchTerm === "" || Meshable.current_searchTerm === "_") {
          resIndicator = "All Units";
        } else {
          resIndicator = "Results For: " + Meshable.current_searchTerm;
        }
        tempNode = new nodea({
          res: resIndicator,
          nodetemplate: "resultsIndictor"
        });
        Meshable.current_units.add(tempNode, {
          at: 0
        });
      }
      return showResults();
    };
    showResults = function() {
      var city, first, last, mac, nodeId, phone, route, state, street, zip;

      Meshable.nodeCoView = new nodeCompView({
        collection: Meshable.current_units
      });
      if (Meshable.current_units.size() === 2) {
        mac = Meshable.current_units.at(1).attributes.macaddress;
        nodeId = Meshable.current_units.at(1).attributes.node.NodeId;
        first = Meshable.current_units.at(1).attributes.person.first;
        last = Meshable.current_units.at(1).attributes.person.last;
        phone = Meshable.current_units.at(1).attributes.person.phone1;
        city = Meshable.current_units.at(1).attributes.address.city;
        state = Meshable.current_units.at(1).attributes.address.state;
        street = Meshable.current_units.at(1).attributes.address.street1;
        zip = Meshable.current_units.at(1).attributes.address.zip;
        route = "/gateway/" + mac + "/" + nodeId + "/" + first + "/" + last + "/" + phone + "/" + city + "/" + state + "/" + street + "/" + zip;
        Meshable.router.navigate(route, {
          trigger: true,
          replace: true
        });
        Meshable.unitsButton.setActive();
        return;
      }
      Meshable.currentpage = "units";
      Meshable.nodeCoView.render();
      $('#mainDiv').empty();
      $('#mainDiv').append($(Meshable.nodeCoView.el));
      $("#mainDiv").trigger('create');
      $.mobile.hidePageLoadingMsg();
      $("body").removeClass('ui-disabled');
      Meshable.loading = false;
      Meshable.unitsButton.setActive();
      if (Meshable.backplace !== "") {
        $('html, body').animate({
          scrollTop: $(Meshable.backplace).offset().top - 10
        }, 0);
        return Meshable.backplace = "";
      }
    };
    LoadTenMore = function(index, searchTerm) {
      var _this = this;

      Meshable.loading = true;
      $("body").addClass('ui-disabled');
      $.mobile.showPageLoadingMsg("a", "Loading", false);
      Meshable.current_searchTerm = searchTerm;
      Meshable.current_index = index;
      return forge.request.ajax({
        url: Meshable.rooturl + "/api/Locations",
        data: {
          term: searchTerm,
          systemTypes: "",
          problemStatuses: "",
          customGroups: "",
          pageIndex: index,
          pageSize: 10
        },
        dataType: "json",
        type: "GET",
        timeout: 10000,
        error: function(e) {
          forge.notification.alert("Error", e.message);
          $("body").removeClass('ui-disabled');
          $.mobile.hidePageLoadingMsg();
          return Meshable.loading = false;
        },
        success: function(data) {
          var TempObj, count, dataObj, listlen, modelList, node, obj, _i, _j, _len, _len1, _ref, _results;

          dataObj = new Object;
          dataObj.list = [];
          data = data.CurrentPageListItems;
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            node = data[_i];
            node.person.userRole = Meshable.userRole;
            if (node.person.first === "") {
              node.person.first = "unknown";
            }
            if (node.person.last === "") {
              node.person.last = "unknown";
            }
            if (node.person.phone1 === "") {
              node.person.phone1 = "000-000-0000";
            }
            if (node.address.city === "") {
              node.address.city = "unknown";
            }
            if (node.address.state === "") {
              node.address.state = "unknown";
            }
            if (node.address.street1 === "") {
              node.address.street1 = "unknown";
            }
            if (node.address.zip === "") {
              node.address.zip = "unknown";
            }
            TempObj = node;
            dataObj.list.push(TempObj);
          }
          Meshable.currentDataObj = dataObj;
          Meshable.refreshUnits = false;
          if (data.isAuthenticated === false) {
            return Backbone.history.navigate("logout", {
              replace: false,
              trigger: true
            });
          } else if (data.length === 0) {
            forge.notification.alert("No More Results", "");
            $.mobile.hidePageLoadingMsg();
            $("body").removeClass('ui-disabled');
            return Meshable.loading = false;
          } else {
            Meshable.refreshUnits = false;
            listlen = dataObj.list.length;
            count = 0;
            modelList = [];
            _ref = dataObj.list;
            _results = [];
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              obj = _ref[_j];
              _results.push((function(obj) {
                var _this = this;

                obj.models = new Array();
                $.mobile.showPageLoadingMsg("a", "Loading", false);
                return forge.request.ajax({
                  url: Meshable.rooturl + "/api/gateway",
                  data: {
                    macaddress: obj.gateway.macaddress
                  },
                  dataType: "json",
                  type: "GET",
                  timeout: 25000,
                  error: function(e) {
                    var tempNode;

                    count += 1;
                    if (count >= listlen) {
                      tempNode = new nodea({
                        nodetemplate: "add"
                      });
                      obj.models.push(tempNode);
                      return build10Views(dataObj.list);
                      /*for model in obj.models
                      											Meshable.current_units.add model
                      										showResults10 Meshable.current_units, true
                      */

                    }
                  },
                  success: function(data) {
                    var obja, tempNode, tempNode1, _k, _len2;

                    if (data.isAuthenticated === false) {
                      return Backbone.history.navigate("logout", {
                        replace: false,
                        trigger: true
                      });
                    } else {
                      tempNode = new nodea({
                        zip: obj.address.zip,
                        state: obj.address.state,
                        address: obj.address.street1,
                        city: obj.address.city,
                        first: obj.person.first,
                        nodetemplate: "header",
                        last: obj.person.last,
                        phone1: obj.person.phone1,
                        mac: obj.gateway.macaddress
                      });
                      obj.models.push(tempNode);
                      for (_k = 0, _len2 = data.length; _k < _len2; _k++) {
                        obja = data[_k];
                        obja.person = new Object;
                        obja.person = obj.person;
                        obja.address = new Object;
                        obja.address = obj.address;
                        if (obja.nodetemplate !== "mainMistaway") {
                          tempNode = new nodea;
                          tempNode1 = tempNode.parse(obja);
                          obj.models.push(tempNode1);
                        }
                      }
                      count += 1;
                      if (count >= listlen) {
                        return build10Views(dataObj.list);
                        /*for model in obj.models
                        												Meshable.current_units.add model
                        											showResults10 Meshable.current_units, true
                        */

                      }
                    }
                  }
                });
              })(obj));
            }
            return _results;
          }
        }
      });
    };
    build10Views = function(obj) {
      var model, tempNode, unit, _i, _j, _len, _len1, _ref;

      for (_i = 0, _len = obj.length; _i < _len; _i++) {
        unit = obj[_i];
        _ref = unit.models;
        for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
          model = _ref[_j];
          Meshable.current_units.add(model);
        }
      }
      if (Meshable.current_units.size() >= 20) {
        tempNode = new nodea({
          nodetemplate: "add"
        });
        Meshable.current_units.add(tempNode);
      }
      return showResults10(Meshable.current_units, true);
    };
    return showResults10 = function(temp, go) {
      var hi;

      hi = temp;
      Meshable.currentpage = "units";
      $('#mainDiv').empty();
      Meshable.nodeCoView.render();
      $('#mainDiv').append($(Meshable.nodeCoView.el));
      $("#mainDiv").trigger('create');
      $.mobile.hidePageLoadingMsg();
      $("body").removeClass('ui-disabled');
      return Meshable.loading = false;
    };
  });

}).call(this);
