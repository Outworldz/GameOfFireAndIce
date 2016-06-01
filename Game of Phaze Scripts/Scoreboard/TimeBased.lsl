// Sign


string osMovePen(string drawList, integer x, integer y) { return drawList;}
string osDrawText(string drawList, string text) {return drawList;}
osSetDynamicTextureData(string dynamicID, string contentType, string data, string extraParams, integer timer) {;}



integer debug = TRUE;

DEBUG(string msg)
{
    if (debug)
       llSay(0,llGetScriptName() + " :" + msg);
}


key http_request_id;
list raceTime;

Display(string body)
{
    DEBUG(body)    ;

    string CommandList = "FontSize 10;"; // Storage for our drawing commands
    CommandList = osMovePen( CommandList, 10, 10 );           // Upper left corner at <10,10>
    
    CommandList = osDrawText( CommandList, body); // Place some text
 
    // Now draw the image
    osSetDynamicTextureData( "", "vector", CommandList, "width:256,height:256", 0 );
}


default
{    
    state_entry()
    {
       // if (debug) llSay(0,"a4dd7d22-071e-47d3-98c7-4d793e07124a|Start|Ferd Frederix");     // for debug only
        llListen(55555,"","","");
        llSetTimerEvent(1);
    }
    
    listen( integer channel, string name, key id, string message )
    {
        integer totTime = 0;
        
        llOwnerSay("Sign heard:" + message);

        list x = llParseString2List(message,["|"],[]);

        key avikey = (key) llList2String(x,0);
        string score =  llList2String(x,1);

        string person = llList2String(x,2);

        if (score == "Start")
        {
            llOwnerSay(person + " just started");
            integer i;
            i = llListFindList(raceTime,[avikey]);
            if ( i == -1){
                raceTime += llGetUnixTime();
                raceTime += avikey;
                return;
               
            } else {
                raceTime = llListReplaceList(raceTime, [llGetUnixTime()], i-1,i-1);
                return;
            }
        }

        if (score =="Finish")
        {
            llOwnerSay(person + " just ended")            ;

            integer i;
            i = llListFindList(raceTime,[avikey]);
            if ( i == -1){
               return;    // do nothing - they never started
            } else {
                integer startTime = llList2Integer(raceTime,i-1); // get start
                integer endTime= llGetUnixTime();                 // get end
                totTime = endTime-startTime;
                raceTime = llDeleteSubList(raceTime,i-1,i); 
            }
        }

        string url = "http://www.outworldz.com/cgi/lowscoreboard.plx"
            + "?Avatar=" + llEscapeURL(person)
            + "&AvatarKey=" + llEscapeURL((string) avikey)
            + "&Score=" +(string)totTime
            + "&Game=Frankie";
        
        DEBUG(url);
        http_request_id = llHTTPRequest(url, [], "");

        llSetTimerEvent(20.0);
    }

    touch_start(integer total_number)
    {
        string aviname = llDetectedName(0);
        key avikey = llDetectedKey(0);
        string url = "http://www.outworldz.com/cgi/lowscoreboard.plx"
            + "?Avatar=" + llEscapeURL(aviname)
            + "&AvatarKey=" + llEscapeURL((string) avikey)
            + "&GetScore=1&Game=Frankie";
        
        DEBUG(url);
        http_request_id = llHTTPRequest(url, [], "");

        llSetTimerEvent(20.0);
    }

    timer()
    {
        llSetTimerEvent(0);
        string url = "http://www.outworldz.com/cgi/lowscoreboard.plx?HiScore=1&Game=Frankie";
        DEBUG(url);
        http_request_id = llHTTPRequest(url, [], "");
        
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == http_request_id)
        {
            //DEBUG(body);
            Display(body);
        }
    }
    


       
    changed(integer what)
    {
        llResetScript();
    }
     on_rez(integer startparam)
    {
        llResetScript();
    }

    
    
} 

 