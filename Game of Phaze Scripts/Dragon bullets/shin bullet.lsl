//************************************************************************
//Shin Ingen @ http://ingen-lab.com:8002
//OpenSim 8.x 
//OCTOBER 10, 2014
//GENERAL PURPOSE PROJECTILE | iTEC GPP v1.0
//CREATE YOUR PROJECTILE AND NAME IT WITH SOMETHING OTHER THAN PRIMITIVE.
//TAKE IT TO YOUR INVENTORY.
//ATTACH PROJECTILE TO YOUR AVATAR AND PUT THIS SCRIPT IN AND THEN DETACH.
//YOU NOW HAVE A FUNCTIONAL PROJECTILE IN YOUR INVENTORY
//PUT THE PROJECTILE INSIDE YOUR LAUNCHER
//EDIT YOUR LAUNCHER SCRIPT TO USE THE NAME OF YOUR PROJECTILE
//=========================================================================
//TODO: FLIGHT PARTICLE | COLLISION PARTICLE
//=========================================================================
float gTimeToDie = 20.0;

particle_system_on()
{
 llParticleSystem([

 PSYS_PART_FLAGS
 , 0
 | PSYS_PART_EMISSIVE_MASK
 | PSYS_PART_INTERP_COLOR_MASK
 | PSYS_PART_INTERP_SCALE_MASK
 | PSYS_PART_FOLLOW_SRC_MASK
 ,

 PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
 //PSYS_SRC_TEXTURE,           "smoke-01",
 PSYS_SRC_MAX_AGE, 0.,
 PSYS_SRC_BURST_RATE, 2.,
 PSYS_SRC_BURST_PART_COUNT, 3,

 PSYS_SRC_ACCEL, <0.0,0.0,-0.01>,

 PSYS_PART_MAX_AGE, 3.,
 PSYS_PART_START_COLOR, <0,0,1>,
 PSYS_PART_END_COLOR, <1,1,1>,
 PSYS_PART_START_ALPHA, 0.9,
 PSYS_PART_END_ALPHA, 0.,

 PSYS_PART_START_SCALE, <1,1,0>,
 PSYS_PART_END_SCALE, <.01,.01,0>
 ]);
}
particle_system_off()
{
    llParticleSystem( [] );
}
default
{
    state_entry()
    {
        llSetPrimitiveParams([PRIM_TEMP_ON_REZ, TRUE]); 
        llSetStatus(STATUS_PHYSICS | STATUS_DIE_AT_EDGE, TRUE);
        //set PE characteristics here
        //llSetBuoyancy(1.0);
        particle_system_on();        
    }
      
    on_rez(integer start_param)
    {
        if (!start_param) return;
        // set particle logic here
        llCollisionFilter("", llGetOwner(), FALSE);
        llSetDamage((float)start_param);
        llCollisionSound("", 1.0); 
        llSetTimerEvent(gTimeToDie);
        //particle_system_on();
    }

    collision_start(integer count)
    {
        integer type = llDetectedType(0);
        if (type & AGENT) {
            // your damage logic goes here
            llDie();
        } else if (llGetStartParameter()) {
            //llDie(); // die on collision --no ricochet--
        }
    }
    
    land_collision_start(vector pos) {
        //if (llGetStartParameter()) llDie(); // die on land collision --no bounce--
    }
    
    timer()
    {
        llDie();
    }
}