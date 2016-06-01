
// Author: Ferd Frederix

// slave to Que bots
// revisions:
// 3-18-2014 added safety for typing.

integer debug = FALSE;

string ani = "avatar_type";
key  http_request_id;

// link messages
integer HELLO = 1;
integer GOODBYE = 2;
integer CHAT  = 3;
integer sending = FALSE; // safety timer variable

DEBUG(string what)
{
    if (debug)
        llOwnerSay(llGetScriptName() + ":" + what);
}



bot_chat (string TYPE, string what)
{
    sending++;
    llSetTimerEvent(llFrand(1)+3);    // 1 to 3 seconds to think before typing

    // Try to use Display Name if possible.
    string myName = llGetDisplayName(llGetKey());
    if (! llStringLength(myName))
    {
        myName = llKey2Name(llGetKey());
    }
    myName = "Que Composer";
    
    string url = "http://www.free-lsl-scripts.com/cgi/BotChat.plx?type="
        + TYPE
        + "&q=" + llEscapeURL(what)
        + "&BotName=" + llEscapeURL(myName);
    
    DEBUG(url);
    http_request_id = llHTTPRequest(url, [], "");    
}



default
{

    attach(key what)
    {
         llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);  
    }
    
     run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TRIGGER_ANIMATION)
        {          
            llSay(0,"At your service");
        }
    }

    link_message(integer sender_number, integer number, string message, key id)
    {
        if (number == GOODBYE)
        {
            bot_chat("BYE", message);
        }
        else if (number == HELLO)
        {
            bot_chat("HELLO", message);
        }
        else if (number == CHAT)
        {
            message = llEscapeURL(message);
            bot_chat("CHAT", message);
        }
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (http_request_id == request_id)
        {
            DEBUG(body);
            // graceful shutdown
            llStopAnimation(ani);
            llSetTimerEvent(0);
            sending = 0;
        }
    }

    timer()
    {
        if (sending) {
            llStartAnimation(ani);
            llSetTimerEvent(20);
        } else {
            // have not heard from server in 10 seconds.
            llStopAnimation(ani);
            llSetTimerEvent(0);
            sending = 0;
        }
    }

}



