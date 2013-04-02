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
			$("#password-input").hide()
			
			
		template: '#auth-template'
		onShow: ->
			@passwordcheck()
			$('#username-input').addClass 'italic'
				
		
		onRender: ->
			
			
			if not @first
				#$( '#home_page' ).hide().trigger( 'updatelayout' );
				#$( '#home_page' ).show().trigger( 'updatelayout' );
				Meshable.events.trigger "rerender:login"		
			@first = false
		
			
			
			$("#password-input").hide()
			@passwordcheck()
			
			
			
		events:
			"click #auth-submit-btn": "submitauth"
			"focus #username-input": "focususername"
			"blur #username-input": "blurusername"
			"blur #password-input": "blurpassword"
			"focus #fakepassword-input": "focusfakepassword"
		focusfakepassword: -> 
			$('#fakepassword-input').hide()
			$('#password-input').show()	
			$('#password-input').focus()							
		passwordcheck: -> 
			if ($('#password-input').val() == '')
				$('#password-input').hide()
				$('#fakepassword-input').show()	
		focususername: ->
			if ($('#username-input').val() == @model.defaults.username)
				$('#username-input').val ""
				$('#username-input').removeClass 'italic'			
		submitauth: ->
			Meshable.router.navigate "dashboard", trigger : true
			###			@model.updatePassword $('#password-input').val()
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
						Meshable.router.navigate "authorized", trigger : true ###
		blurpassword: -> 
			if ($('#password-input').val() == '')
				$('#fakepassword-input').val("Password").show()
				$('#password-input').hide()	
		blurusername: ->
			@model.updateUsername $('#username-input').val()
			if ($('#username-input').val() == @model.defaults.username)
				$('#username-input').addClass 'italic' 
		
			else 
				self = @
				
				$.ajax
					url: Meshable.rooturl + "/Account/doesusernameExist"
					data:  {username: @model.get "username" }
					dataType: "json"
					type: "POST"
					traditional: true
					error: (e) -> 
						self.model.updateMsg "Sorry your username is not found!"
					success: (data) ->
						if data == false
							self.model.updateMsg "Awesome, we found your username"
							$('#fakepassword-input').focus()
						else 
							self.model.updateMsg "Sorry, your username isn't in the system"  
							$('#username-input').focus()
							
	AuthPageView = Backbone.Marionette.CompositeView.extend
		id: "home_page"
#		className: "table-striped table-bordered"
		template: "#wrapper_home"
		itemView: AuthView
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#login_page").append(itemView.el) 

	return new AuthPageView
			collection: new collect new AuthModel
					

	