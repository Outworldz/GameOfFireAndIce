// adds a message from llGame.plx to the event queue if on channel 100

key http_request_id;
integer debug = 1;
integer HUDchannel = 666;

default
{


    link_message( integer sender_num, integer num, string str, key id )
    {
        llOwnerSay("triggered " + str + "\n");
        if (str == "killNPC")
        {
            string url = "http://www.outworldz.com/cgi/llGameMagic.plx?PassFail=1&"
                
                + "Event=" + llEscapeURL(str)
                + "&Language=" + llGetAgentLanguage(id) 
                + "&AvatarName=" + llEscapeURL(llKey2Name(id)) 
                + "&AvatarKey=" + llEscapeURL(id)
                ;
            
            llOwnerSay(url);
            http_request_id = llHTTPRequest(url, [], "");
        }
    }
 
    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == http_request_id) {
            if (debug)
                llOwnerSay("Advance Game: " +  body);

            list result = llParseString2List(body,["|"],[]);
            // print "ACK|$totFluff|$text";
            if (llList2String(result,0) == "ACK"){
                llSay(0,llList2String(result,2));
                llSay(HUDchannel,"sheep|" +  llList2String(result,1));
            }
        }
        
        
    } 
}

