// Author: Ferd Frederix

// master chat controller to Que bots
// revisions:
// 3-17-2014 0.2 seems to work on Que
// 3-18-2014  0.3 fixes last character bug


string ani = "avatar_type";

float DISTANCE =  10.0;  // distance the picture will detect up an avatar, from 0.1 to 96.0.   Bigger numbers cause more lag
float RATE = 5.0;       // seconds to scan for an avatar, lower numbers cause more lag but faster response.
integer listener;

integer HELLO = 1;
integer GOODBYE = 2;
integer CHAT  = 3;

integer ActiveListening = FALSE ;

integer debug = TRUE;



DEBUG(string what)
{
    if (debug)
        llSay(0,llGetScriptName() + ":" + what);
}



default
{
    state_entry()
    {
        llSensorRepeat("","",AGENT,DISTANCE,PI,RATE);
    }

    attach(key id)
    {
         llSensorRepeat("","",AGENT,DISTANCE,PI,RATE);
    }


    sensor(integer num_detected)
    {
        integer i;
        integer AvatarNearby = FALSE;
        for(i = 0; i < num_detected; i++)
        {
            //DEBUG("Detected " + llDetectedName(0) + " @" + (string) llVecDist(llDetectedPos(i),llGetPos()) );
            if (llVecDist(llDetectedPos(i),llGetPos())  < DISTANCE )
            {
                AvatarNearby++;
            }
        }

        if (debug)
           AvatarNearby++;

         // new avatar present, start listening
        if (AvatarNearby && ActiveListening == FALSE)
        {
            DEBUG("Listening");
            if (! listener)
                listener = llListen(0,"","","");

            llMessageLinked(LINK_SET,HELLO,llDetectedName(0) + "^" + llGetAgentLanguage(llDetectedKey(0)),llDetectedKey(0));
            ActiveListening = TRUE;
        }

        // no one near, and we were listening
        if (!AvatarNearby && ActiveListening == TRUE)
        {
            DEBUG("Not Listening");
            llListenRemove(listener);
            listener = 0;
            ActiveListening = FALSE;

            llMessageLinked(LINK_SET,GOODBYE,llDetectedName(0) + "^" + llGetAgentLanguage(llDetectedKey(0)),llDetectedKey(0));
        }


    }

    no_sensor()
    {
       llListenRemove(listener);
       listener = 0;

       DEBUG("Not Listening");
        llListenRemove(listener);
        if(ActiveListening)
        {
            ActiveListening = FALSE;
            llMessageLinked(LINK_SET,GOODBYE,llDetectedName(0) + "^" + llGetAgentLanguage(llDetectedKey(0)),llDetectedKey(0));
        }
    }


    listen(integer channel, string name, key id, string message )
    {
        if (id == llGetOwner())
            return;

       // if (debug)
       // {
       //     llMessageLinked(LINK_SET,CHAT,name + "^" + llGetAgentLanguage(id) + "^" + message,id);
       //     return;
      //  }


        // get distance
        list place = llGetObjectDetails(id,[OBJECT_POS]);
        vector where = llList2Vector(place,0);
        
        // DEBUG("D:" + (string) llVecDist(where ,llGetPos()) );

        if (llVecDist(where ,llGetPos())  > DISTANCE && ! debug) {
            DEBUG("too far");
            return;
        }

        // ignore objects
        list detail = llGetObjectDetails(id,[OBJECT_CREATOR]);
        key who = llList2Key(detail,0);

        //DEBUG("key:" + (string) who);

        // objects have owners. avatars do not
        if (who == NULL_KEY)
        {
            // remove delimiter from chat
            integer idx = llSubStringIndex( message, "^");
            if (idx > -1)
                message = llDeleteSubString(message,idx,idx);

            string msg = name
                + "^" + llGetAgentLanguage(id)
                + "^" + message
                + "^" + (string) id
                + "^" + (string) where
                + "^" + llGetDisplayName(id);
                

            llMessageLinked(LINK_SET,CHAT,msg,id);
        }
    }

    on_rez(integer start)
    {
        llResetScript();
    }
}