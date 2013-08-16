define ['jquery', 'jqm', 'backbone','underscore','marionette', 'Meshable', 'Events'], ($, jqm, Backbone, _, Marionette, Meshable, Events) ->									 
	
	
					
	form = Backbone.Model.extend 
		initialize: -> 
				@set
					trafficlight: "green"		
			defaults: 				 				
				trafficlight: "green" 			
				
		
	formWrap = Backbone.Collection.extend 
		model: form	
	


	formView = Backbone.Marionette.ItemView.extend
		initialize: (node) ->
			
			@bindTo @model, "change", @render

		
			
		template: '#template-contact'
		
		onRender: ->
			
			$('#formName').val (Meshable.user.FirstName + " " + Meshable.user.LastName)
			$('#formEmail').val Meshable.user.Email
			$('#formPhone').val Meshable.user.Phone
			$("#mistawayDiv").trigger('create')
			
			
		events:
			#"click #mistBtn": "mist"
			#"click #stopBtn": "stop"
			"click #formSubmit": "submit"
			#"slidestop .slider": "sliderSet"
			#"change .select_set": "selectSet"
			
		submit: ->
			forge.request.ajax
				url: "https://sendgrid.com/api/mail.send.json"
				type: "GET"
				dataType: "json"
				timeout: "10000"
				contentType: 'application/json; charset=utf-8'
				data: 
					"api_user": "dane@houselynx.com" 
					"api_key": "Z!gBMeshify" 
					"to": Meshable.company.email
					"toname": Meshable.company.name
					"subject": ($("#formName").val() + " has sent you a message from the iMistAway Mobile App")
					"text": ("Customer: " + $("#formName").val()  + " \n" + "Phone: " + $("#formPhone").val() + "\n" + "Email: " + $("#formEmail").val() + "\n \n Needs help with: " + $("#formReason").val() + "\n \n And has included the following message: \n\n" + $("#formMessage").val()) 
					"from": $("#formEmail").val()
					
					
				
				error: (e) -> 
					$("body").removeClass('ui-disabled')
					$.mobile.hidePageLoadingMsg()
					forge.notification.alert("Error", e.message) 
					Meshable.router.navigate "", trigger : true
					#self.model.updateMsg "An error occurred on authentication... sorry!"
				success: (data) ->
					forge.notification.alert("Message Sent", "Your authorized dealer will be contacting you shortly about your request")
			
		

		


	formCompView = Backbone.Marionette.CompositeView.extend
		itemView: formView
		template: "#wrapper_ul"
		itemViewContainer: "ul"
		
		
		
		
			
		
		appendHtml: (collectionView, itemView) ->
			collectionView.$("#placeholder").append(itemView.el) 

	
	Meshable.vent.on "goto:contact", ->
		
		Meshable.contactButton.setActive()
		form_collection = new formWrap [
			new form { 
				name: Meshable.company.name
				zip: Meshable.company.zip
				city: Meshable.company.city
				state: Meshable.company.state
				street: Meshable.company.street
				email: Meshable.company.email
				phone: Meshable.company.phone
				image: Meshable.company.image
				}
		]
		
		compView = new formCompView
			collection: form_collection
			
			
		
	
		
		
		

			
		Meshable.currentpage = "contact"
		
		compView.render()
		$('#mainDiv').empty()
		$('#mainDiv').append($(compView.el))
		$("#mainDiv").trigger('create')		
		$.mobile.hidePageLoadingMsg()
		$("body").removeClass('ui-disabled')
		
		$('#formName').val (Meshable.user.FirstName + " " + Meshable.user.LastName)
		$('#formEmail').val Meshable.user.Email
		$('#formPhone').val Meshable.user.Phone
		$("#mistawayDiv").trigger('create')
	
	
		
		
	
