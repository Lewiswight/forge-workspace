define ['jquery','backbone','underscore','marionette', 'Meshable', 'Events'], ($, Backbone, _, Marionette, Meshable, Events) ->									
	Meshable.addInitializer (options) ->
		authview = new AuthView
			model: options.authModel
		Meshable.loginRegion.show(authview)

						
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

	AuthView = Backbone.Marionette.ItemView.extend
		initialize: (AuthModel) ->
			@bindTo @model, "change", @render
		template: '#auth-template'
		onShow: ->
			@passwordcheck()
			$('#username-input').addClass 'italic'			
		onRender: ->
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
			Meshable.router.navigate "authorized", trigger : true
		#	@model.updatePassword $('#password-input').val()
		#	@model.updateUsername $('#username-input').val()
		#	self = @
		#	Meshable.router.navigate "authorized", trigger : true

			###		$.ajax
				url: Meshable.rooturl + "/Account/LogOn"
				data:  { UserName: @model.get("username") , Password: @model.get("password"), RememberMe: $('#RememberMe').is(":checked"), isapicall: true}
				dataType: "json"
				type: "POST"
				traditional: true
				error: (e) -> 
					Meshable.router.navigate "authorized", trigger : true
					#self.model.updateMsg "An error occurred on authentication... sorry!"
				success: (data) ->
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

	return new AuthModel
					

	