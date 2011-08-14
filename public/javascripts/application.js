var chatter = new function() 
{
	
	var self = this;
	self.chatroom = null;
	self.user = null;
	self.channel = null;
	
	
	self.setUser = function(user)
	{
		self.user = user;
	},
	
	
	self.setChannel = function(channel)
	{
		self.channel = channel;
	},
	
	
	self.joinRoom = function(room)
	{
		self.chatroom = room;
		
		console.log("Joined Room: " + self.chatroom + " on channel: " + self.channel);
		
		PUBNUB.subscribe({
		    channel  : self.channel,
		    callback : function(message) 
			{
				self.parseMessage(message);
				self.updatePageTitle("new message from " + message.user);
			}
		});
		
		
		self.loadHistory();
		self.postMessage("has joined the room.", "joined");
	},
	
	
	self.leaveRoom = function()
	{
		console.log("Leaving room: " + self.chatroom + " on channel: " + self.channel);
		PUBNUB.unsubscribe({ channel : self.channel });
		return self.postMessage("has left the chat.", "left");
	},
	
	
	self.postMessage = function(message, status)
	{
		console.log("Posted: " + message + " to: " + self.channel);
		
		PUBNUB.publish({
	        channel : self.channel, 
			message : {
				message: message,
				status: status,
				user: self.user,
				uuid: self.generateGuid()
			}
	    });
	},
	
	
	self.loadHistory = function()
	{
		console.log("Loading history for: " + self.channel);
		
		PUBNUB.history({
		    channel : self.channel,
		    limit : 100

		// Set Callback Function when History Returns
		}, function(messages) 
		{
		    for(i in messages)
			{
				self.parseMessage(messages[i]);
			}
		});
	},
	
	
	self.updatePageTitle = function(message)
	{
		$(document).attr("title", message);
		setTimeout(function(){
			$(document).attr("title", "jegit: Chat Freely");
		}, 4000);
	},
	
	
	self.parseMessage = function(message)
	{
		
		message.message = message.message.replace(/<.*?>/g, '');
		console.log("Parsing message: " + message + " with a status of: " + status);
		
		if(message.status == "left")
		{
			self.chatroom.addLine("<span class='left'>" + message.user + " " + message.message + "</span>");
		}
		else if(message.status == "joined")
		{
			self.chatroom.addLine("<span class='joined'>" + message.user + " " + message.message + "</span>");
		}
		else
		{
			self.chatroom.addLine("<strong class='user'>" + message.user + "</strong> " + message.message);
		}
		
	},
	
	
	self.generateGuid = function()
	{
		var guid = new Guid();
		return guid.generate();
	},
	
	
	self.numberOfChatters = function()
	{
		PUBNUB.analytics({
		    channel : self.channel,  // OPTIONAL
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


var chatroom = new function()
{
	var self = this;
	self.elem = null;
	
	
	self.setRoom = function(elem)
	{
		self.elem = elem;
	}
	
	
	self.addLine = function(line)
	{
		self.elem.append("<li>" + line + "</li>");
		self.scrollDown();
	},
	
	
	self.scrollDown = function()
	{
		self.elem.animate({ scrollTop: self.elem.prop("scrollHeight") }, 0);
	};
		
}


function Guid()
{
	var self = this;
	self.S4 = function() 
	{
	   return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
	}
	
	
	self.generate = function() 
	{
	   return (self.S4() + self.S4() + "-" + self.S4() + "-" + self.S4() + "-" + self.S4() + "-" + self.S4() + self.S4() + self.S4());
	}
}


chatroom.setRoom($("#manuscript"));
chatter.setUser(user);
chatter.setChannel(channel);
chatter.joinRoom(chatroom);
chatter.numberOfChatters();

var say = $("#say-something");
say.bind("keyup", function(e){
	var code = (e.keyCode ? e.keyCode : e.which);

	if(code == 13 && say.val() != "")
	{
		chatter.postMessage(say.val());
		say.val("");
	}
});


PUBNUB.subscribe({
    channel  : "chatters-count",
    callback : function(message) 
	{
		$("#chatters-count span").html(message);
	}
});


window.onbeforeunload = function(e)
{
	if (!e) 
	{
		e = window.event;
	}

	chatter.leaveRoom();
	
	//e.cancelBubble is supported by IE - this will kill the bubbling process.
	e.cancelBubble = true;
	e.returnValue = ""; //This is displayed on the dialog

	//e.stopPropagation works in Firefox.
	if (e.stopPropagation) 
	{
		e.stopPropagation();
		e.preventDefault();
	}
}