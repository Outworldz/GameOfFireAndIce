// 4-20-2014
// :CATEGORY:Games
// :NAME:Bits of FLuff magic game
// :AUTHOR:Ferd Frederix
// :REV:1.0
// :WORLD:Second Life, OpenSim
// :DESCRIPTION:
// A simple game like Sonic the Hedgehog where avatars bump prims and they poof. If you bump the enemy, all your rings go poof

// :CODE:
// Put a ring inside this and a sound. Collide with it.

string sonicring = "sonicring.wav";    // failsound
string sonicringhurt = "sonicringhurt.wav";


integer debug = FALSE;
integer INVISTIME = 120;        // 10 sec intervals

// movement 
float maxX = 5.0;
float maxY = 5.0;


integer visible = TRUE;         // avatar key and date and time in seconds from midnite

key RequestId;                 // http key
string texture ;               // which texture is showing

DEBUG( string msg)
{
    if (debug)
        llSay(0,llGetScriptName() + ":" + msg);    
}




// particles

// mask flags - set to TRUE (or 1) to enable
integer bounce = 0;    // Make particles bounce on Z plane of object
integer glow = 1;        // Make the particles glow
integer interpColor = 0;    // Go from start to end color
integer interpSize = 1;    // Go from start to end size
integer followSource = 0;    // Particles follow the source
integer followVel = 1;    // Particles turn to velocity direction
integer wind = 0;        // Particles affected by wind

//pattern:
//integer pattern = PSYS_SRC_PATTERN_ANGLE;
//integer pattern = PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY;
//integer pattern = PSYS_SRC_PATTERN_ANGLE_CONE;
//integer pattern = PSYS_SRC_PATTERN_DROP;
integer pattern = PSYS_SRC_PATTERN_EXPLODE;

// Select a target for particles to go towards
// "" for no target, "owner" will follow object owner
//    and "self" will target this object
//    or put the key of an object for particles to go to
//key target = "";
key target = "";
//key target = "owner";

// particle parameters
float age = 2;                  // Life of each particle

float maxSpeed = .1;            // Max speed each particle is spit out at
float minSpeed = .01;            // Min speed each particle is spit out at

 
float startAlpha = 1;           // Start alpha (transparency) value
float endAlpha = 1;           // End alpha (transparency) value (if interpColor = TRUE)

vector startColor = <1,1,1>;    // Start color of particles <R,G,B>
vector endColor = <1,0,0>;      // End color of particles <R,G,B> (if interpColor = TRUE)

vector startSize = <.3,.3,0>;     // Start size of particles <x,y>
vector endSize = <.1,.1,0>;       // End size of particles (if interpSize == TRUE)

vector push = <0,0,0>;          // Force pushed on particles

// system parameters
float life = 0;             // Life in seconds for the system to make particles
integer count = 2;        // How many particles to emit per BURST
float rate = .1;            // How fast (rate) to emit particles
float radius = .1;          // Radius to emit particles for BURST pattern
float outerAngle = 1.54;    // Outer angle for all ANGLE patterns
float innerAngle = 1.55;    // Inner angle for all ANGLE patterns
vector omega = <0,0,0>;    // Rotation of ANGLE patterns around the source

integer flags = 0;

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
        + "&Language=" + llEscapeURL(Language);

    DEBUG(url);

    RequestId = llHTTPRequest(url, [], "");

}

Move()
{
    
    float x = randBetween(1,maxX) + pos.x;
    float y = randBetween(1,maxY) + pos.y;
    
    llSetPos(<x,y,pos.z>);
}


float randBetween(float min, float max)
{
    return llFrand(max - min) + min;
}
    

DoParticles(integer enable)
{
    if (!enable) {
        llParticleSystem([]);
        return;
    }
    
    texture = llGetInventoryName(INVENTORY_TEXTURE,(integer)llFrand(llGetInventoryNumber(INVENTORY_TEXTURE)));

    DEBUG(texture);
    
    if (glow) flags = flags | PSYS_PART_EMISSIVE_MASK;
    if (bounce) flags = flags | PSYS_PART_BOUNCE_MASK;
    if (interpColor) flags = flags | PSYS_PART_INTERP_COLOR_MASK;
    if (interpSize) flags = flags | PSYS_PART_INTERP_SCALE_MASK;
    if (wind) flags = flags | PSYS_PART_WIND_MASK;
    if (followSource) flags = flags | PSYS_PART_FOLLOW_SRC_MASK;
    if (followVel) flags = flags | PSYS_PART_FOLLOW_VELOCITY_MASK;
    if (target != "") flags = flags | PSYS_PART_TARGET_POS_MASK;
    
    llParticleSystem([  PSYS_PART_MAX_AGE,age,
        PSYS_PART_FLAGS,flags,
        PSYS_PART_START_COLOR, startColor,
        PSYS_PART_END_COLOR, endColor,
        PSYS_PART_START_SCALE,startSize,
        PSYS_PART_END_SCALE,endSize,
        PSYS_SRC_PATTERN, pattern,
        PSYS_SRC_BURST_RATE,rate,
        PSYS_SRC_ACCEL, push,
        PSYS_SRC_BURST_PART_COUNT,count,
        PSYS_SRC_BURST_RADIUS,radius,
        PSYS_SRC_BURST_SPEED_MIN,minSpeed,
        PSYS_SRC_BURST_SPEED_MAX,maxSpeed,
        PSYS_SRC_TARGET_KEY,target,
        PSYS_SRC_INNERANGLE,innerAngle,
        PSYS_SRC_OUTERANGLE,outerAngle,
        PSYS_SRC_OMEGA, omega,
        PSYS_SRC_MAX_AGE, life,
        PSYS_SRC_TEXTURE, texture,
        PSYS_PART_START_ALPHA, startAlpha,
        PSYS_PART_END_ALPHA, endAlpha
            ]);
}


Fail()
{

    DoParticles(FALSE);
    llPlaySound(sonicringhurt,1.0);
    llSetAlpha(0.0,ALL_SIDES);
    llSetTimerEvent(INVISTIME);
    llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES,0.0]);
    Score(-10);
}


    
Pass()
{
    DoParticles(FALSE);
    llSetAlpha(0.0,ALL_SIDES);
    // special effects for colliding
    integer count = llCeil(llFrand(5));
    integer soundcount = count;
    while (--soundcount)
    {
        llPlaySound(sonicring,1.0);
        llSleep(1.0);
    }
    llSetTimerEvent(INVISTIME);
    llSetPrimitiveParams([PRIM_GLOW, ALL_SIDES,0.0]);
    Score(count);
    Move();
}

integer init ;
vector pos;

default
{
    state_entry()
    {
        init = FALSE;
        llTargetOmega(<0.0,0.0,1.0>,TWO_PI/5,1);        // spin
        llSetAlpha(1.0,ALL_SIDES);                      // visible
        llVolumeDetect(TRUE);
        llSetPrimitiveParams([PRIM_GLOW,ALL_SIDES,0.02]);
        DoParticles(TRUE);
        llSetTimerEvent(10.0);
    }

    collision_start(integer total_number)
    {
        if (!visible)        // skip if I cannot be seen
            return;

        visible = FALSE;

        key avikey = llDetectedKey(0);

        // Handle physical objects vs avatars. Push away objects
        list details =  llGetObjectDetails( avikey, [OBJECT_CREATOR] );
        key creator =  llList2Key(details,0);

        DEBUG("collide");

        aviKey = llDetectedKey(0);
        aviName= llDetectedName(0);
        Language = llGetAgentLanguage(aviKey);

        //if (debug)
        //        texture = "spark6";
        
        if (texture == "spark6")
            Fail();
        else
            Pass();

    }

    timer()
    {
        if (init == FALSE)
        {
            llOwnerSay("Set");
            pos = llGetPos();
            init = TRUE;
        }

        // always move and change particle streams
        Move();
        DoParticles(TRUE);

        if (! visible)
        {
            llSetAlpha(0.2,ALL_SIDES);
            llSetPrimitiveParams([PRIM_GLOW,ALL_SIDES, 0.10]);
            visible = TRUE;
            
        }
        // do all this randiomly
        
        llSetTimerEvent(randBetween(5,15));
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
                    if (! debug)
                        llRezObject("Lost Bit Of Magic",llGetPos() + <0,0,1>,<llFrand(2)-1,llFrand(2)-1,llFrand(2)>,ZERO_ROTATION,i);
                }

            }
        }
    }

    on_rez(integer start)
    {
        llResetScript();
    }

}
