// Mars attacks as a dragon

integer debug = FALSE;

DEBUG (string msg)
{
    if (debug)
        llSay(0,msg);
}

string attackSound = "Monster1.wav";
string sonicSound = "sonicring.wav";
string flameSound = "flameSound.wav";

float DIST = 40;    // sensor distance
float rate = 10;    // sensor speed
float speed = 4;    //how fast to fly, dist /speed

float dist; // calculated distance
key rqstKey ;

list recentAvatars; // 200 long


vector dragonVector;   // computed Dragon  position
vector victimVector;      // detected position

rotation victimRotation;

key avatarKey ;        // detected Key
string avatarName ;    // detected Name
    
CheckifPlaying()
{
    string url = "http://www.outworldz.com/cgi/lib/BotTrigger.plx?Bot=Mars&AvatarKey=" + llEscapeURL(avatarKey)
        + "&AvatarName=" + llEscapeURL(avatarName)
        + "&Coords=" + llEscapeURL((string) victimVector)
        + "&Dist=" + (string) dist;
    
    DEBUG(url);
    rqstKey = llHTTPRequest(url, [],""); 
       
}

default
{
    on_rez(integer p)
    {
        llResetScript();
    }
    
    state_entry()
    {
        llSay(0, "Dragon Ready");
        llSensor("","",AGENT,DIST,TWO_PI);
    }

    sensor(integer number)
    {

                
        integer located;
        integer i;
        for (i = 0 ; i < number; i++)
        {
            if ( llListFindList(recentAvatars,[llDetectedKey(i)]) < 0 )
            {
                victimVector = llDetectedPos(i);

                DEBUG("Victim Pos:" + (string) victimVector);
                if (debug) 
                    victimVector = <128,128,45>;
                

                if (llListFindList(recentAvatars,[llDetectedKey(i)]) == -1)
                    recentAvatars += llDetectedKey(i);

                if (llGetListLength(recentAvatars) > 200)
                    recentAvatars = llDeleteSubList(recentAvatars,0,0);

                avatarName     = llDetectedName(i);
                if (debug) avatarName = "Ferd Federix";
                
                avatarKey      = llDetectedKey(i);
                if (debug) avatarKey = "a4dd7d22-071e-47d3-98c7-4d793e07124a";

                // face towards the person
                victimRotation   =  llDetectedRot(i);
                
                vector v = llRot2Fwd( llDetectedRot(i) );
                dragonVector = llGetPos() + v * 5 ;
                DEBUG("Dragon Pos:" + (string) dragonVector);

                dist = llVecDist(llGetPos(), victimVector);

                
                located++;
                i = number;    // attack immediately
            }
        }
        
        if (located)
        {
            CheckifPlaying();
        }
        
    }    

    http_response(key request_id, integer status, list metadata, string body)
    {
        if (rqstKey == request_id)
        {
            DEBUG(body);

            list result = llParseString2List(body,["|"],[]);

            if (llList2String(result,0) == "ACK")
            {
                llPlaySound(attackSound,1.0);
                llSetTimerEvent(dist / speed);
                               
            }            
        }
    }

    no_sensor()
    {
        llSleep(rate);
        llSensor("","",AGENT,DIST,TWO_PI);
    }
    
    timer()
    {
        llMessageLinked(LINK_SET,1,"flame","");
        llPlaySound(flameSound,1.0);
        llSleep(2);
        llPlaySound(sonicSound,1.0);
        llSetTimerEvent(0);    // cancel all timers
        llSensor("","",AGENT,DIST,TWO_PI);

        
    }
    

    
}