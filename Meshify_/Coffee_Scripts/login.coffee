define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									
#	Meshable.addInitializer (options) ->
#		authview = new AuthView
#			model: options.authModel
#		Meshable.loginRegion.show(authview)

						
	AuthModel = Backbone.Model.extend
		defaults: 				 				
			username: "UserName"
			fakepassword: "Password"
			password: ""		
			statusmsg: ""
			numberofattempts: 0 		
		updateMsg: (msg) ->  
			@set 
				statusmsg: msg		
		updateUsername: (un) -> 
			@set
				username: un  

			
		updatePassword: (pw) -> 
			@set
				password: pw

	collect = Backbone.Collection.extend
		model: AuthModel 
	
	AuthView = Backbone.Marionette.ItemView.extend
		initialize: (AuthModel) ->
			@bindTo @model, "change", @render
			@first = true
			
			
			
		template: '#auth-template'
		onShow: ->
			
			
				
		
		onRender: ->
			
			#$("#password-input").hide()
			forge.prefs.get "remember", (value) ->
				if value is true
					#$('#remember-me').val true
					forge.prefs.get "password", (value) ->
						$('#pw').val value
					forge.prefs.get "username", (value) ->
						$('#un').val value
				#if value is false
					#$('#password-input').val false
			#@passwordcheck()
			
				
			#if not @first
				hi = 1
				#$( '#home_page' ).hide().trigger( 'updatelayout' );
				#$( '#home_page' ).show().trigger( 'updatelayout' );
			#	Meshable.events.trigger "rerender:login"		
			#@first = false
		
			
			
			$("#login").trigger('create')
			#@passwordcheck()
			
			
			
		events:
			"click #auth-submit-btn": "submitauth"
			#"focus #username-input": "focususername"
			#"blur #un": "blurusername"
			#"blur #password-input": "blurpassword"
			#"focus #fakepassword-input": "focusfakepassword"
		focusfakepassword: -> 
			$('#fakepassword-input').hide()
			$('#password-input').show()	
			$('#password-input').focus()							
		passwordcheck: -> 
			if ($('#password-input').val() == '')
				$('#password-input').hide()
				$('#fakepassword-input').show()	
			else
				$('#password-input').show()
				$('#fakepassword-input').hide()	
		focususername: ->
			if ($('#username-input').val() == @model.defaults.username)
				$('#username-input').val ""
				$('#username-input').removeClass 'italic'			
		submitauth: ->
			#Meshable.vent.trigger "goto:menu"
			#Meshable.router.navigate "dashboard", trigger : true
			#@model.updatePassword $('#password-input').val()
			#@model.updateUsername $('#username-input').val()
			pass = $('#pw').val()
			username = $('#un').val()
			remember = $('#remember-me').prop("checked")
			forge.prefs.set "remember", remember
			
			if remember is true
				forge.prefs.set "password", pass
				forge.prefs.set "username", username
				
			
				
			self = @  
			$("body").addClass('ui-disabled') 
			$.mobile.showPageLoadingMsg("a", "Loading", false)
			
			if not forge.is.connection.connected()
				forge.notification.alert("Login Failed", "No Internet Connection")
				#alert "No Internet Connection" 
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
			else
				forge.request.ajax
					url: Meshable.rooturl + "/api/authentication/login"
					type: "POST"
					dataType: "json"
					timeout: "10000"
					contentType: 'application/json; charset=utf-8'
					data: JSON.stringify({ "UserName" : $('#un').val(), "Password" : $('#pw').val(), "RememberMe" : $('#remember-me').prop("checked")})
					
					error: (e) -> 
						$("body").removeClass('ui-disabled')
						$.mobile.hidePageLoadingMsg()
						forge.notification.alert("Error", e.message) 
						Meshable.router.navigate "", trigger : true
						#self.model.updateMsg "An error occurred on authentication... sorry!"
					success: (data) ->
						try
							data.company.Name = Meshable.companyName
							userRole = 1
							for role in data.roles
								if role == "MOBILE_ONLY"
									userRole = 0
							Meshable.userRole = userRole
							Meshable.companyPhone = data.company.Phone
						catch error
							Meshable.companyName = "Mistaway"
							Meshable.userRole = 1
							Meshable.companyPhone = "000-000-0000"
						#data.company.Name Name to display on Units company.logoUrl path to S3 image for role in data.roles {ADMIN, SUPER_ADMIN DEALER CUSTOMER MOBILE_ONLY}
						if data.IsAuthenticated == true
							$.mobile.changePage $("#mainPage"), changeHash: false, reverse: false, transition: "fade"
							$.mobile.showPageLoadingMsg("a", "Loading", false)
							Meshable.router.navigate "units", trigger : true
							#self.model.updateMsg data.statusMsg 
						else 
						#this would be navigate on router
							forge.notification.alert("Login Failed", "Password or Username not valid") 
							$("body").removeClass('ui-disabled')
							$.mobile.hidePageLoadingMsg()
							#self.model.updateMsg data.statusMsg
							#Meshable.router.navigate "authorized", trigger : true 
		blurpassword: -> 
			if ($('#password-input').val() == '')
				$('#fakepassword-input').val("Password").show()
				$('#password-input').hide()	
		
							
	AuthPageView = Backbone.Marionette.CompositeView.extend
		id: "home_page"
#		className: "table-striped table-bordered"
		template: "#wrapper_home"
		itemView: AuthView
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#login_page").append(itemView.el) 
			
			
			
	Meshable.vent.on "goto:login", ->
		$.mobile.showPageLoadingMsg("a", "Loading", false)
		
		
		forge.topbar.hide(
		  ->
			console.log "hi"
		, (e) ->
			console.log e
		)
		forge.tabbar.hide(
		  ->
			console.log "hi"
		, (e) ->
			console.log e
		)
			
		if not forge.is.connection.connected()
			loginView = new AuthPageView
				collection: new collect new AuthModel
					
			Meshable.currentpage = "login"
			 
			loginView.render()
			$('#login').empty()
			$('#login').append($(loginView.el))
			Meshable.changePage loginView, false
		else
			forge.request.ajax
				url: Meshable.rooturl + "/api/authentication"
				dataType: "json"
				type: "GET"
				timeout: 30000
	
				success: (data) ->	
					if data.IsAuthenticated == true
						#Meshable.vent.trigger "goto:menu"
						$("body").addClass('ui-disabled') 
						$.mobile.showPageLoadingMsg("a", "Loading", false)
						$.mobile.changePage $("#mainPage"), changeHash: false, reverse: false, transition: "fade"
						$.mobile.showPageLoadingMsg("a", "Loading", false)
						Meshable.router.navigate "units", trigger : true
						#Meshable.vent.trigger "goto:units", true
						return
					else
						loginView = new AuthPageView
							collection: new collect new AuthModel
								
						Meshable.currentpage = "login"
						 
						loginView.render()
						$('#login').empty()
						$('#login').append($(loginView.el))
						Meshable.changePage loginView, false
						

					

	