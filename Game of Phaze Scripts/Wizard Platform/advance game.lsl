// adds a message from llGame.plx to the event queue if on channel 100

key http_request_id;
integer debug = 0;


default
{


    link_message( integer sender_num, integer num, string str, key id )
    {
        if (debug) 
            llOwnerSay("trigger " + str + "\n");
        if (num == 100)
        {
            string url = "http://www.outworldz.com/cgi/GameTrigger.plx?" 
                + "Event=" + llEscapeURL(str)
                + "&Language=" + llGetAgentLanguage(id) 
                + "&AvatarName=" + llEscapeURL(llKey2Name(id)) 
                + "&AvatarKey=" + llEscapeURL(id)
                ;
            
            if (debug) 
                llOwnerSay(url);
            http_request_id = llHTTPRequest(url, [], "");
        }
    }
     http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == http_request_id)
        {
           if (debug)
            llOwnerSay("Advance Game: " +  body);
        }
    } 

            


}





