// In World Game receiver.
// Registers HTTP-IN to server and waits for processing messages to be sent asyncronously from server

// Messages:

// Game Receiver:
// passkey = RegionCPU
//
// CMD=llRegionSay
// Channel = (integer) > 0
// Message = text to send on channel
// ACK on channel > 0
// NAK if channel == 0

// CMD=llInstantMessage
// AvatarKey= UUID
// Message=text to send to UUID
// ACK on success
// NAK on bad key or length message == 0

// bad command: UNK

// Revisions:
// 3-04-2014 initial LSLEdit test

integer debug = TRUE;

float SCANTIME = 60;

// http://192.168.1.4:5000/reg/?UUID=passkey&URL=http://myHTTP-IN

string myurl = "http://www.free-lsl-scripts.com:5000/reg/";

string passkey = "RegionCPU";

key http_RequestKey ;
string URL;             // the tiny URL 

// cmd from server


integer initted = 0; // has the password been spoken from registering?

integer counter= 0;
integer timecount = 1;  // how often to register with the server
integer POLL_TIME = 10; // 10 minutes to register      


// http state counter
key requestURL;
integer http_state = FALSE;

integer HTTP_CHECK = 1;
integer HTTP_REGISTER = 2;       
integer HTTP_SERVER = 3;


// get the POST parameters
string Param(list incomingMessage,string param)
{
    integer index = llListFindList(incomingMessage,[param]);
    string retval;
    if (index > -1)
        retval = llList2String(incomingMessage,index+1);

    return retval;
}


DEBUG(string msg)
{
    if (debug)
        llSay(0,llGetScriptName() + ":" + msg);
}

register_HTTPIN()
{
    DEBUG("REGISTER HTTP_IN");
    llReleaseURL(URL);
    http_state = HTTP_REGISTER;
    requestURL= llRequestURL();
    DEBUG((string) requestURL);
}

register_Server()
{
    DEBUG("REGISTER SERVER");
    http_state = HTTP_SERVER;
    string url = myurl + "?UUID=" + passkey + "&URL=" + llEscapeURL(URL);
    llSetTimerEvent(SCANTIME);
    http_RequestKey = llHTTPRequest( url, [], "");
    DEBUG((string) http_RequestKey);  
}

check_Server()
{
    DEBUG("DIAGNOSE START");
    http_state = HTTP_CHECK;
    http_RequestKey=  llHTTPRequest( URL, [], "");
    DEBUG((string) http_RequestKey);  
}
    
// ###############################################
// Routine to parse a string sent through the 
// http server via post.
//       parsePostData(theMessage)
// Returns a strided list with stride length 2.
// Each set has the key and then its value.
list parsePostData(string message) {
    list postData = [];         // The list with the data that was passed in.
    list parsedMessage = llParseString2List(message,["&"],[]);    // The key/value pairs parsed into one list.
    integer len = ~llGetListLength(parsedMessage);
 
    while(++len) {          
        string currentField = llList2String(parsedMessage, len); // Current key/value pair as a string.
 
        integer split = llSubStringIndex(currentField,"=");     // Find the "=" sign
        if(split == -1) { // There is only one field in this part of the message.
            postData += [llUnescapeURL(currentField),""];  
        } else {
            postData += [llUnescapeURL(llDeleteSubString(currentField,split,-1)), llUnescapeURL(llDeleteSubString(currentField,0,split))];
        }
    }
    // Return the strided list.
    return postData ;
}



default
{
    state_entry()
    {
        register_HTTPIN();
    }
    
    changed(integer what)
    {
        if (what & CHANGED_REGION_START)
        {
            register_HTTPIN();
        }
    }
    
    timer()
    {
        check_Server();
    }
    
    http_response(key request_id, integer status, list metadata, string body)
    {
        DEBUG("Body:" +  body);
        if (http_RequestKey == request_id && status == 200)
        {
            if (http_state == HTTP_SERVER && status == 200)
            {
                llSetTimerEvent(60);    // start diagnostics
                DEBUG("Diagnostics started");
            }
            else if (http_state == HTTP_CHECK)
            {
                if (body != "GET")
                {
                    llOwnerSay("HTTP-IN died in " + llGetScriptName());
                    llSleep(60);
                    register_HTTPIN();
                }
                else
                {
                    DEBUG("Diagnostic passed");
                }
            }
        }
        http_state = FALSE;
    }
   
    on_rez(integer param)
    {
        llResetScript();
    }
    
    http_request(key id, string method, string body) 
    {
        DEBUG("Body:" +  body);
        
        if ((method == URL_REQUEST_GRANTED) && (id == requestURL) ){
            // An URL has been assigned to me.
            URL = body;
            register_Server();
        }
        else if ((method == URL_REQUEST_DENIED) && (id == requestURL)) {
            // I could not obtain a URL
            llOwnerSay("There was a problem, and a URL was not assigned: " + body);
            requestURL = NULL_KEY;
            llSleep(60);
            register_HTTPIN();
        }
        else if (method == "POST") {

            // An incoming message was received.
           DEBUG("Received information from the outside: " + body);
           list incomingMessage = parsePostData(body);
            
           DEBUG("List of Data = " + llDumpList2String(incomingMessage,"\n"));

           string cmd = Param(incomingMessage,"CMD");
           DEBUG("cmd:" + cmd);
            
           if (cmd == "llRegionSay")
           {
                integer  Channel = (integer) Param(incomingMessage,"Channel");
                string Message  = Param(incomingMessage,"Message");
                if (Channel > 0) {
                    llRegionSay(Channel, Message);
                    llHTTPResponse(id,200,"ACK");
                }
                else
                {
                    llHTTPResponse(id,200,"NAK");
                }
           }
           else if (cmd == "llInstantMessage")
           {
                key AvatarKey = (key) Param(incomingMessage,"AvatarKey");
                string Message  = Param(incomingMessage,"Message");
                if ((key) AvatarKey != NULL_KEY && llStringLength(Message) > 0)
                {
                    llInstantMessage(AvatarKey, Message);
                    llHTTPResponse(id,200,"ACK");
                }
                else
                {
                    llHTTPResponse(id,200,"NAK");
                }
           }
           else
           {
                //if (debug) llOwnerSay("unknown message");
                llHTTPResponse(id,200,"UNK");
           }
        }
        else {
            // An incoming message has come in using a method that has
            // not been anticipated.
            llHTTPResponse(id,200,"GET");
        }
        http_state = FALSE;
    }


}

