// 5-26-2016
// :CATEGORY:Games
// :NAME:Burn them all
// :AUTHOR:Vegaslon Plutonian
// :REV:1.0
// :WORLD:Second Life, OpenSim
// :DESCRIPTION:
// A Simple Game where you use a dragon to burn things.

// :CODE:


// settable flags and c9nstants
integer debug = TRUE;
integer Good_Bad = TRUE; // If set TRUE it adds to the score. If FALSE, it subtracts

integer Hit = 1;    // add 1 point for a hit
integer Miss=-5;    //lose 5 points for a miss
integer BURNINGTIME = 120;        // how long it will be on fire and then accept hits again.
string MagicName = "Lost Bit of Magic";  //The object we rez when they hit something bad.
string sonicring = "magic-string-spell-1";    // failsound
string sonicringhurt = "sonicringhurt";
string glass1 = "glass1";
string glass2 = "glass2";
string glass3 = "glass3";


float damage;   // place to hold the current flame damage
string name;    // holds the object name
integer visible = TRUE;         // avatar key and date and time in seconds from midnite
key RequestId;                 // http key

integer damagechan = -80249; //The attack channel for fire
integer iDragonChannelBack = 549898; // channel the dragon talks back on.
integer iDragonChannel = 549897; // secret channel to comm with Dragons. set to zero to not care about them
integer HUDchannel = 666;

// Handles to listeners
integer hDamageCallback; // holds a listener key
integer hDragonChannelBack; // handle for DragonCallback so we can remote it.

DEBUG( string msg)
{
    if (debug)
        llSay(0,llGetScriptName() + ":" + msg);
}


// avatar
key aviKey;
string aviName;
string Language;

Score(integer score)
{
    string url = "http://www.outworldz.com/cgi/llgameMagic.plx"
        + "?AvatarKey=" + llEscapeURL(aviKey)
        + "&PassFail="  + (string) score
        + "&AvatarName=" + llEscapeURL(aviName)
        + "&Language=" + llEscapeURL(Language)
        + "&Name=" + "Torched";

    DEBUG(url);

    RequestId = llHTTPRequest(url, [], "");

}


// If called, subtracts from the score
Fail(integer amount)
{
    llPlaySound(sonicringhurt,1.0);

    visible = FALSE;

    llSetAlpha(0.0,ALL_SIDES);
    llSetTimerEvent(BURNINGTIME);
    Score(amount);
}

Pass(integer amount)
{
    llSetTimerEvent(BURNINGTIME);
    Score(amount);
}


default
{
    state_entry()
    {
        hDamageCallback = llListen(damagechan,"","","");

        name =llGetObjectName();
        DEBUG ("plAyEr " + name);
    }

    http_response(key request_id, integer status, list metadata, string body)
    {
        DEBUG("http_response:" + body);
        if (request_id == RequestId)
        {
            list params = llParseString2List(body,["|"],[]);
            string ack = llList2String(params,0);
            if (ack == "ACK")
            {
                string msg = llList2String(params,2);
                llInstantMessage(aviKey,msg);

                integer num = (integer) llList2String(params,1);
                integer i;

                if (num > 10)
                    num = 10;

                for (i = 0 ; i < num ; i++)
                {
                    float x = llFrand(3);
                    if (x < 1) llTriggerSound(glass1,1.0);
                    else if (x < 2) llTriggerSound(glass2,1.0);
                    else  llTriggerSound(glass3,1.0);
                    DEBUG("Rez");
                    llRezObject(MagicName,llGetPos() + <0,0,1>,<llFrand(2)-1,llFrand(2)-1,llFrand(2)>,ZERO_ROTATION,i);
                }
            }
        }
    }

    on_rez(integer start)
    {
        llResetScript();
    }
    changed(integer what)
    {
        if (what & CHANGED_REGION_START)
            llResetScript();
    }
    listen(integer channel,string namea, key id, string message)
    {
        if (channel == damagechan)
        {
            // plAyEr <SPACE> ObjectName <SPACE>dragonattackerKey <SPACE> (float) damage
            DEBUG("heard:" + message);
            list i;
            
            i = llParseString2List(message, [" "], []);
            if ( llSubStringIndex( llList2String(i, 0), "plAyEr "+ name) != -1)
            {
                string dragonattackerKey = llList2String(i, 1);

                float damage = (float)llList2String(i, 2);
                llListenRemove(hDamageCallback);
                hDragonChannelBack = llListen(iDragonChannelBack,"","","");
                DEBUG("Asking Dragon");
                llSay(iDragonChannel, dragonattackerKey);
            }
        }
        else
        {
            DEBUG("Dragon said to torch " + message);
            llListenRemove(hDragonChannelBack);
            
            aviKey = (key) message;
            // tell the tree or whatever the avatar and what they did to us boo hoo.
            llMessageLinked(LINK_SET,10,(string) damage, aviKey);
            
            list details =  llGetObjectDetails( aviKey, [OBJECT_NAME] );
            aviName= llList2String(details,0);
            Language = llGetAgentLanguage(aviKey);
            if (Good_Bad)
                Pass(Hit);
            else
                Fail(Missed);

        }

    }
    timer()
    {
        hDamageCallback = llListen(damagechan,"","","");
        llSetTimerEvent(0);
    }

}
