// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'jqm', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events'], function($, jqm, Backbone, _, Marionette, Meshable, Events) {
    var LoadTenMore, displayResults, nodeCompView, nodeView, nodea, nodes, showResults, showResults10;

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
      if (routerObj !== "") {
        displayResults(routerObj);
        return;
      }
      if (!refresh && Meshable.current_units !== "" && Meshable.refreshUnits === false) {
        showResults(Meshable.current_units);
        return;
      }
      $("body").addClass('ui-disabled');
      $.mobile.showPageLoadingMsg("a", "Loading", false);
      Meshable.current_index = 0;
      if (!forge.is.connection.connected()) {
        forge.notification.alert("Failed to Load", "No Internet Connection");
        $("body").removeClass('ui-disabled');
        $.mobile.hidePageLoadingMsg();
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
          return window.history.back();
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
              node.person.first = "Unknown";
            }
            if (node.person.last === "") {
              node.person.last = "Unknown";
            }
            if (node.person.phone1 === "") {
              node.person.phone1 = "000-000-0000";
            }
            if (node.address.city === "") {
              node.address.city = "Unknown";
            }
            if (node.address.state === "") {
              node.address.state = "Unknown";
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
            return $("body").removeClass('ui-disabled');
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
        return;
      }
      _ref = dataObj.list;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        obj = _ref[_i];
        _results.push((function(obj) {
          var _this = this;

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
                Meshable.current_units.add(tempNode);
                return showResults(Meshable.current_units);
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
                  first: obj.person.first,
                  nodetemplate: "header",
                  last: obj.person.last,
                  phone1: obj.person.phone1,
                  mac: obj.gateway.macaddress
                });
                Meshable.current_units.add(tempNode);
                for (_j = 0, _len1 = data.length; _j < _len1; _j++) {
                  obja = data[_j];
                  obja.person = new Object;
                  obja.person = obj.person;
                  obja.address = new Object;
                  obja.address = obj.address;
                  if (obja.nodetemplate !== "mainMistaway") {
                    tempNode = new nodea;
                    Meshable.current_units.add(tempNode.parse(obja));
                  }
                }
                count += 1;
                if (count >= listlen) {
                  if (count > 1) {
                    tempNode = new nodea({
                      nodetemplate: "add"
                    });
                    Meshable.current_units.add(tempNode);
                  }
                  return showResults(Meshable.current_units);
                }
              }
            }
          });
        })(obj));
      }
      return _results;
    };
    showResults = function(temp) {
      var hi;

      hi = temp;
      Meshable.nodeCoView = new nodeCompView({
        collection: Meshable.current_units
      });
      Meshable.currentpage = "units";
      Meshable.nodeCoView.render();
      $('#mainDiv').empty();
      $('#mainDiv').append($(Meshable.nodeCoView.el));
      $("#mainDiv").trigger('create');
      $.mobile.hidePageLoadingMsg();
      $("body").removeClass('ui-disabled');
      if (Meshable.backplace !== "") {
        $('html, body').animate({
          scrollTop: $(Meshable.backplace).offset().top
        }, 0);
        return Meshable.backplace = "";
      }
    };
    LoadTenMore = function(index, searchTerm) {
      var _this = this;

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
          return $.mobile.hidePageLoadingMsg();
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
              node.person.first = "Unknown";
            }
            if (node.person.last === "") {
              node.person.last = "Unknown";
            }
            if (node.person.phone1 === "") {
              node.person.phone1 = "000-000-0000";
            }
            if (node.address.city === "") {
              node.address.city = "Unknown";
            }
            if (node.address.state === "") {
              node.address.state = "Unknown";
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
            return $("body").removeClass('ui-disabled');
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
                    var model, tempNode, _k, _len2;

                    count += 1;
                    if (count >= listlen) {
                      tempNode = new nodea({
                        nodetemplate: "add"
                      });
                      modelList.push(tempNode);
                      for (_k = 0, _len2 = modelList.length; _k < _len2; _k++) {
                        model = modelList[_k];
                        Meshable.current_units.add(model);
                      }
                      return showResults10(Meshable.current_units, true);
                    }
                  },
                  success: function(data) {
                    var model, obja, tempNode, tempNode1, _k, _l, _len2, _len3;

                    if (data.isAuthenticated === false) {
                      return Backbone.history.navigate("logout", {
                        replace: false,
                        trigger: true
                      });
                    } else {
                      tempNode = new nodea({
                        first: obj.person.first,
                        nodetemplate: "header",
                        last: obj.person.last,
                        phone1: obj.person.phone1,
                        mac: obj.gateway.macaddress
                      });
                      modelList.push(tempNode);
                      for (_k = 0, _len2 = data.length; _k < _len2; _k++) {
                        obja = data[_k];
                        obja.person = new Object;
                        obja.person = obj.person;
                        obja.address = new Object;
                        obja.address = obj.address;
                        if (obja.nodetemplate !== "mainMistaway") {
                          tempNode = new nodea;
                          tempNode1 = tempNode.parse(obja);
                          modelList.push(tempNode1);
                        }
                      }
                      count += 1;
                      if (count >= listlen) {
                        tempNode = new nodea({
                          nodetemplate: "add"
                        });
                        modelList.push(tempNode);
                        for (_l = 0, _len3 = modelList.length; _l < _len3; _l++) {
                          model = modelList[_l];
                          Meshable.current_units.add(model);
                        }
                        return showResults10(Meshable.current_units, true);
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
    return showResults10 = function(temp, go) {
      var hi;

      hi = temp;
      Meshable.currentpage = "units";
      $('#mainDiv').empty();
      Meshable.nodeCoView.render();
      $('#mainDiv').append($(Meshable.nodeCoView.el));
      $("#mainDiv").trigger('create');
      $.mobile.hidePageLoadingMsg();
      return $("body").removeClass('ui-disabled');
    };
  });

}).call(this);
