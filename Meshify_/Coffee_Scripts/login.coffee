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
						$('#unNew').val value
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
			"click #getnewpass": "openPopup"
			"click #newPas": "newPassword"
			#"blur #un": "blurusername"
			#"blur #password-input": "blurpassword"
			#"focus #fakepassword-input": "focusfakepassword"
			
		openPopup: ->
			$("#popupBasic").popup('open')

			
		 
			
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
			forge.prefs.set "username", username
			if remember is true
				forge.prefs.set "password", pass
				
			demoGraph = new Object {
				user_id: username
			}
						
			forge.flurry.setDemographics(
				demoGraph
			, ->
				console.log "demographics sent"
			, (e) ->
				console.log e
			)
			
			
			param = new Object {
				login: username
				
			}
			forge.flurry.customEvent(
				"start up"
				param
			, ->
				console.log "startup sent to flury"
			, (e) ->
				console.log e
			)
			
			
			forge.geolocation.getCurrentPosition (position) ->
				forge.flurry.setLocation position.coords
			
				
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
					data: JSON.stringify({ "UserName" : $('#un').val(), "Password" : $('#pw').val(), "RememberMe" : $('#remember-me').prop("checked"), "AppType" : "web"})
					
					error: (e) -> 
						$("body").removeClass('ui-disabled')
						$.mobile.hidePageLoadingMsg()
						forge.notification.alert("Error", e.message) 
						Meshable.router.navigate "", trigger : true
						#self.model.updateMsg "An error occurred on authentication... sorry!"
						
						
					success: (data) ->
						
						
						#data.company.Name Name to display on Units company.logoUrl path to S3 image for role in data.roles {ADMIN, SUPER_ADMIN DEALER CUSTOMER MOBILE_ONLY}
						if data.IsAuthenticated == true
							
							
							###addTemplate = (file) ->
								forge.file.string file, (string) ->
										$('body').append(string)
									 
							checkCachedTemplate = (templateName) ->
								forge.prefs.get templateName, (file) ->
									if file == null
										cacheTemplate()
										return
									
									forge.file.isFile file, (isFile) ->
								    	
							            if isFile == false
							            	
							                #msg = "File no longer available"
							                #forge.notification.alert("Message", msg)  
							                cacheTemplate()
							            else
							                #msg = "Template available Locally"
							                #forge.notification.alert("Message", msg) 
							                addTemplate file
							
							cacheTemplate = ->
								forge.file.cacheURL "https://s3.amazonaws.com/LynxMVC4-Bucket/template-apgus.html", (file) ->
									#alert "template cached"
									
									#$('body').append(forge.file.sting(file))
							    	# File cached save the file object for later
									forge.prefs.set "template-apgus1", file, ->
							      		#alert "templated saved" 
							      		addTemplate file
							    							      		
							checkCachedTemplate "template-apgus1"###
							

							# unsubscribe to all of the channels you subcribed to last time you logged in
							forge.parse.push.subscribedChannels ((channels) ->
								for channel in channels
									forge.parse.push.unsubscribe channel, (->
										forge.logging.info ("no more notifications from: " + channel
										) 
									), (err) ->
										forge.logging.error "couldn't unsubscribe from beta-tester notifications: " + JSON.stringify(err)											
							), (err) ->
								forge.logging.error "couldn't retreive subscribed channels: " + JSON.stringify(err)
							
							channelName = $('#un').val()
							channelName = channelName.replace("@", "")
							channelName = channelName.replace(/\./g,'')
							channelName = channelName.toLowerCase()
							
							# this alerts the user when they get a notification 
							forge.event.messagePushed.addListener (msg) ->
						  		forge.notification.alert("Message", msg.alert)  
						  		
						  	# subscribe to your username, your company, and your parent company
						 	forge.parse.push.subscribe channelName, (->
								forge.logging.info "subscribed to: " + channelName
							), (err) ->
								forge.logging.error "error subscribing to : " + JSON.stringify(err)
								
							forge.parse.push.subscribe ("company" + JSON.stringify(data.company.CompanyId)), (->
								forge.logging.info "subscribed to: " + channelName
							), (err) ->
								forge.logging.error "error subscribing to : " + JSON.stringify(err)
								
							forge.parse.push.subscribe ( "parent" + JSON.stringify(data.company.Parent_CompanyId)), (->
								forge.logging.info "subscribed to: " + channelName
							), (err) ->
								forge.logging.error "error subscribing to : " + JSON.stringify(err)
								
							Meshable.company.zip = data.company.Address.zip
							Meshable.company.city = data.company.Address.city
							Meshable.company.state = data.company.Address.state
							Meshable.company.street = data.company.Address.street1
							Meshable.company.name = data.company.Name 
							Meshable.company.email = data.company.email
							Meshable.company.phone = data.company.phone
							Meshable.company.image = data.company.mobileLogoUrl
							Meshable.user.FirstName = data.person.first
							Meshable.user.LastName = data.person.last
							Meshable.user.Phone = data.person.phone1
							Meshable.user.Email = data.person.UserObj.Username
							for itm of Meshable.company
								if Meshable.company[itm] == null
									Meshable.company[itm] = ""
							try
								
								Meshable.userRole = 1
								for role in data.roles
									if role == "MOBILE_ONLY"
										Meshable.userRole = 0
										
								if Meshable.userRole == 1
									usrR = "Dealer/Admin"
								else
									usrR = "Mobile Only"
									
								param = new Object {
									UserType: usrR
									
								}
								forge.flurry.customEvent(
									"start up"
									param
								, ->
									console.log "set sent to flury"
								, (e) ->
									console.log e
								)
							
							catch error
								Meshable.userRole = 1
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
			
	
	Meshable.vent.on "new:password", ->
		forge.request.ajax
			url: Meshable.rooturl + "/api/authentication/username"
			data:  {username: $('#unNew').val() } 
			dataType: "json"
			type: "GET"
			error: (e) -> 
				$("body").removeClass('ui-disabled')
				$.mobile.hidePageLoadingMsg()
				forge.notification.alert("Error", "email address doesn't match your account") 
			success: (data) ->
				forge.request.ajax
					url: Meshable.rooturl + "/api/authentication/sendEmail"
					data:  {UserName: "lewis@meshify.com" } 
					dataType: "json"
					type: "POST"
					error: (e) -> 
						$("body").removeClass('ui-disabled')
						$.mobile.hidePageLoadingMsg()
						forge.notification.alert("Error", e.message) 
					success: (data) ->
						forge.notification.alert("Success", "Check you inbox for instructions on how to retrieve your password")
						$("#popupBasic").popup('close')
				
				
				
			
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
						
						
						###addTemplate = (file) ->
								forge.file.string file, (string) ->
										$('body').append(string)
									 
							checkCachedTemplate = (templateName) ->
								forge.prefs.get templateName, (file) ->
									if file == null
										cacheTemplate()
										return
									
									forge.file.isFile file, (isFile) ->
								    	
							            if isFile == false
							            	
							                #msg = "File no longer available"
							                #forge.notification.alert("Message", msg)  
							                cacheTemplate()
							            else
							                #msg = "Template available Locally"
							                #forge.notification.alert("Message", msg) 
							                addTemplate file
							
							cacheTemplate = ->
								forge.file.cacheURL "https://s3.amazonaws.com/LynxMVC4-Bucket/template-apgus.html", (file) ->
									#alert "template cached"
									
									#$('body').append(forge.file.sting(file))
							    	# File cached save the file object for later
									forge.prefs.set "template-apgus1", file, ->
							      		#alert "templated saved" 
							      		addTemplate file
							    
							      		
							checkCachedTemplate "template-apgus1"###
						
						
						Meshable.company.zip = data.company.Address.zip
						Meshable.company.city = data.company.Address.city
						Meshable.company.state = data.company.Address.state
						Meshable.company.street = data.company.Address.street1
						Meshable.company.name = data.company.Name 
						Meshable.company.email = data.company.email
						Meshable.company.phone = data.company.phone
						Meshable.company.image = data.company.mobileLogoUrl
						Meshable.user.FirstName = data.person.first
						Meshable.user.LastName = data.person.last
						Meshable.user.Phone = data.person.phone1
						Meshable.user.Email = data.person.UserObj.Username
						for itm of Meshable.company
							if Meshable.company[itm] == null
								Meshable.company[itm] = ""
						try
							
							Meshable.userRole = 1
							for role in data.roles
								if role == "MOBILE_ONLY"
									Meshable.userRole = 0
									
							if Meshable.userRole == 1
								usrR = "Dealer/Admin"
							else
								usrR = "Mobile Only"
								
							param = new Object {
								UserType: usrR
								
							}
							forge.flurry.customEvent(
								"start up"
								param
							, ->
								console.log "set sent to flury"
							, (e) ->
								console.log e
							)
							
						catch error
							Meshable.userRole = 1
						#send user's location for analytics 
						forge.prefs.get "username", (value) ->
							username = value
							
							param = new Object {
								login: username
								
							}
							forge.flurry.customEvent(
								"start up"
								param
							, ->
								console.log "startup sent to flury"
							, (e) ->
								console.log e
							)
						
						forge.geolocation.getCurrentPosition (position) ->
							forge.flurry.setLocation position.coords
						
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
						

					

	