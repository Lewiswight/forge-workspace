// Generated by CoffeeScript 1.6.2
(function() {
  define(['jquery', 'jqm', 'backbone', 'underscore', 'marionette', 'Meshable', 'Events'], function($, jqm, Backbone, _, Marionette, Meshable, Events) {
    var AuthModel, AuthPageView, AuthView, collect;

    AuthModel = Backbone.Model.extend({
      defaults: {
        username: "UserName",
        fakepassword: "Password",
        password: "",
        statusmsg: "",
        numberofattempts: 0
      },
      updateMsg: function(msg) {
        return this.set({
          statusmsg: msg
        });
      },
      updateUsername: function(un) {
        return this.set({
          username: un
        });
      },
      updatePassword: function(pw) {
        return this.set({
          password: pw
        });
      }
    });
    collect = Backbone.Collection.extend({
      model: AuthModel
    });
    AuthView = Backbone.Marionette.ItemView.extend({
      initialize: function(AuthModel) {
        this.bindTo(this.model, "change", this.render);
        return this.first = true;
      },
      template: '#auth-template',
      onShow: function() {},
      onRender: function() {
        forge.prefs.get("remember", function(value) {
          var hi;

          if (value === true) {
            forge.prefs.get("password", function(value) {
              return $('#pw').val(value);
            });
            forge.prefs.get("username", function(value) {
              return $('#un').val(value);
            });
          }
          return hi = 1;
        });
        return $("#login").trigger('create');
      },
      events: {
        "click #auth-submit-btn": "submitauth"
      },
      focusfakepassword: function() {
        $('#fakepassword-input').hide();
        $('#password-input').show();
        return $('#password-input').focus();
      },
      passwordcheck: function() {
        if ($('#password-input').val() === '') {
          $('#password-input').hide();
          return $('#fakepassword-input').show();
        } else {
          $('#password-input').show();
          return $('#fakepassword-input').hide();
        }
      },
      focususername: function() {
        if ($('#username-input').val() === this.model.defaults.username) {
          $('#username-input').val("");
          return $('#username-input').removeClass('italic');
        }
      },
      submitauth: function() {
        var pass, remember, self, username;

        pass = $('#pw').val();
        username = $('#un').val();
        remember = $('#remember-me').prop("checked");
        forge.prefs.set("remember", remember);
        if (remember === true) {
          forge.prefs.set("password", pass);
          forge.prefs.set("username", username);
        }
        self = this;
        $("body").addClass('ui-disabled');
        $.mobile.showPageLoadingMsg("a", "Loading", false);
        if (!forge.is.connection.connected()) {
          forge.notification.alert("Login Failed", "No Internet Connection");
          $("body").removeClass('ui-disabled');
          return $.mobile.hidePageLoadingMsg();
        } else {
          return forge.request.ajax({
            url: Meshable.rooturl + "/api/authentication/login",
            type: "POST",
            dataType: "json",
            timeout: "10000",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify({
              "UserName": $('#un').val(),
              "Password": $('#pw').val(),
              "RememberMe": $('#remember-me').prop("checked")
            }),
            error: function(e) {
              $("body").removeClass('ui-disabled');
              $.mobile.hidePageLoadingMsg();
              forge.notification.alert("Error", e.message);
              return Meshable.router.navigate("", {
                trigger: true
              });
            },
            success: function(data) {
              var error, role, userRole, _i, _len, _ref;

              try {
                data.company.Name = Meshable.companyName;
                userRole = 1;
                _ref = data.roles;
                for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                  role = _ref[_i];
                  if (role === "MOBILE_ONLY") {
                    userRole = 0;
                  }
                }
                Meshable.userRole = userRole;
                Meshable.companyPhone = data.company.Phone;
              } catch (_error) {
                error = _error;
                Meshable.companyName = "Mistaway";
                Meshable.userRole = 1;
                Meshable.companyPhone = "000-000-0000";
              }
              if (data.IsAuthenticated === true) {
                $.mobile.changePage($("#mainPage"), {
                  changeHash: false,
                  reverse: false,
                  transition: "fade"
                });
                $.mobile.showPageLoadingMsg("a", "Loading", false);
                return Meshable.router.navigate("units", {
                  trigger: true
                });
              } else {
                forge.notification.alert("Login Failed", "Password or Username not valid");
                $("body").removeClass('ui-disabled');
                return $.mobile.hidePageLoadingMsg();
              }
            }
          });
        }
      },
      blurpassword: function() {
        if ($('#password-input').val() === '') {
          $('#fakepassword-input').val("Password").show();
          return $('#password-input').hide();
        }
      }
    });
    AuthPageView = Backbone.Marionette.CompositeView.extend({
      id: "home_page",
      template: "#wrapper_home",
      itemView: AuthView,
      appendHtml: function(collectionView, itemView) {
        return collectionView.$("#login_page").append(itemView.el);
      }
    });
    return Meshable.vent.on("goto:login", function() {
      var loginView;

      $.mobile.showPageLoadingMsg("a", "Loading", false);
      forge.topbar.hide(function() {}, console.log("hi", function(e) {
        return console.log(e);
      }));
      forge.tabbar.hide(function() {}, console.log("hi", function(e) {
        return console.log(e);
      }));
      if (!forge.is.connection.connected()) {
        loginView = new AuthPageView({
          collection: new collect(new AuthModel)
        });
        Meshable.currentpage = "login";
        loginView.render();
        $('#login').empty();
        $('#login').append($(loginView.el));
        return Meshable.changePage(loginView, false);
      } else {
        return forge.request.ajax({
          url: Meshable.rooturl + "/api/authentication",
          dataType: "json",
          type: "GET",
          timeout: 30000,
          success: function(data) {
            if (data.IsAuthenticated === true) {
              $("body").addClass('ui-disabled');
              $.mobile.showPageLoadingMsg("a", "Loading", false);
              $.mobile.changePage($("#mainPage"), {
                changeHash: false,
                reverse: false,
                transition: "fade"
              });
              $.mobile.showPageLoadingMsg("a", "Loading", false);
              Meshable.router.navigate("units", {
                trigger: true
              });
            } else {
              loginView = new AuthPageView({
                collection: new collect(new AuthModel)
              });
              Meshable.currentpage = "login";
              loginView.render();
              $('#login').empty();
              $('#login').append($(loginView.el));
              return Meshable.changePage(loginView, false);
            }
          }
        });
      }
    });
  });

}).call(this);
