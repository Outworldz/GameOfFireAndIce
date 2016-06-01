// the main controller for the arena for each opponent
// Rezzed by master controller one per NPC.


// ______           _  ______            _           _
// |  ___|         | | |  ___|          | |         (_)
// | |_ ___ _ __ __| | | |_ _ __ ___  __| | ___ _ __ ___  __
// |  _/ _ \ '__/ _` | |  _| '__/ _ \/ _` |/ _ \ '__| \ \/ /
// | ||  __/ | | (_| | | | | | |  __/ (_| |  __/ |  | |>  <
// \_| \___|_|  \__,_| \_| |_|  \___|\__,_|\___|_|  |_/_/\_\
// 
// fred@mitsi.com
//
// author Ferd Frederix Copyright 2015
// License CC-NC-BY-SA
// You must share any changes to the community as Open source
//
// Revision:

 
// added random speeds
// 07-22-2011 - remove avatar key init listener when we get the channel
// 07-22-2011 - zero score
// 07-22-2011 - give it a half meter push out the flames
// 07-27-2011 - http score keeping
// 02-29-2011 - comm re-write
// 06-10-2012 - fix counter to rez correct number
// 03-15-2015 - initial port to Opensim
// 03-18-2015 -  animations and sounds and comms work
// 07-05-2015 debug second warriors when you win.
// 9-02-2015 - Allow rez for debug.  

integer debug = FALSE; 

DEBUG(string msg)
{
    if (debug)  {
        llOwnerSay(llGetScriptName() + ":" + msg);
        llSetText(msg, <1,1,1>,1.0);
    }
}

key GRAVE = "3840f802-c3c3-468a-9fef-95a5e35ecc9b"; // A grave to die in- basically any prim the avatar will sit on at the end of the game.
string lidclose = "close";                          // the Prim Animation message sent on Num=1 when the avatar is dead

// sounds
string you_die_sound    = "sad-trombone";
string die_sound        = "Zdeath";
string attack_sound     = "quickstab";
string hit_sound        = "clang1";
string big_hit_sound    = "clang2";
string collide_sound    = "clang3";
string touched_sound    = "Flick";
string miss_sound       = "Flick";
string startup_sound    = "Monster1";
  
  
// Animations List
string showoff = "showoff";        // looped
string laydown = "avatar_dead";        // avatar in coffin
string attack = "avatar_kick_roundhouse_R";           // 
string win = "avatar_jumpforjoy";                 // not looped
string die = "avatar_dead";                 // looped
string swing = "avatar_punch_onetwo";             // not looped
string swing2 = "avatar_sword_strike_R";
string miss = "avatar_throw_R";

string hit = "avatar_crouch";       // looped
string bighit = "avatar_jump";           // looped
string crithit = "avatar_turnback_180";         // looped

string lastAviAnim ; // the last animation played on the avatar, so we can stop it.
string lastNpcAnim ; // the last animation played on the avatar, so we can stop it.

integer demon_health = 100;
integer avatar_health = 100;

integer tickcounter = 0;
integer attacking = 0;

float INSIM =  40;   // we die if they go this far
float MAXDIST = 20; // we stop at this
float FAR = 5; // past this, we do not point directly at him, but to one side to prevent collisions.
float NEAR = 4; // if within 3, we attack
float JITTER = 0;    // Jittreer around the avatar we are attacking.

vector startPos;       // so we can see if we get too far
vector DestPos;       // where we are heading
rotation DestRot = ZERO_ROTATION;
key AvatarKey;      // the avatar we are going to chase
float defaultTimer = 1.0;
integer current_demon_counter;
key NpcKey;


//channels
integer listener_demon; // for the message from demons asking for channels
integer listener_rezzer; // for the rezzer that sends us the avatar key
integer RezzerToControllerChannel ;
integer demon2ControllerChannel;                   // sent when we score one way or the other
integer Controller2DemonChannel;                   // sent when to show Avatar health
integer ToDemon = 500;
integer FromDemon = 501;

integer demonScoreChannel = 8768510;           // score board
integer scoreChannel = 9987;                    // to scoreboard 

// remote tuneables
float HEALTHTIME = 30;      // health grows every 10 seconds
integer HEALTHINC = 1;     // by this much
float ANGLE = 0.2;          // smaller = less ability to attack
float DISTANCE = 30;     // how far away to sense the avatars

// states

integer currState;
integer AvatarDead = 1;
integer NpcDead = 2;


integer NDemons ;        // number of total demons in inventory
integer initted = FALSE;
key http_request_id ;           // http key

// OS_NPC_CREATOR_OWNED will create an 'owned' NPC that will only respond to osNpc* commands issued from scripts that have the same owner as the one that created the NPC.
// OS_NPC_NOT_OWNED will create an 'unowned' NPC that will respond to any script that has OSSL permissions to call osNpc* commands.
integer  NPCOptions = OS_NPC_CREATOR_OWNED;    // only yhe owner of this box can control this NPC.

integer Damage ;         // > 0 uif they have a weapon
integer DemonDamage;


// Functions
 
AnimateAvatar(string anim)
{

    ///DEBUG("Avatar Animate " + anim);    
    if ((key) AvatarKey != NULL_KEY) {
        osAvatarStopAnimation(AvatarKey,lastAviAnim);
        osAvatarPlayAnimation(AvatarKey,anim);
    }
    lastAviAnim = anim;
}
npcAnimate(string anim)
{
    //DEBUG("npcAnimate " + anim); 
    osNpcPlayAnimation(NpcKey,anim);
    lastNpcAnim = anim;
}

Send2Demon(string param, string cmd)
{
   // DEBUG("Send2Demon" + param+ ":" + cmd + " on channel " + (string) Controller2DemonChannel);
    llShout(Controller2DemonChannel,param + "|"  + cmd );   
}

Send2Scoreboard(string msg)
{
    llShout(scoreChannel,msg);   
} 

Sound(string soundfile)
{
    key UUID = llGetInventoryKey(soundfile);
    Send2Demon("sound",(string) UUID);
}

vector point_in_front_of( key id, float d )
{
    list pose = llGetObjectDetails( id, [ OBJECT_POS, OBJECT_ROT ] );
    
    vector DestPos =  llList2Vector( pose, 0 ) + < d, 0.0, 0.0 > * llList2Rot( pose, 1 );;
    //DestPos.x =  DestPos.x + Jitter(JITTER);    // but add some jitter
    //DestPos.y =  DestPos.y + Jitter(JITTER);
    return DestPos;
}

/////////////////////// END GAME /////////////////////////
// you won, object dies
/////////////////////// END GAME /////////////////////////
NpcDied()
{
    DEBUG("NPC Died");
    Send2Scoreboard(llKey2Name(AvatarKey) + "Won!");
    AnimateAvatar(win);
    npcAnimate(die);
    Send2Demon("hovertext","Oh No! You killed me!");
    Sound(die_sound);
    PostScores(1,Damage); // won
    currState =NpcDead;
    demon_health = 100;
    llSetTimerEvent(5.0);
}
AvatarLeft()
{
    DEBUG("Avatar Left");
    Send2Scoreboard(llKey2Name(AvatarKey) + "Left!");
    PostScores(0,-Damage); // lose
    
    currState = AvatarDead;
     
    Send2Demon("hovertext","Hahaha, you left!");

    llSetTimerEvent(5.0);  
}

AvatarDied()
{
    DEBUG("Avatar Died");
    Send2Scoreboard(llKey2Name(AvatarKey) + "Lost!");
    PostScores(0,-Damage); // lose
    

    currState = AvatarDead;
     
    Send2Demon("hovertext","Hahaha, you died!");

    Sound(you_die_sound);    
    npcAnimate(win);
   
    if ((key) AvatarKey != NULL_KEY)
        osForceOtherSit(AvatarKey, GRAVE);
    
    DEBUG("Stopping Sit");
    
    if ((key) AvatarKey != NULL_KEY)
        osAvatarStopAnimation(AvatarKey,"sit");  
 
    llSetTimerEvent(5.0);  
}

AvatarWonAll()
{
   //DEBUG("Avatar Won all games");
    PostScores(1,Damage*2);
    osNpcRemove(NpcKey);
    llRegionSayTo(AvatarKey,0,"You have won the game!");
    llDie();
}

/////////////////////// AVATAR ANIMATIONS /////////////////////////
AvatarTookHit()
{       
  //  DEBUG("AvatarTookHit");
    npcAnimate(attack);
    Send2Demon("hovertext","Nicked You");  
    Sound(hit_sound);
    AvatarScore(- (1 + DemonDamage));
    AnimateAvatar(hit);
}
AvatarTookBigHit()
{
  //  DEBUG("AvatarTookBigHit");
    npcAnimate(swing);
    Send2Demon("hovertext","Big Hit on You!");
    Sound(big_hit_sound);
    AvatarScore(- (2 + DemonDamage));
    AnimateAvatar(bighit);
}
AvatarTookCritHit()
{
  //  DEBUG("AvatarTookCritHit");
    npcAnimate(swing2);
    Send2Demon("hovertext","Critical Hit on You!");
    Sound(big_hit_sound);
    AvatarScore(- (3 + DemonDamage));
    AnimateAvatar(crithit);
}
AvatarTookMiss()
{
   // DEBUG("AvatarTookMiss");
    npcAnimate(miss);
    Send2Demon("hovertext","Missed");
    Sound(miss_sound);
    AnimateAvatar(swing);
} 

//////// DEMONS //////////
DemonTookHit()
{       
 //  DEBUG("DemonTookHit");
    Send2Demon("hovertext","Nicked");
    AnimateAvatar(swing);
    npcAnimate(hit);
    Sound(hit_sound);
    demon_health -= 2 + Damage;
    AvatarScore(1);
}
DemonTookBigHit()
{
  //  DEBUG("DemonTookBigHit");
    Send2Demon("hovertext","Big Hit!");
    AnimateAvatar(swing);
    npcAnimate(bighit);
    Sound(big_hit_sound);
    demon_health -= 3 + Damage;
    AvatarScore(2);
}
DemonTookCritHit()
{
  //  DEBUG("DemonTookCritHit");
    Send2Demon("hovertext","Critical Hit!");
    AnimateAvatar(swing);
    npcAnimate(crithit);
    Sound(big_hit_sound);
    demon_health -= 5 + Damage;
    AvatarScore(3);   
}
DemonTookMiss()
{
  //  DEBUG("DemonTookMiss");
    Send2Demon("hovertext","Missed");
    AnimateAvatar(swing);
    npcAnimate(swing);
    Sound(miss_sound);
}


float Jitter(float J)
{
    return llFrand(((J * 2) - J) + J);        // random number between +/- JITTER (diameter)
}

PostScores(integer winlose, integer Score)
{   
    string AviName = llKey2Name(AvatarKey);
    
    if (llStringLength(AviName))
    {
        DEBUG("Won/Lost:" + (string) winlose + " with score: " + (string) Score );
        string url = "http://www.outworldz.com/cgi/scoreboard.plx"
            + "?Avatar=" + llEscapeURL(AviName)
            + "&AvatarKey=" + llEscapeURL((string) AvatarKey)
            + "&Score=" + (string) Score
            + "&WinLose=" + (string) winlose
            + "&Game=Dreadful%20Pirates";
            

        DEBUG(url);
        http_request_id = llHTTPRequest(url, [], "");
    } else {
        llOwnerSay("Bad avatar key in demon controller");
    }
}

AvatarScore(integer count)
{
    avatar_health = avatar_health + count;     
    DEBUG("Avatar Health = " + (string) avatar_health);
    if (avatar_health <= 0)
    {
        DEBUG("Avatar Died");
        avatar_health = 0;
        Send2Demon("AvatarHealth","0");    // tell them the avis health
        AvatarDied();    
        return;
        
    } else if (avatar_health > 100) {
        avatar_health = 100;       
        Send2Demon("AvatarHealth","100");    // tell them the Demons health
    }    
    
    Send2Demon("AvatarHealth",(string) avatar_health);
    
    if (demon_health  > 0)
        Send2Demon("DemonHealth",(string) demon_health);    // tell them the avis health
    else if (demon_health  <= 0)
    {
        DEBUG("Demon is dead, posting score");
        PostScores(1,Damage); // win

        current_demon_counter++;        // move to the next demon
        DEBUG("current_demon_counter=" + (string) current_demon_counter);
        
        NpcDied();
    }
}


Rezem()
{
    demon_health = 100;

    string notecard = llGetInventoryName(INVENTORY_NOTECARD,current_demon_counter);
    NpcKey = osNpcCreate(notecard, "", llGetPos() + <0,0,1>, notecard, NPCOptions);
    llSetObjectDesc(NpcKey);
    
    DEBUG("Rezzing demon " + notecard);
    llSay(0,notecard + " appears");
    
    npcAnimate(showoff);
    
    osSetSpeed(NpcKey, llFrand(0.5) + 0.5);    // fromhalf speed, up to 1
    
    
    llSetTimerEvent(5);    //  Time to rez a demon
}


integer random_integer( integer min, integer max )
{
  return min  + (integer)( llFrand( max - min + 1 ) );
}
 


Init(integer param)
{
    DEBUG("Init running");

    
    llSetText("", <1,1,1>,1.0);
    startPos = llGetPos();
    tickcounter = 0;
    demon_health = 100;
    avatar_health = 100;

    // permanant channel setup
    RezzerToControllerChannel = param;
    Controller2DemonChannel = param + 1;
    demon2ControllerChannel = param + 2;
    
    DEBUG("Init: RezzerToControllerChannel is " + (string) RezzerToControllerChannel);
    DEBUG("Init: demon2ControllerChannelchannel is " + (string) demon2ControllerChannel);
    DEBUG("Init: Controller2DemonChannel is " + (string) Controller2DemonChannel);

    listener_rezzer = llListen(RezzerToControllerChannel,"","",""); // removable listener

    NDemons = llGetInventoryNumber(INVENTORY_NOTECARD);
    
    current_demon_counter = 0;
    avatar_health = 100;
    
    DEBUG( (string) NDemons + " monsters available");
    
    llSay(RezzerToControllerChannel,"Go!");
}
 

default
{
    state_entry()
    {
        if (debug) {
            osNpcRemove(llGetObjectDesc());
            llOwnerSay ("/1000000 6f285c43-e656-42d9-b0e9-a78684fee15c");
            Init(1000000);
        }
    }
    
    // the only thing the Rezzer hears are avatar keys - who is attacking
    listen(integer channel, string name, key id, string message)
    {
        DEBUG("heard:" + message  + " on channel " + (string) channel);
        
        if (channel == RezzerToControllerChannel)
        {
            AvatarKey = (key) message;
            
            if ((key)  AvatarKey == NULL_KEY)
                llDie();  
                
            llListenRemove(listener_rezzer);  
            DEBUG("Set avatar key to " + message);
    
            listener_demon = llListen(FromDemon,"","","");  // for NPC to tell us he is ready for channels
 
            Rezem();
            return;
        }
        
        if (channel == FromDemon)
        {
           // llListenRemove(listener_demon);
            
            llListen(demon2ControllerChannel,"","",""); // permanent listener
            
            DEBUG("talkback channel " + (string)Controller2DemonChannel + " sent to Demon");
            llSay(ToDemon,"channel|" + (string)Controller2DemonChannel);
            return; 
        }

        if (channel == demon2ControllerChannel)
        {
            DEBUG("Demon said: " + message);  
            
            list stuff = llParseString2List(message,["|"],[]);
            
            //AvatarKey = (key) llList2String(stuff,0);
            DemonDamage = (integer) llList2String(stuff,1);
            
            DEBUG("Avatar Key = " + (string) AvatarKey);
            DEBUG("Demon Damage = " + (string) DemonDamage);
    
            vector vAvatarPos = llList2Vector(llGetObjectDetails(AvatarKey,[OBJECT_POS,OBJECT_ROT]),0);
    
            if (llVecDist(osNpcGetPos(NpcKey), vAvatarPos) > NEAR)     // too far
            {
                llRegionSayTo(AvatarKey,0,"Missed - get closer!");
                return;
            }
    
            float rand = llFrand(5);
            if ( rand < 1)
                DemonTookMiss();
            else if ( rand < 1.5)
                DemonTookCritHit();
            else if (rand < 3)
                DemonTookBigHit();
            else
                DemonTookHit(); 
        } else {
            DEBUG("***Illegal message heard on channel " + channel + ":" + message);
        }
    
    }
    

    timer()
    {
        osNpcStopAnimation(NpcKey,lastNpcAnim);
        if ((key) AvatarKey != NULL_KEY)
            osAvatarStopAnimation(AvatarKey,lastAviAnim);

        if (currState == NpcDead) {
            DEBUG("NpcDead");
            osNpcRemove(llGetObjectDesc());
            currState = 0;
            
            if (current_demon_counter >= NDemons) 
            {
                AvatarWonAll();
                return;
            }  
            
            currState = 0; // !!!
            
            
            Rezem();
            return;
        }
        
        if (currState == AvatarDead) {
            DEBUG("AvatarDead");
            osNpcRemove(NpcKey);
            llDie();
        }
        
        // each 10 seconds gains energy, increasing the demon_health meter. 10 seconds
        if (tickcounter++ %  (integer) (HEALTHTIME /defaultTimer) == 0 )
        {
            demon_health += HEALTHINC;
            if (demon_health > 100)
                demon_health = 100;

            Send2Demon("DemonHealth",(string) demon_health);    // tell them the avis health

            avatar_health += HEALTHINC;
            if (avatar_health > 100)
                avatar_health = 100;

            Send2Demon("AvatarHealth",(string) avatar_health);    // tell them the avis health
        }

        //POSITIONING
        list details = llGetObjectDetails(AvatarKey,[OBJECT_POS]);
        vector vAvatarPos = llList2Vector(details,0); 
        //DEBUG("Avatar DetectedPos:"+ (string) vAvatarPos);
                
        vector vNpcCurrentPosition = osNpcGetPos(NpcKey);
        //DEBUG("NPC DetectedPos:"+ (string) vNpcCurrentPosition);

        if ( llVecDist(vAvatarPos,startPos) > INSIM)
        {
            llRegionSayTo(AvatarKey,0, "Hah!  You left!  Come back when you want me to bash me you again!  Running away just puts black marks on your record.");
            AvatarScore(-10);
            AvatarLeft();
            return;
        }
         // forfeit
        if (! llGetListLength(details))
        {
            DEBUG("Avatar Gone - Game Over");
            llInstantMessage(AvatarKey,"Hah!  You left!  Come back when you want me to bash me you again!  Running away just puts black marks on your record.");
            AvatarScore(-10);
            AvatarDied();
            return;
        }
        
        //DEBUG("NPC DetectedPos:"+ (string) vNpcCurrentPosition);
        
        if ( llVecDist(vNpcCurrentPosition,startPos) > MAXDIST)
        {
            DEBUG("At Edge, returning");
            DestPos = startPos;
            
            osNpcMoveToTarget(NpcKey, DestPos,OS_NPC_NO_FLY);
            llSetTimerEvent(5);
            attacking = 0;
            return;
        }
        else if (llVecDist(vNpcCurrentPosition,vAvatarPos) < NEAR)
        {   
            DestPos = point_in_front_of(AvatarKey,1);
            osNpcMoveToTarget(NpcKey, DestPos,OS_NPC_NO_FLY); 
            
            if (attacking++ % 4 == 0)
            {
                DEBUG("Demon atacking ");
                integer rand = llCeil(llFrand(5) + 1); //  5 to 10 points
                
                if (rand < 2){
                    AvatarTookMiss();
                } else if (rand < 3){
                    AvatarTookHit();
                } else if (rand < 4) {
                    AvatarTookBigHit();
                } else {
                    AvatarTookCritHit();
                }
                attacking  = 0;
            }
            llSetTimerEvent(1);     
        }
        else
        {
            DestPos = point_in_front_of(AvatarKey,1);
            osNpcMoveToTarget(NpcKey, DestPos,OS_NPC_NO_FLY);  
            attacking = 0;
            llSetTimerEvent(1);
        }
        
        llSetTimerEvent(1);   
    }

    on_rez(integer start_parameter)
    {
        llSetText("",<1,1,1>,1.0);
        if (start_parameter)
            Init(start_parameter);
    }
    
    http_response(key request_id, integer status, list metadata, string body)
    {
        if (request_id == http_request_id)
        {
            DEBUG("http:" + body);
        }
    }   
}
// __ END__