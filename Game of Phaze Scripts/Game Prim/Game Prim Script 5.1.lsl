// Version 5.1 4-29-2014
// fred@mitsi.com
// author Ferd Frederix Copyright 2009
// Game Prim script

// contacts the server
// gets the data fields
//
// 4.0 fixed hints
// 4.1 some crap
// 4.2 opensim
// 4.3 link messages work
// 4.6 opensim changes
// 4.7 cleanup
// 4.8 added collision logic to stop double collides
// 4.9 added 'all giving' capability, more options to sit
// 5.0 enabled remote xlate
// 5.1 reject objects

// LOGIN URL = http://metaverse.mitsi.com/cgi/gamelogin.htm


// fiddly bits
integer debug = FALSE;

integer TOUCH = FALSE;            // set to TRUE if they can touch it to trigger this
integer SIT = FALSE;              // set to TRUE if this goes into a SEAT
integer COLLIDE = TRUE;          // set to TRUE if you want them to collide with  the prim

integer SPEACHOPTION = 1;        // Set to 0 for chat, 1 for IM, 2 for Scripted translator

vector OFFSET = <0,0,0>;         // offset to rez items with channel = 2.  <0,0,2> will rez the object 2 metera above the prim. Max = 10 meters.

// not fiddly bits
list stack;                    // place to store HTTP traffic
integer HTTPSTRIDE = 2;        // 3 items in a stack = 2 here as it starts option 0

string Version = "5.0";
integer OUT_CHANNEL = -30;        // the output channel if translation is enabled


// Steers the conversation to the correct actor
Tell (string story,key lasttouched) {
    
    if (debug) llOwnerSay("tell");
    string lang = llGetAgentLanguage(lasttouched);
    string Name = llKey2Name(lasttouched);
    lang = llGetSubString(lang,0,1);
    if (lang == "")
        lang = "en";


     //lang="de";  // way  to check german

    if (SPEACHOPTION == 0) {
        if (debug) llOwnerSay("llSaying");
        llSay(0,story);
    }
    else if (SPEACHOPTION == 1) {
        if (debug) llOwnerSay("Sending IM");
        llInstantMessage(lasttouched,story);
    }
    else if (SPEACHOPTION == 2)
    {
        if (lang != "en") {
            if (debug) llOwnerSay("Sending LINK");
            llMessageLinked(LINK_THIS,OUT_CHANNEL,Name + "|" + lang + "|" +  story,lasttouched);
        }
        else {
            if (debug) llOwnerSay("Sending Direct IM");
            llInstantMessage(lasttouched,story);
        }
    } else {
        llOwnerSay("Illegal SpeechOption");
    }
}

// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
// * The real start of the universe.
// * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Ping(string AvatarName,key AvatarKey)
{
    string Language = llEscapeURL(llGetAgentLanguage(AvatarKey));
    string Me = llEscapeURL(llGetObjectName());
    string Them = llEscapeURL(AvatarKey);
    string Theirname = llEscapeURL(AvatarName);
    if (debug)
        Theirname = "Ferd Frederix";

    string url = "http://www.outworldz.com/cgi/llgame.plx?PrimName=" + (string) Me + "&Ver=" + Version + "&AvatarKey=" + (string)Them + "&Language=" + Language;

    if (AvatarKey != NULL_KEY)
        url +=  "&Avatar=" + (string)Theirname  ;
    if (debug ) llOwnerSay(url);

    stack += AvatarKey;
    stack += Theirname;
    stack += llHTTPRequest(url, [], "");
}


default
{
    state_entry()
    {
        llSetTimerEvent(1);

        if (COLLIDE == TRUE)
            llVolumeDetect(TRUE);
        else
            llVolumeDetect(FALSE);
    }

    timer()
    {
        llSetTimerEvent(3600);  // hourly
        Ping("Ping", NULL_KEY);
    }

    // save the Web server data for this prim
    http_response(key request_id, integer status, list metadata, string body)
    {
        integer where = llListFindList(stack,   [request_id]) ;
        if (where > -1)      
        {
            stack = llDeleteSubList(stack,where-HTTPSTRIDE,where);    // key, name, request ID

            if (llGetListLength(stack) > 10 * HTTPSTRIDE )    // 10 at a time, the rest can go phooey
                stack = llDeleteSubList( stack, 0, HTTPSTRIDE ); // kill off 1st element, is old
    
            // $status|$display|$sound|$Channel|$ChannelText|$AvatarKey
            if (debug) llOwnerSay("Response Body:" + body);

            list my_detail = llParseString2List( body,["|"],[]);
            if (debug) llOwnerSay("Dump:" + llDumpList2String(my_detail,","));

            string statusType = llList2String(my_detail,0);
            string storyText = llList2String(my_detail,1);
            string SoundUUID = llList2String(my_detail,2);
            integer ActionChannel = (integer) llList2String(my_detail,3);
            string ActionText = llList2String(my_detail,4);
            string AvatarKey = llList2String(my_detail,5);


            if (statusType == "ACK"  && llStringLength(AvatarKey) > 1 )
            {
                if (debug) llOwnerSay("Calling tell");
                
                if (llStringLength(storyText) > 1)
                    Tell (storyText, AvatarKey);    // speak it one of 3 ways

                // play sound, if any
                if (llStringLength(SoundUUID) > 1 ) {
                    if (debug) llOwnerSay("Playing sound " + SoundUUID);
                    llTriggerSound(SoundUUID,1.0);
                }

                // They had the requirements, or there was no dependency,  and there was text in the Channel
                if (ActionChannel)
                {
                    if (debug)
                        llOwnerSay("Sending Link command " +  ActionText  + " on channel " + (string) ActionChannel);
                    llMessageLinked(LINK_SET,ActionChannel,ActionText, AvatarKey); // pass it to other scripts.
                    llSay(ActionChannel,ActionText); // pass it to other scripts.

                    
                    // if it is there and num = 1, give it as a gift
                    if (ActionChannel  == 1)  {
                        if (debug) llOwnerSay("Giving item:" + ActionText);
                        llGiveInventory(AvatarKey,ActionText);
                    }

                    // if it is there and num = 2, rez it as an effect
                    if (ActionChannel == 2 ) {
                         if (debug) llOwnerSay("Rezzing Object:" + ActionText);
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
                llOwnerSay(" prim collided ");

            integer i;
            for (; i < total_number; i++)
            {
                if (debug) llOwnerSay("Collided by " + (string) llDetectedKey(i));
    
                list reject = llGetObjectDetails(llDetectedKey(i), [OBJECT_CREATOR]);
                key x = llList2Key(reject,0);
                if (x == NULL_KEY)
                    Ping(llDetectedName(i), llDetectedKey(i));
            }
        }
    }
    touch_start(integer total_number)
    {

        if (TOUCH) {

            if (debug)
                llOwnerSay(" prim touched ");

            integer i;
            for (; i < total_number; i++)
            {
                if (debug) llOwnerSay("Touched by " + (string) llDetectedKey(i));
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
        if (mask & CHANGED_LINK)
        {
            key avatarKey = llAvatarOnSitTarget();    // see if they sat down
            if (avatarKey != NULL_KEY)
            {
                Ping(llKey2Name(avatarKey), avatarKey);
            }
        }
    }


}