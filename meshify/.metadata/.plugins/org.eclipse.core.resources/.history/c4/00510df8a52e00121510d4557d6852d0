require.config({

    // Initialize the application with the main application file.
    deps: ["require_startup"],

    shim: {
      
		
	
			'marionette': {
			    deps: ['backbone'],
			    exports: 'marionette'
			 },
			
			 
			 
			 'Router': {
				    deps: ['Meshable'],
				    exports: 'Router'
				 },
			 
			 'Events': {
				    deps: ['Meshable'],
				    exports: 'Events'
				 },
				 
			
		
	          'backbone': {
	              //These script dependencies should be loaded before loading
	              //backbone.js
	              deps: ['jquery','underscore'],
	              //Once loaded, use the global 'Backbone' as the
	              //module value.
	              exports: 'backbone'
	          },
	        
				 'jquery.mobile-config': ['jquery'],
		         'jquery.mobile': ['jquery','jquery.mobile-config'],
		         
	        
		 
				 
				 
			},
			
			
			
			
			

		
          
    paths: {
        
    	jquery: "vendor/jquery",
    	'jqm-config': "jqm-config",
    	"jqm": "vendor/jquery.mobile",
    	'cordova': "vendor/cordova-android-2.1.0",
    	'backbone': "vendor/backbone",
    	'underscore': "vendor/underscore",
        'marionette': "vendor/backbone.marionette", 
        'Meshable': "Meshable",
        'Router': "meshable-router",
        'Events': "events",
        'login': "login",
        'tbd': 'vendor/tbd',
        'dashboard': 'dashboard',
        'search': 'search'
        

      
    }
});