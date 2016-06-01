// remove when live - only for LSLEditor use
integer osIsNpc(key npc) {return 0;}



// adds a message from llGame.plx to the event queue if on channel 100
// fiddly bits


integer debug = FALSE;

key http_request_id;

integer DragonChannelBack = 549898; // channel the dragomn talks back on.
integer DragonChannel = 549897; // secret channel to comm with Dragons. set to zero to not care about them
integer HUDchannel = 666;


// V2
// DEBUG(string) will chat a string or display it as hovertext if debug == TRUE
DEBUG(string str)
{
    if (debug)
        llOwnerSay(llGetScriptName() + ":" +  str);  
}
 
default
{
    state_entry() {
        llSetAlpha(0,ALL_SIDES);         
        llVolumeDetect(FALSE);
        llVolumeDetect(TRUE);
    }
  
    collision_start(integer total_number)
    { 
        
        DEBUG("Prim collided ");

        integer i;
        for (; i < total_number; i++)
        {
            DEBUG("Collided by " + (string) llDetectedKey(i));
            if  (osIsNpc(llDetectedKey(i))) {
                DEBUG("NPC - rejected");
            } else {               
                llListen(DragonChannelBack,"","","");
                DEBUG("Asking Dragon");
                llSay(DragonChannel,(string) llDetectedKey(i));
                llTriggerSound(llGetInventoryName(INVENTORY_SOUND,0),1.0); 
            }
        } 
    
    }  
    
    changed(integer mask)
    {
         if (mask & (CHANGED_REGION_START))
            llResetScript();
    }
    
    listen(integer channel, string name, key is, string str)
    {
        DEBUG("Dragon said to collider " + str);
        llListenRemove(DragonChannel);
        key id = (key) str;
        
        llMessageLinked(LINK_SET,0,"KillNPC",id);
        
        string url = "http://www.outworldz.com/cgi/llGameMagic.plx?PassFail=1&"
            + "Event=" + llEscapeURL(llGetObjectName())
            + "&Language=" + llGetAgentLanguage(id) 
            + "&AvatarName=" + llEscapeURL(llKey2Name(id)) 
            + "&AvatarKey=" + llEscapeURL(id)
            ;
        
        DEBUG(url);
        http_request_id = llHTTPRequest(url, [], "");
    
    }
    

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == http_request_id) {
           DEBUG("Advance Game: " +  body);

            list result = llParseString2List(body,["|"],[]);
            // print "ACK|$totFluff|$text";
            if (llList2String(result,0) == "ACK"){
                llSay(0,llList2String(result,2));
                llSay(HUDchannel,"sheep|" +  llList2String(result,1));
                state wait;
            }
        }
        
         
    } 
}    
    
state wait {
    state_entry() {
        if (debug) llOwnerSay("Waiting");
        llSetTimerEvent(60);
    }
    timer()
    {
        llMessageLinked(LINK_SET,0,"StartNPC","");
        state default;
    }
}



