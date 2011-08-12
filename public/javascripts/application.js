function Chatter(channel, user) 
{
	
	
	var $this = this;
	$this.channel = channel;
	$this.user = user;
	$this.chatroom = null;
	
	$this.joinRoom = function(room)
	{
		$this.chatroom = room;
		
		console.log("Joined Room: " + $this.chatroom + " on channel: " + $this.channel);
		
		PUBNUB.subscribe({
		    channel  : $this.channel,
		    callback : function(message) 
			{
				$this.parseMessage(message);
			}
		});
		
		
		$this.loadHistory();
		$this.postMessage("has joined the room.", "joined");
	};
	
	
	$this.leaveRoom = function()
	{
		console.log("Leaving room: " + $this.chatroom + " on channel: " + $this.channel);
		PUBNUB.unsubscribe({ channel : $this.channel });
		return $this.postMessage("has left the chat.", "left");
	};
	
	
	$this.postMessage = function(message, status)
	{
		console.log("Posted: " + message + " to: " + $this.channel);
		
		PUBNUB.publish({
	        channel : $this.channel, 
			message : {
				message: message,
				status: status,
				user: $this.user,
				uuid: $this.generateGuid()
			}
	    });
	};
	
	
	$this.loadHistory = function()
	{
		console.log("Loading history for: " + $this.channel);
		
		PUBNUB.history({
		    channel : $this.channel,
		    limit : 100

		// Set Callback Function when History Returns
		}, function(messages) 
		{
		    for(i in messages)
			{
				$this.parseMessage(messages[i]);
			}
		});
	};
	
	
	$this.parseMessage = function(message)
	{
		
		message.message = message.message.replace(/<.*?>/g, '');
		console.log("Parsing message: " + message + " with a status of: " + status);
		
		if(message.status == "left")
		{
			$this.chatroom.addLine("<span class='left'>" + message.user + " " + message.message + "</span>");
		}
		else if(message.status == "joined")
		{
			$this.chatroom.addLine("<span class='joined'>" + message.user + " " + message.message + "</span>");
		}
		else
		{
			$this.chatroom.addLine("<strong class='user'>" + message.user + "</strong> " + message.message);
		}
		
	};
	
	
	$this.generateGuid = function()
	{
		var guid = new Guid();
		return guid.generate();
	};
	
	
	$this.numberOfChatters = function()
	{
		PUBNUB.analytics({
		    channel : $this.channel,  // OPTIONAL
		    duration : 0,           // Minutes Offset
		    ago      : 0,            // Minutes Ago
		    limit    : 100,          // Aggregation Limit
		    callback : function(analytics) 
			{
		        console.log( "Analytics:", analytics )
		    }
		});
	};
	
}


function Chatroom(elem)
{
	var $this = this;
	$this.elem = elem;
	
	
	$this.addLine = function(line)
	{
		$this.elem.append("<li>" + line + "</li>");
		$this.scrollDown();
	};
	
	
	$this.scrollDown = function()
	{
		$this.elem.animate({ scrollTop: $this.elem.prop("scrollHeight") }, 0);
	};
		
}


function Guid()
{
	var $this = this;
	$this.S4 = function() 
	{
	   return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
	}
	
	
	$this.generate = function() 
	{
	   return ($this.S4() + $this.S4() + "-" + $this.S4() + "-" + $this.S4() + "-" + $this.S4() + "-" + $this.S4() + $this.S4() + $this.S4());
	}
}


var chatroom = new Chatroom($("#manuscript"));
var chatter = new Chatter(channel, user);
chatter.joinRoom(chatroom);
chatter.numberOfChatters();

var say = $("#say-something");
say.bind("keyup", function(e){
	var code = (e.keyCode ? e.keyCode : e.which);

	if(code == 13)
	{
		chatter.postMessage(say.val());
		say.val("");
	}
});


window.onbeforeunload = function()
{
	return chatter.leaveRoom();
}