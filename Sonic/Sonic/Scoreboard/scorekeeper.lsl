//3-30-2014

integer debug = TRUE;      // set to 1 or TRUE for debuging information to the owner


key urlRequestId;           // for gridspot
key selfCheckRequestId  ; // for self check
string UUID = "fluff scorekeeper";

string url;                // from llRequestURL
key URLReq = NULL_KEY;     // key of llRequestURL
integer nServed;           // how many requests serverd




string getData(string abody)
{
        
    DEBUG("Parsing " + abody);
    list incomingMessage = parsePostData(abody);

     // fake out a http header
    if (debug)
        incomingMessage = llParseString2List(abody,["="],[]);

    DEBUG("Params: " + llDumpList2String(incomingMessage,":"));

    string cmd = llUnescapeURL(llList2String(incomingMessage,0));
    
    string aviKey = llUnescapeURL(llList2String(incomingMessage,1));
    DEBUG("aviKey: " + aviKey);
    
    Name = llKey2Name((key) aviKey);
    DEBUG("Name: " + Name);

    string response ="Huh?";
    
    if (cmd == "Pass") {
        
        response = "PASS|" ;
        
        PassFail(1,aviKey);
        
    } else if (cmd == "Fail")  {        
        PassFail(0,aviKey);
        
    }
    
    DEBUG("getData:" + response);
    return response;
}




DEBUG(string msg)
{
    if (debug)
        llOwnerSay(llGetScriptName() + " : " + msg);
}




list parsePostData(string message)
{
    list postData = [];         
    list parsedMessage = llParseString2List(message,["&"],[]);    
    integer len = ~llGetListLength(parsedMessage);

    while(++len) {
        string currentField = llList2String(parsedMessage, len); 

        integer split = llSubStringIndex(currentField,"=");     
        if(split == -1) { 
            postData += [llUnescapeURL(currentField),""];
        } else {
            postData += [llUnescapeURL(llDeleteSubString(currentField,split,-1)), llUnescapeURL(llDeleteSubString(currentField,0,split))];
        }
    }
    
    return postData ;
}

key Passkey;

PassFail(integer PassFail, string aviKey )
{
    
    string url = "http://www.outworldz.com/cgi/llgameMagic.plx?AvatarKey=" + llEscapeURL(aviKey) + "&PassFail="  + (string) PassFail + "&AvatarName=" + llEscapeURL(Name);

    if (debug ) llOwnerSay(url);

    Passkey = llHTTPRequest(url, [], "");
}


request_url()
{
    DEBUG("get URL");
    llReleaseURL(url);
    url = "";
    urlRequestId = llRequestURL();
}



key Request(string URL)
{
    llSetText("Registering",<1,1,1>,1.0);
    DEBUG("Going to http-in");
    string url = "http://www.outworldz.com/cgi/httpregister.plx?uuid=" + llEscapeURL(UUID) + "&url=" + llEscapeURL(URL);

    return  llHTTPRequest( url, [HTTP_METHOD, "GET"], "");
}

string Name;

default
{
    state_entry()
    {
        llSetText("Initializing",<1,1,1>,1.0);
        request_url();
    }
    
    on_rez(integer param)
    {
        llResetScript();
    }

    http_request(key id, string method, string body)
    {
        DEBUG("http_request:" + method + ":" + body);
        if (method == URL_REQUEST_GRANTED)
        {
            DEBUG("url ready:" + url);
            url = body;    // save body response so we can release it.
            URLReq = Request(body);
            
            // check every 5 mins for dropped URL
            llSetTimerEvent(300.0);
        }
        else if(method == URL_REQUEST_DENIED)
        {
            llOwnerSay("ERROR: URL REQUEST was DENIED "+body);
            llSetText("ERROR: URL REQUEST was DENIED",<1,0,0>,1.0);
            llSleep(60);
            llResetScript();
        }
        else if(id == URLReq)
        {
            if (body == "OK")
            {
                DEBUG("http-in:" + body);
                //llSetText("OK",<1,0,0>,1.0);
                llHTTPResponse(id, 200, "");
            }
            else
            {
                llSetText("Unable to register",<0,0,1>,1.0);
            }
        }
        else if  (method == "POST")
        {
            DEBUG("POST");
            nServed++;
            string resp = getData(body);  

                      
            DEBUG("To-Prim:" + resp);
            llHTTPResponse(id, 200, resp);
        }
        
        else
        {
            llSetText("Not Implemented",<1,0,0>,1.0);
            llHTTPResponse(id, 501, "Not Implemented "+method);
        }
    }


    http_response(key request_id, integer status, list metadata, string body)
    {
        DEBUG("http_response:" + body);
        if (request_id == selfCheckRequestId)
        {
            // If you're not usually doing this,
            // now is a good time to get used to doing it!
            selfCheckRequestId = NULL_KEY;
 
            if (status != 200)
                request_url();
            else
                DEBUG("Test Passed");
        } 
        else if(URLReq == request_id){
            URLReq = NULL_KEY;       
            if(status == 200)
            {
                llSetText("Ok",<1,1,1>,1.0);
            }
            else
            {
                llSetText("Request failed",<1,0,0>,1.0);
                llOwnerSay("Request failed status="+(string)status+" "+body);
                llSleep(60);
                request_url();
            }
        }
        else if ( Passkey = request_id)
        {
            list stuff = llParseString2List(body,["|"],[]);
            string httpstatus = llList2String(stuff,0);
            if (httpstatus == "ACK")
            {
                key avatarKey = (key) llList2String(stuff,1);
                string msg =  llList2String(stuff,2);
                
                DEBUG(msg);
                llInstantMessage(avatarKey, msg);
                
                llSetText("Magic Happpened",<1,1,1>,1.0);
            }
        }
    }

    changed (integer what)
    {
     
        if (what & (CHANGED_REGION_START ))
        {
            llReleaseURL(url);
            request_url();
        }
    }
    
    
    
    timer()
    {
        DEBUG("Self-test");
        selfCheckRequestId = llHTTPRequest(url,
                                [HTTP_METHOD, "GET",
                                    HTTP_VERBOSE_THROTTLE, FALSE,
                                    HTTP_BODY_MAXLENGTH, 200],
                                "");
    }
    
    
    
}



