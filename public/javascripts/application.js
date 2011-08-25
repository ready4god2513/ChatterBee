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
				
		PUBNUB.subscribe({
		    channel  : self.channel,
		    callback : function(message) 
			{
				self.parseMessage(message);
				self.updatePageTitle("new message from " + message.user);
			}
		});
		
		
		self.loadHistory();
		
		// We need to register the user in the room.  We may make another room
		// to do this and just keep that list up to date unless we can get a list of
		// all of the currently subscribed users
	},
	
	
	self.leaveRoom = function()
	{
		console.log("Leaving room: " + self.chatroom + " on channel: " + self.channel);
		PUBNUB.unsubscribe({ channel : self.channel });
		
		// We need to unregister the user from the room.  We may make another room
		// to do this and just keep that list up to date unless we can get a list of
		// all of the currently subscribed users
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
			self.chatroom.addLine("<span class='left-chat'>" + message.user + " " + message.message + "</span>");
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


if(typeof(user) != "undefined")
{
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
}



function initiate_geolocation() 
{  
    navigator.geolocation.getCurrentPosition(handle_geolocation_query, handle_errors);  
}  

function handle_errors(error)  
{  
    switch(error.code)  
    {  
        case error.PERMISSION_DENIED: console.log("user did not share geolocation data");  
        break;  

        case error.POSITION_UNAVAILABLE: console.log("could not detect current position");  
        break;  

        case error.TIMEOUT: console.log("retrieving position timed out");  
        break;  

        default: console.log("unknown error");  
        break;  
    }  
}  

function handle_geolocation_query(position)
{
	$.ajax({
		url: "/auth/location",
		type: "post",
		data: "latitude=" + position.coords.latitude + "&longitude=" + position.coords.longitude,
		success: function(message)
		{
			$("#location").val(message);
		}
	});
}

$(function(){
	initiate_geolocation();
});


window.onbeforeunload = function(e)
{
	return chatter.leaveRoom();
}