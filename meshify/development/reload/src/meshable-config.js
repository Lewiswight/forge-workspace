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
				 }
				     
		 
				 
				 
			},
			
			
			
			
			

		
          
    paths: {
        
    	"jquery": "vendor/jquery",
    	'jqm-config': "jqm-config",
    	"jqm": "vendor/jquery.mobile",
    	'backbone': "vendor/backbone",
    	'underscore': "vendor/underscore",
        'marionette': "vendor/backbone.marionette", 
        'Meshable': "Meshable",
        'Router': "meshable-router",
        'Events': "events",
        'login': "login",
        'dashboard': 'dashboard',
        'search': 'search'
        

      
    }
});