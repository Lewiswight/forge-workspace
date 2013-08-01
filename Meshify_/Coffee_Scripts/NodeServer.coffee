# http://ejohn.org/blog/ecmascript-5-strict-mode-json-and-more/

# Optional. You will see this name in eg. 'ps' or 'top' command

# Port where we'll run the websocket server

# websocket and http servers

###
Global variables
###

# latest 100 messages

# list of currently connected clients (users)

###
Helper function for escaping input strings
###

inspect = require("eyes").inspector(maxLength: false)
async = require("async")
parseString = require("xml2js").parseString




process.title = "node-chat"
webSocketsServerPort = 1337
webSocketServer = require("websocket").server
http = require("http")
history = []
clients = []
clientDict = new Object 
responceDict = new Object
# Array with some colors
colors = ["red", "green", "blue", "magenta", "purple", "plum", "orange"]

# ... in random order
colors.sort (a, b) ->
  Math.random() > 0.5


###
HTTP server
###
server = http.createServer((request, response) ->
)

# Not important for us. We're writing WebSocket server, not HTTP server
server.listen webSocketsServerPort, ->
  console.log (new Date()) + " Server is listening on port " + webSocketsServerPort


###
WebSocket server
###

# WebSocket server is tied to a HTTP server. WebSocket request is just
# an enhanced HTTP request. For more info http://tools.ietf.org/html/rfc6455#page-6





wsServer = new webSocketServer(
	httpServer: server
	keepalive: false
	keepaliveInterval: 60000
	dropConnectionOnKeepaliveTimeout: false
	keepaliveGracePeriod: 2000
)
	

# This callback function is called every time someone
# tries to connect to the WebSocket server
wsServer.on "request", (request) ->
  console.log (new Date()) + " Connection from origin " + request.origin + "."
  
  # accept connection - you should check 'request.origin' to make sure that
  # client is connecting from your website
  # (http://en.wikipedia.org/wiki/Same_origin_policy)
  connection = request.accept(null, request.origin)
  
  # we need to know client index to remove them on 'close' event

  MAC = false
  userColor = false
  console.log (new Date()) + " Connection accepted."
  hbID = false
  
  
  # user sent some message
  connection.on "message", (message) ->
    if message.type is "utf8" # accept only text
      if MAC is false # first message sent by user is their name
      	try
      		msgParts = message.utf8Data.split(":")
      	catch error
      		connection.sendUTF "not_connected"
      		return
      	if msgParts[0] == "connect"
      		#need to add validation on this part to make sure the mac is really a mac address
      		MAC = msgParts[1]
      		clientDict[MAC] = connection
      		responceDict[MAC] = false
      		connection.sendUTF "connected"
      		console.log "connected"
      		
      	else
      		connection.sendUTF "not_connected"
      		return
  
        
      else
      	if message.utf8Data == "ping"
      		connection.sendUTF "pong"
      		return
      	console.log "hi"
      	
      	responceDict[MAC] = message.utf8Data
      	console.log responceDict[MAC]
      	if hbID is false
      		hbID = setInterval(heartbeat, 60000)	
      		
      	


  heartbeat = ->
  	console.log "running heart beat from " + MAC
  	connection.sendUTF "ping"
      		
      		  # user disconnected
  connection.on "close", (connection) ->
  	console.log "client is exiting"
  	if MAC isnt false
  		#remove client
  		delete clientDict[MAC]
  		MAC = false
  		clearInterval(hbID)




###
Restful API for setting channels
###

#xml = "<sci_request version='1.0'><send_message><targets><device id='00000000-00000000-00409DFF-FF5C1B19'/></targets><rci_request version='1.1'><do_command target='Socket'><data><channel_set name='mc13_[00:13:a2:00:40:9f:29:81]!.r' value='M'/></data></do_command></rci_request></send_message></sci_request>"
sendData = (xml) ->
	id = ""
	string = ""
	parseString xml, (err, result) ->
	  id = result.sci_request.send_message[0].targets[0].device[0].$.id
	  id = id.replace("00000000-00000000-","")
	  id = id.replace("FF-FF","")
	  for key of result.sci_request.send_message[0].rci_request[0].do_command[0].data[0]
	  	command = key
	  	inspect key
	  	for key2 of result.sci_request.send_message[0].rci_request[0].do_command[0].data[0][key][0].$
	  		inspect key2
	  		if key2 == "name"
	  			name = result.sci_request.send_message[0].rci_request[0].do_command[0].data[0][key][0].$[key2]
	  		if key2 == "value"
	  			value = result.sci_request.send_message[0].rci_request[0].do_command[0].data[0][key][0].$[key2]
	  			
	  	string += "<" + command + " name='" + name + "' value='" + value + "'/>"
	  	console.log string
	  responceDict[id] = false
	  console.log "I'm here"
	  clientDict[id].sendUTF string
	console.log id
	return id

respond = (req, res, next) ->
  keys = []
  for key of clientDict
  	console.log key
  res.send "hello " + clientDict[req.params.name]
restify = require("restify")
server = restify.createServer()
server.use restify.bodyParser(mapParams: false)

#post data here to set channels, it needs to the rci request that we build right now on the server
server.post "/API/", create = (req, res, next) ->
  newId = ""
  xml = req.body
  console.log "here is the xml"
  inspect xml
  try
  	console.log "trying"
  	newId = sendData xml
  	console.log "here is the id"
  	console.log newId
  catch error
  	res.send 201, "Gateway: " + newId + " Not Connected or Bad XML"
  	next()


  count = 0
  async.whilst ( ->
  	responceDict[newId] is false and count < 40
  ), ((callback) ->
  	count += 1
  	setTimeout callback, 500
  ), (err) ->
  	  if responceDict[newId] is false
  	    msg = "timed out waiting for response from the gateway"
  	    sendResp msg, res, next
  	  else
  	    sendResp responceDict[newId], res, next

sendResp = (respon, res, next) ->
	res.header('Content-Type', 'text/plain')
	res.send 201, respon
	next()
 
 
clients = (req, res, next) -> 
	data = ""
	for key of clientDict
		data += ", " + key
	res.header('Content-Type', 'text/plain')
	res.send data
	next()
  
server.get "/clients", clients
server.head "/hello/:name", respond
server.listen 8080, ->
  console.log "%s listening at %s", server.name, server.url






	

