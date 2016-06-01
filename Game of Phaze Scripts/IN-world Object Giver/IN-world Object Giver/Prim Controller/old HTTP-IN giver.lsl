integer debug = FALSE;

string Version = "0.1";
key gID;

string myurl = "http://someserver.com/primgiver.plx?Giver="  ;


key http_RequestKey ;
integer init = 0;
string URL;             // the tiny URL 
string whatURL   = "http://w-hat.com/name2key"; // name2key url
string avatar;
string UUID;

integer initted = 0; // has the password been spoken from registering?

integer counter= 0;
integer timecount;      // how often to register with the server
integer POLL_TIME = 10; // 10 minutes to register      


// http state counter
key requestURL;
integer http_state = FALSE;

integer HTTP_REGISTER = 2;       
integer HTTP_Key2Name = 1;


// get the POST parameters
string Param(list incomingMessage,string param)
{
    integer index = llListFindList(incomingMessage,[param]);
    string retval;
    if (index > -1)
        retval = llList2String(incomingMessage,index+1);

    return retval;
}



register_Server()
{
    http_state = HTTP_REGISTER;


    string url = myurl + URL ;
    
    if (debug) llOwnerSay(url);
    http_RequestKey=  llHTTPRequest( url, [], "");
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
        llSetTimerEvent(2.0); 
    }
    
    changed(integer what)
    {
        if (what & CHANGED_REGION_START)
        {
            requestURL= llRequestURL();
        }
    }
    
    timer()
    {
        if (!init)
            requestURL= llRequestURL();
        
        llSetTimerEvent(60.0); 
        if (timecount++ % POLL_TIME == 0)
            register_Server();
    }
    
    
  
    
    http_response(key request_id, integer status, list metadata, string body)
    {
        
        //if (debug) llOwnerSay(body);
        //if (debug) llOwnerSay("talk it in chat =" + (string) http_state );
        
        if (http_RequestKey == request_id && status == 200)
        {
            if (http_state == HTTP_Key2Name)
            {
                if (debug) llOwnerSay("Key2Name " + body);
                if ( (key) body == NULL_KEY )
                {
                    llHTTPResponse(gID,200,"Cannot locate avatar:" + avatar);
                }   
                else
                {
                    llGiveInventory((key) body,"Prim");
                    counter++;
                    llSetText((string) counter + " textures issued", <1,1,1>, 1.0);
                    llHTTPResponse(gID,200,"Item sent to:" + avatar );
                }
            }
            if (http_state == HTTP_REGISTER && ! initted++)
            {
                llOwnerSay(body);
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
         gID = id;
         list incomingMessage;
 
        if ((method == URL_REQUEST_GRANTED) && (id == requestURL) ){
            // An URL has been assigned to me.
            URL = body;
            init++;
            register_Server();
        }
        else if ((method == URL_REQUEST_DENIED) && (id == requestURL)) {
            // I could not obtain a URL
            llOwnerSay("There was a problem, and a URL was not assigned: " + body);
            requestURL = NULL_KEY;
        }
        else if (method == "POST") {

            // An incoming message was received.
           // if (debug) llOwnerSay("Received information from the outside: " + body);
            incomingMessage = parsePostData(body);
            
            //if (debug) llOwnerSay(llDumpList2String(incomingMessage,"\n"));

  
            string type = Param(incomingMessage,"type");
            if (debug) llOwnerSay("type:" + type);
            
            
            if (type == "write")
            {
                avatar  = Param(incomingMessage,"Avatar");
                UUID = Param(incomingMessage,"UUID");
                
                
                http_state = HTTP_Key2Name;
                
                http_RequestKey = llHTTPRequest( whatURL + "?terse=1&name=" +
                               llEscapeURL(avatar), [], "" );

                
            }
            else
            {
                //if (debug) llOwnerSay("unknown message");
                llHTTPResponse(id,200,"unknown command");
            }
        }
        else {
            // An incoming message has come in using a method that has
            // not been anticipated.
            llHTTPResponse(id,200,"GET");
        }

    }


}

