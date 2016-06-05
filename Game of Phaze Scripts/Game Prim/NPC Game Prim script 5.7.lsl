// fred@mitsi.com
// author Ferd Frederix Copyright 2009
// Game Prim script

// v 5.5 NPC uses the server to send text to a NPC
// V 5.6 adds a Set Status to turn phantom off to fix a bug on Linux.
//  It has a SPEACHOPTION of 3 for @say using a NPC All-InOne
//  Channel can be "rez' to rez an object by name
//  Channel can be "give to give an object by name

// LOGIN URL = http://www.outworldz.com/game

// uncomment this for use in LSLEditor
integer osIsNpc(key id) {return FALSE;}


string Version = "5.7"; //  helps spot old scripts at the web site 

// fiddly bits
integer debug = TRUE;    // if TRUE, should be in Spanish
integer TRANSLATE = FALSE;  // set to true to use Opensim Translation (dev builds only, will dump core on some machines)

// SET ONE OR MORE OF THESE
integer COLLIDE = TRUE;          // set to TRUE if you want them to collide with  the prim
integer TOUCH = TRUE;            // set to TRUE if they can touch it to trigger this
integer SIT = TRUE;              // set to TRUE if this goes into a SEAT
integer CollideObjects = FALSE;  // set to TRUE to allow things to bump this prim (unlikely, but physical objects can run into it)
integer SPEACHOPTION = 2;        // Set to 0 for chat, 1 for Private Message, 2 for NPC @say
vector OFFSET = <0,0,2>;         // offset to rez items with channel = "rez".  <0,0,2> will rez the object 2 meters above the prim. Max = 10 meters.

// not fiddly bits
list stack;                    // place to store HTTP traffic
integer HTTPSTRIDE = 2;        // 3 items in a stack = 2 here as it starts option 0

DEBUG(string msg){
    if (debug) llSay(0,msg);
}

// Steers the conversation to the correct actor
Tell (string story,key lasttouched, string ActionChannel)
{
    if (SPEACHOPTION  == 0 ) {
        llSay(0,story);
    } else if (SPEACHOPTION == 1)  {
        DEBUG("Sending IM " + story + " to " + llKey2Name(lasttouched));
        llRegionSayTo(lasttouched,0,story);
    } else{
        if ((integer) ActionChannel) {
            list commands = llParseString2List(story,["\n"],[]);
            integer n = llGetListLength(commands);
            integer i = 0;
            while (i < n) {
                string s = llList2String(commands,i);
                DEBUG("Sending NPC " + s) ;
                llMessageLinked((integer) ActionChannel,0,s, ""); // pass it to other scripts.
                i++;
            }
        }
    }
}



Ping(string AvatarName,key AvatarKey)
{
    string Language = "en" ;
    // only works on later dev builds as of 9-2015
    if (TRANSLATE)
        Language = llEscapeURL(llGetAgentLanguage(AvatarKey));
    
   if (debug)   llSay(0,"Language: " + Language);
        
    string Me = llEscapeURL(llGetObjectName());
    string Them = llEscapeURL(AvatarKey);
    string Theirname = llEscapeURL(AvatarName);
   
    string url = "http://www.outworldz.com/cgi/llgame.plx"
        + "?PrimName=" + (string) Me
        + "&Ver=" + Version
        + "&AvatarKey=" + (string)Them
        + "&Language=" + Language;

    if (AvatarKey != NULL_KEY)
        url +=  "&Avatar=" + (string)Theirname  ;
    if (debug ) llOwnerSay(url);

    stack += AvatarKey;
    stack += Theirname;
    stack += llHTTPRequest(url, [], "");
}


// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * The real start of the universe.
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

default
{
    
    on_rez(integer p)
    {
        llResetScript();
    }
    state_entry()
    {
        llSetTimerEvent(1);
          
        if (COLLIDE == TRUE)
        {
            llSetStatus(STATUS_PHANTOM,TRUE);
            llVolumeDetect(FALSE);
            llVolumeDetect(TRUE);
        }
        else {
            llVolumeDetect(FALSE);
            llSetAlpha(1,ALL_SIDES);  
        }
    }

    timer()
    {
        llSetTimerEvent(3600);  // hourly
        Ping("Ping", NULL_KEY);
    }

    // save the Web server data for this prim
    http_response(key request_id, integer status, list metadata, string body)
    {
        if (debug) llSay(0,"Response Body:" + body);
        integer where = llListFindList(stack,   [request_id]) ;
        if (where > -1)      
        {
            stack = llDeleteSubList(stack,where-HTTPSTRIDE,where);    // key, name, request ID

            if (llGetListLength(stack) > 10 * HTTPSTRIDE )    // 10 at a time, the rest can go phooey
                stack = llDeleteSubList( stack, 0, HTTPSTRIDE ); // kill off 1st element, is old

            // $status|$display|$sound|$Channel|$ChannelText|$AvatarKey


            list my_detail = llParseString2List( body,["|"],[]);
            DEBUG("Dump:" + llDumpList2String(my_detail,","));

            string statusType = llList2String(my_detail,0);
            string storyText = llList2String(my_detail,1);
            string SoundUUID = llList2String(my_detail,2);
            string ActionChannel = llList2String(my_detail,3);
            string ActionText = llList2String(my_detail,4);
            string AvatarKey = llList2String(my_detail,5);

            if (statusType == "NAK"  && llStringLength(AvatarKey) > 1 )
            {
                DEBUG("NAK");

                if (llStringLength(storyText) > 1)
                    Tell (storyText, AvatarKey, ActionChannel);    // speak it one of 3 ways

            } else if (statusType == "ACK"  && llStringLength(AvatarKey) > 1 )            {
                DEBUG("ACK");

                if (llStringLength(storyText) > 1)
                    Tell (storyText, AvatarKey, ActionChannel);    // speak it one of 3 ways

                // play sound, if any
                if (llStringLength(SoundUUID) > 1 ) {
                    DEBUG("Playing sound " + SoundUUID);
                    llTriggerSound(SoundUUID,1.0);
                }

                // They had the requirements, or there was no dependency,  and there was text in the Channel
                if (ActionChannel)
                {
                    if (debug)
                        llOwnerSay("Sending Link/RegionSat command " +  ActionText  + " on channel " + (string) ActionChannel);
                    llMessageLinked(LINK_SET,(integer) ActionChannel,ActionText, AvatarKey); // pass it to other scripts.
                    if ((integer) ActionChannel > 0)
                        llRegionSay((integer) ActionChannel,ActionText); // pass it to other scripts.


                    // if it is there and num = 1, give it as a gift
                    if (ActionChannel  == "give")  {
                        DEBUG("Giving item:" + ActionText);
                        llGiveInventory(AvatarKey,ActionText);
                    }

                    // if it is there and num = 2, rez it as an effect
                    if (ActionChannel == "rez" ) {
                        DEBUG("Rezzing Object:" + ActionText);
                        llRezObject(ActionText ,llGetPos() + OFFSET,  ZERO_VECTOR , ZERO_ROTATION,0);
                    }
                }
            }
        }        
    }

    collision_start(integer total_number)
    {
        if (COLLIDE) {

            if (debug)
                llSay(0," prim collided ");

            integer i;
            for (; i < total_number; i++)
            {
                if (debug) llSay(0,"Collided by " + (string) llDetectedKey(i));
                if (! osIsNpc(llDetectedKey(i)))
                {
                    if (CollideObjects)
                    {
                        list reject = llGetObjectDetails(llDetectedKey(i), [OBJECT_CREATOR]);
                        key x = llList2Key(reject,0);
                        if (x == NULL_KEY)
                            Ping(llDetectedName(i), llDetectedKey(i));
                    } else {
                        Ping(llDetectedName(i), llDetectedKey(i));
                    }
                }
            } 
        }
    }
    touch_start(integer total_number)
    {

        if (TOUCH) {

            if (debug) llSay(0," prim touched ");

            integer i;
            for (; i < total_number; i++)
            {
                if (debug) llSay(0,"Touched by " + (string) llDetectedKey(i));
                Ping(llDetectedName(i), llDetectedKey(i));
            }
        }
    } 
   
    changed(integer mask)
    {
        if (mask & CHANGED_INVENTORY)
        {
            llResetScript(); 
        }
        if ((mask & CHANGED_LINK) && SIT)
        {
            key avatarKey = llAvatarOnSitTarget();    // see if they sat down
            if (avatarKey != NULL_KEY)
            {
                Ping(llKey2Name(avatarKey), avatarKey);
            }
        }
         if (mask & CHANGED_REGION_START)
         {
             llResetScript();
         }
    }
 

}