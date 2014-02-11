forever = require("forever-monitor") 
email = require("emailjs")
child = new Array
server = email.server.connect(
	host: "localhost"
	ssl: false
)

# send the message and get a callback with an error or details of the message that was sent
server.send
	text: "New Uploader Precess Started"
	from: "Uploader <lewis@meshify.com>"
	to: "lewiswight@gmail.com, dane@meshify.com"
	cc: ""
	subject: "New Uploader Precess Started"
, (err, message) ->
	console.log err or message
console.log "New Uploader Precess Started" 

spinUp = (name) ->
	i = name
	name = name.toString()
	directory = "./tmp/log" + name + ".txt"	
	directory2 = "./tmp/error" + name + ".txt"
	child[i] = new (forever.Monitor)("uploadprocessnode/start.js",
	  max: 100
	  silent: true
	  outFile: directory
	  errFile: directory2
	  
	  options: []
	)
	
	console.log name
	child[i].on "restart",  ->
		
		server = email.server.connect(
			host: "localhost"
			ssl: false
		)
		
		# send the message and get a callback with an error or details of the message that was sent
		server.send
			text: "uploader: " + name + " has restarted"
			from: "you <lewis@meshify.com>"
			to: "lewiswight@gmail.com, dane@meshify.com"
			cc: ""
			subject: "uploader: " + name + " has restarted"
			attachment: [
				data: "<html><i>Log File</i></html>"
				alternative: true
			,
				path: directory
				type:"text file"
				name:"log.txt"
			,
				data: "<html><i>Error File</i></html>"
				alternative: true
			,
				path: directory2
				type:"text file"
				name:"error.txt"
			]
		, (err, message) ->
			console.log err or message
		console.log "uploader: " + name + " has restarted"
	    
	child[i].on "exit",  ->
		
		server = email.server.connect(
			host: "localhost"
			ssl: false
		)
		
		# send the message and get a callback with an error or details of the message that was sent
		server.send
			text: "one of your " + name + " uploaders has exited permenantly"
			from: "Uploader <lewis@meshify.com>"
			to: "lewiswight@gmail.com, dane@meshify.com"
			cc: ""
			subject: "one of your " + name + " uploaders has exited permenantly"
		, (err, message) ->
			console.log err or message
		console.log "one of your " + name + " uploaders has exited permenantly" 
	  
	
	child[i].start()

for i in [0..24]
	spinUp(i)



	
