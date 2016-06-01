
// Game register ( basic) 
// 4/13/2014


integer debug = 0;

string version = "1.0";
integer counter = 0;
key http_request_id;
string url;
key urlRequestId;
key selfCheckRequestId;
string type;


DEBUG(string msg)
{
    if (debug)
        llOwnerSay(llGetScriptName() + "  " + msg);
}


 
reset_script()
{
    llReleaseURL(url);
    llResetScript();
}

string get_post_value(string content, string returns)
{
//  this parses application/x-www-form-urlencoded POST data
 
//  for instance if the webserver posts 'data1=hi&data2=blah' then
//  calling get_post_value("data1=hi&data2=blah","data1"); would return "hi"
//  written by MichaelRyan Allen, Unrevoked Clarity
 
    list params =  llParseString2List(content,["&"],[]);
    integer index = ~llGetListLength(params);
 
    list keys;// = [];
    list values;// = [];
 
    // start with -length and end with -1
    while (++index)
    {
        list parsedParams =  llParseString2List(llList2String(params, index), ["="], []);
        keys += llUnescapeURL(llList2String(parsedParams, 0));
        values += llUnescapeURL(llList2String(parsedParams, 1));
    }
 
    integer found = llListFindList(keys, [returns]);
    if(~found)
        return llList2String(values, found);
//  else
        return "";
}

register(string callback)
{
    string url = "http://www.outworldz.com/cgi/httpregister.plx?uuid="
                + (string) llGetKey()
                + "&url=" + llEscapeURL(callback)
                + "&name=" + llEscapeURL(llGetObjectName());
    
    DEBUG(url);
     http_request_id = llHTTPRequest(url, [], "");
}


request_url()
{
    llReleaseURL(url);
    url = "";

    urlRequestId = llRequestURL();
}

throw_exception(string inputString)
{
    key owner = llGetOwner();
    llInstantMessage(owner, inputString);
    
    llSetText(inputString,<1,1,1>,1.0);
 
    // yeah, bad way to handle exceptions by restarting.
    // However this is just a demo script...
    llSleep(300);
    reset_script();
}
default
{
    state_entry()
    {
        llSetText("Request",<1,1,1>,1.0);
        request_url();
    }

    changed(integer change)
    {
        if (change & (CHANGED_REGION | CHANGED_REGION_START | CHANGED_TELEPORT))
            request_url();
    }
    http_request(key id, string method, string body)
    {
        integer responseStatus = 400;
        string responseBody = "Unsupported method";
 
        if (method == URL_REQUEST_DENIED) {
            throw_exception("The following error occurred while attempting to get a free URL for this device:\n \n" + body);
            llSetText(body,<1,1,1>,1.0);
 
        } 
        else if (method == URL_REQUEST_GRANTED)
        {
            DEBUG(body);
            url = body;
            key owner = llGetOwner();
            llSetText("Waiting",<1,1,1>,1.0);
            register(body);
 
            // check every 5 mins for dropped URL
            llSetTimerEvent(300.0);
        }
        else if (method == "GET")
        {
            responseStatus = 200;
            responseBody = (string) counter++;
            llSetText("OK",<1,1,1>,1.0);
            type = "GET";
            llSetTimerEvent(90);
        }
        else if (method == "POST") {
           
            //DEBUG("POST body:" + body);            
            string command = get_post_value(body,"cmd");
            string uuid = get_post_value(body,"uuid");
            
            llOwnerSay("Server Command: "  + command);
            llOwnerSay("Server UUID: "  + uuid);
            
            llMessageLinked(LINK_SET,0,command,(key) uuid);
            
            responseStatus = 200;
            responseBody = "ACK"; 
            llSetText("OK",<1,1,1>,1.0);
        }
        else if (method == "PUT") {
            responseStatus = 200;
            responseBody = "PUT"; 
            llSetText("OK",<1,1,1>,1.0);
        }
        // else if (method == "DELETE") { responseStatus = 403; responseBody = "forbidden"; }
        llHTTPResponse(id, responseStatus, responseBody);
    }

    http_response(key id, integer status, list metaData, string body)
    {
        
        DEBUG(body);
        
        if (id == selfCheckRequestId)
        {
            // If you're not usually doing this,
            // now is a good time to get used to doing it!
            selfCheckRequestId = NULL_KEY;
 
            if (status != 200)
                request_url();
        }
 
        else if (id == NULL_KEY)
            throw_exception("Too many HTTP requests too fast!");
    }
            
     timer()
    {
        
        if (type == "GET")
        {
             llSetText("TIMEOUT!",<1,0,0>,1.0);
            type = "";
            llSetTimerEvent(300);
            return;
        }
        
        llSetText("Check",<1,1,1>,1.0);
        selfCheckRequestId = llHTTPRequest(url,
                                [HTTP_METHOD, "GET",
                                    HTTP_VERBOSE_THROTTLE, FALSE,
                                    HTTP_BODY_MAXLENGTH, 16384],
                                "");
    }

    on_rez(integer start)
    {
        llResetScript();
    }
    
}
