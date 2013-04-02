// Generated by CoffeeScript 1.3.3
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
        this.first = true;
        return $("#password-input").hide();
      },
      template: '#auth-template',
      onShow: function() {
        this.passwordcheck();
        return $('#username-input').addClass('italic');
      },
      onRender: function() {
        if (!this.first) {
          Meshable.events.trigger("rerender:login");
        }
        this.first = false;
        $("#password-input").hide();
        return this.passwordcheck();
      },
      events: {
        "click #auth-submit-btn": "submitauth",
        "focus #username-input": "focususername",
        "blur #username-input": "blurusername",
        "blur #password-input": "blurpassword",
        "focus #fakepassword-input": "focusfakepassword"
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
        }
      },
      focususername: function() {
        if ($('#username-input').val() === this.model.defaults.username) {
          $('#username-input').val("");
          return $('#username-input').removeClass('italic');
        }
      },
      submitauth: function() {
        return Meshable.router.navigate("dashboard", {
          trigger: true
          /*			@model.updatePassword $('#password-input').val()
          			@model.updateUsername $('#username-input').val()
          			self = @   
          
          			$.ajax
          				url: "http://devbuildinglynx.apphb.com/Account/LogOn"
          				data:  { UserName: "buildinglynx" , Password: "37905528", RememberMe: true, isapicall: true}
          				dataType: "json"
          				type: "POST"
          				traditional: true 
          				error: (e) -> 
          					Meshable.router.navigate "authorized", trigger : true
          					#self.model.updateMsg "An error occurred on authentication... sorry!"
          				success: (data) ->
          					console.log data
          					if data.IsAuthenticated == true
          						self.model.updateMsg data.statusMsg 
          					else 
          					#this would be navigate on router
          						self.model.updateMsg data.statusMsg
          						Meshable.router.navigate "authorized", trigger : true
          */

        });
      },
      blurpassword: function() {
        if ($('#password-input').val() === '') {
          $('#fakepassword-input').val("Password").show();
          return $('#password-input').hide();
        }
      },
      blurusername: function() {
        var self;
        this.model.updateUsername($('#username-input').val());
        if ($('#username-input').val() === this.model.defaults.username) {
          return $('#username-input').addClass('italic');
        } else {
          self = this;
          return $.ajax({
            url: Meshable.rooturl + "/Account/doesusernameExist",
            data: {
              username: this.model.get("username")
            },
            dataType: "json",
            type: "POST",
            traditional: true,
            error: function(e) {
              return self.model.updateMsg("Sorry your username is not found!");
            },
            success: function(data) {
              if (data === false) {
                self.model.updateMsg("Awesome, we found your username");
                return $('#fakepassword-input').focus();
              } else {
                self.model.updateMsg("Sorry, your username isn't in the system");
                return $('#username-input').focus();
              }
            }
          });
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
    return new AuthPageView({
      collection: new collect(new AuthModel)
    });
  });

}).call(this);
