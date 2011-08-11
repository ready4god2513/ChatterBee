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
	};
	
	
	$this.leave = function()
	{
		console.log("Leaving room: " + $this.chatroom + " on channel: " + $this.channel);
		
		PUBNUB.publish({
	        channel : $this.channel, 
			message : {
				message: "left session",
				user: user,
				uuid: guid()
			}
	    });
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
		console.log("Parsing message: " + message);
		$this.chatroom.addLine(message.message);
	};
	
	
	$this.generateGuid = function()
	{
		var guid = new Guid();
		return guid.generate();
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
		$this.elem.animate({ scrollTop: $this.elem.prop("scrollHeight") }, 1000);
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
chatter.loadHistory();

var say = $("#say-something");
say.bind("keyup", function(e){
	var code = (e.keyCode ? e.keyCode : e.which);

	if(code == 13)
	{
		chatter.postMessage(say.val());
		say.val("");
	}
});