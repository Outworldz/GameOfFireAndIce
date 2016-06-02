 //Following flame script.
 //Goes out under water, has ability to be put out with external script, does damage to Vegaslon Plutonian combat systems.
 
 vector start_pos;
 key rezzedfrom;
 
flame(integer on)
{
    if (!on) {
        llParticleSystem([]);
        return;
    }
 
    llParticleSystem([
        PSYS_PART_FLAGS,
        PSYS_PART_WIND_MASK |
        PSYS_PART_INTERP_COLOR_MASK |
        PSYS_PART_INTERP_SCALE_MASK |
        PSYS_PART_EMISSIVE_MASK,
 
        PSYS_SRC_PATTERN,
        PSYS_SRC_PATTERN_ANGLE_CONE,
 
            PSYS_PART_START_COLOR, <.0,0.0,0.0>,
            PSYS_PART_END_COLOR, <1,1,1.0>,
 
        PSYS_PART_START_SCALE, <1,1,0>,
        PSYS_PART_END_SCALE, <0,.05,0>,
 
        PSYS_PART_START_ALPHA, 1.0,
        // emissive, always fullbright D:.
                    PSYS_SRC_TEXTURE, "d9a42220-dd5f-4890-ba7e-70b00c70821a",
        PSYS_PART_MAX_AGE, .75,
 
        PSYS_SRC_ANGLE_BEGIN, 0.0,
        PSYS_SRC_ANGLE_END, 45 * DEG_TO_RAD,
 
        PSYS_SRC_BURST_RATE, .05,
        PSYS_SRC_BURST_PART_COUNT, 10,
 
        PSYS_SRC_BURST_SPEED_MIN, .5,
        PSYS_SRC_BURST_SPEED_MAX, 1.5,
 
        PSYS_SRC_ACCEL, <0,0,4>
        // PSYS_SRC_TEXTURE, "bf3559f9-02dc-dbf8-9c7a-7bffd31c9ac6"
    ]);
}
 
key tgt;
 
integer nosense = 0;
 
integer on = 0;
 
integer colcheck = 1; // Checking for collision ( def true)
 
float end;
integer damage= 0;
default
{
    state_entry()
    {
        flame(FALSE);
    }
 
    on_rez(integer s)
    {
        if (s) {
            llListen(s, "", NULL_KEY, "");
            llSetLinkAlpha(LINK_SET, 0.0, ALL_SIDES);
            llListen(999999, "", NULL_KEY, (string)llGetKey());
            llSetTimerEvent(2);
        }
    }
 timer()
 {
     llDie();
     }
    listen(integer c, string who, key id, string msg)
    {
        if (c == 999999) // For extinguishers to use
            llDie();
 llSetTimerEvent(0.0);
        rezzedfrom=llList2String(llGetObjectDetails(id, [OBJECT_ROOT]), 0);
 
        tgt = (key)msg;
        nosense =0;
        on = 0;
 
        colcheck=1;
        llSensor("flame-"+(string)tgt, NULL_KEY, ACTIVE, TWO_PI, 96);
        llSetLinkAlpha(LINK_ALL_CHILDREN, 1.0, ALL_SIDES);
 
    }
 
    no_sensor()
    {
        if (colcheck==1) {
            colcheck = 0;
            llSetObjectName("flame-"+(string)tgt);
            end = llGetWallclock() + 30;
            llResetTime();
            llSleep(.05);
            llSensorRepeat("", tgt, AGENT|ACTIVE, 96, TWO_PI, 1);
            return;
        }
 
        nosense++;
        if (nosense > 5)
            llDie();
    }

    sensor(integer t)
    {
        if (colcheck==1) { //Oops, got a burny assigned to them.
            colcheck = 0; // does this really even matter?  YES OF COURSE
            llDie();
        }
        vector last_pos = llDetectedPos(0);
        ++damage;
        if (damage > 5){
            llWhisper(-80249,"plAyEr "+llDetectedName(0)+" "+rezzedfrom+" 9 Fire");
            //OwnerSay("test");
            damage=0;}
            start_pos= last_pos;
           
    
 
 
        if (llGetWallclock() > end)
            llDie();
 
        nosense = 0;
 
        vector h = llGetAgentSize(tgt);
 
        vector me = llGetPos();
    
        if (me.z <= llWater(ZERO_VECTOR)) llDie();
        vector to = llDetectedPos(0);
        //llOwnerSay((string)to);
  
                    llSetKeyframedMotion(
            [(to - me),
            <0,0,0,0>, 0.12],
            []);
        
 
        if (!on) {
            if(llVecDist(llGetPos(), to) < 2) {
                flame(TRUE);
                llLoopSound("48db54d0-24ff-34c8-3d5d-1496c6878d34", .4);
            }
        }
    }
}
