forever = require("forever-monitor") 
email = require("emailjs")
child = new Array
server = email.server.connect(
	host: "localhost"
	ssl: false
)

folder =  process.argv[2]
instances =  process.argv[3]
trys =  process.argv[4]
Pname = process.argv[5]


instances = (parseInt(instances,10)) - 1
trys = parseInt(trys,10)

dir = folder + "/start.js" 


# send the message and get a callback with an error or details of the message that was sent
server.send
	text: Pname + " Started"
	from: "NodeServer <lewis@meshify.com>"
	to: "lewiswight@gmail.com, dane@meshify.com"
	cc: ""
	subject: Pname + " Started"
, (err, message) ->
	console.log err or message
console.log "New Uploader Process Started" 

spinUp = (name) ->
	i = name
	name = name.toString()
	directory = "./tmp/log" + "_" + Pname + name + ".txt"	
	directory2 = "./tmp/error" + "_" + Pname + name + ".txt"
	child[i] = new (forever.Monitor)(dir,
	  max: trys
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
			text: Pname + " " + name + " has restarted"
			from: "you <lewis@meshify.com>"
			to: "lewiswight@gmail.com, dane@meshify.com"
			cc: ""
			subject: Pname + " " + name + " has restarted"
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
			text: "one of your " + Pname + " processes has exited permanently"
			from: "Uploader <lewis@meshify.com>"
			to: "lewiswight@gmail.com, dane@meshify.com"
			cc: ""
			subject: "one of your " + Pname + " processes has exited permanently"
		, (err, message) ->
			console.log err or message
		console.log "one of your " + Pname + " processes has exited permanently"
	  
	
	child[i].start()




for i in [0..instances]
	spinUp(i)



	

