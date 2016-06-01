// 3-22-2015


// demon script worn on a demon = click it to attack it.


// ______           _  ______            _           _
// |  ___|         | | |  ___|          | |         (_)
// | |_ ___ _ __ __| | | |_ _ __ ___  __| | ___ _ __ ___  __
// |  _/ _ \ '__/ _` | |  _| '__/ _ \/ _` |/ _ \ '__| \ \/ /
// | ||  __/ | | (_| | | | | | |  __/ (_| |  __/ |  | |>  <
// \_| \___|_|  \__,_| \_| |_|  \___|\__,_|\___|_|  |_/_/\_\
//
// fred@mitsi.com
//
// author Ferd Frederix Copyright 2009
//
//

// Demon Attack Controller

// Revision:
// 7-1-2011 - initial working OpenSim draft
// 7-22-2011 - set initial score at 15, not 16
// 7-22-2011 - increase from 10 to make turns sharper
// 7-22-2011 - set avatar key only once from startup param in listen event
// 7-29-2011 - Score board changes
//                Added listen for N|key|health to demon2ControllerChannel to show avatar health
//                Scoring changed to 1/5 chance of a miss,1/10 crit hit, 1/5 Big hit, 2/5 miss
//                touch steals focus on avatar, multi-user loop added
//
// 3-15-2015 initial port to Opensim
// 3-16-2015 LSL tests
// 3-22-2015 added sound

integer debug = FALSE;
DEBUG(string str) {
    if (debug) llWhisper(0,llGetScriptName() + ":" + str);
}
// TUNEABLES:
 
integer DemonDamage  = 1;  /// adds to the damage done by demon type.
string stepSound = "footstepmuffled"; // footsteps
float Volume = 1;        // how loud the sounds playback

//channels
integer initted;
integer listener;
integer Controller2DemonChannel = 500;   // sent when to show Avatar health
integer Demon2ControllerChannel = 501;   // sent when we score one way or the other


// vars

vector lastPosition;        // the last position we were at when the timer fired
integer demon_health; 
integer avatar_health;

Init(integer start_param) {
    
    DEBUG("Skeleton is listening on " + (string) Controller2DemonChannel);

    demon_health = 100;
    avatar_health = 100;

    HoverText("");
    
    llListen(Controller2DemonChannel,"","","");
}

HoverText(string text)
{
   string msg = text + "\nHealth: "
        + (string) demon_health
        + "\n"
        + "Your Health: "
        + (string) avatar_health;

    llMessageLinked(LINK_SET,0,msg,"");
}
 

default {
    
    state_entry()
    {   
        llSetTimerEvent(1);
    }
    
    timer(){ 
        if (! initted) {
            llListen(Controller2DemonChannel,"","","");
            //DEBUG("Need channel");
            llSay(Demon2ControllerChannel,"Need channel");
        }
     }

    listen(integer channel, string name, key id, string message)
    {
        // if we hear from another demon, or ourselves that the avatar is dead, we die, too. End of Game
         
        //DEBUG("Heard:" + message + " on channel " + (string) channel);
        
        list stuff = llParseString2List(message,["|"],[]);
        string acmd = llList2String(stuff,0);
        string param1 = llList2String(stuff,1);

        if (acmd == "AvatarHealth" ) {
            //DEBUG("Health received");
            avatar_health = (integer) param1;
            HoverText("Attack!");
        } else if (acmd == "DemonHealth" ) {
           // DEBUG("D Health received");
            demon_health = (integer) param1;
            HoverText("Attack!");
        } else if (acmd == "sound") {    
            //DEBUG("Sound received of " + param1);           
            llTriggerSound((key) param1,1.0);
        } else if (acmd=="hovertext") {
            HoverText(param1);
        } else if (acmd=="channel") {
            initted = TRUE;
            
            llSetTimerEvent(0);
             
            DEBUG("Controller2DemonChannel channel:" + (string) param1);
            llListenRemove(listener);
            Controller2DemonChannel = (integer) param1;
            Demon2ControllerChannel =  Controller2DemonChannel + 1 ;
            llListen(Controller2DemonChannel,"","",""); 
              
        } else {
            DEBUG("Unknown command:" + message);
        } 
    }
    touch_start(integer count)
    {
        integer i;
        for (i = 0; i < count; i++)
        {
            DEBUG("Touched: sending " + (string) llDetectedKey(i) + "|" + (string) DemonDamage + " on channel " + (string) Demon2ControllerChannel);
            llShout(Demon2ControllerChannel,(string) llDetectedKey(i) + "|" + (string) DemonDamage);
        }
    }
 
    on_rez(integer start_param)
    {
        DEBUG("On_rez");
        llSetTimerEvent(1);
    }   
    
    attach(key  where)
    {
        DEBUG("Attach");
        HoverText("Loading");
        llSetTimerEvent(1);
    }
}
 
 