//************************************************************************
//Shin Ingen @ http://ingen-lab.com:8002
//OpenSim 8.x 
//OCTOBER 10, 2014
//GENERAL PURPOSE PROJECTILE | iTEC GPP (explosion) v1.0.0
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
    llParticleSystem([                 // nice fire                 
    PSYS_PART_FLAGS , 0               //iTEC Particle Engine Tester v1.0  
    | PSYS_PART_BOUNCE_MASK            //Bounce on object's z-axis
    | PSYS_PART_WIND_MASK                //Particles are moved by wind
    | PSYS_PART_INTERP_COLOR_MASK        //Colors fade from start to end
    | PSYS_PART_INTERP_SCALE_MASK        //Scale fades from beginning to end
    //| PSYS_PART_FOLLOW_SRC_MASK          //Particles follow the emitter
    | PSYS_PART_FOLLOW_VELOCITY_MASK     //Particles are created at the velocity of the emitter
    //| PSYS_PART_TARGET_POS_MASK        //Particles follow the target
    | PSYS_PART_EMISSIVE_MASK            //Particles are self-lit (glow)
    //| PSYS_PART_TARGET_LINEAR_MASK     //Undocumented--Sends particles in straight line?
    ,
    
    //PSYS_SRC_TARGET_KEY , NULL_KEY,    //Key of the target for the particles to head towards
                                         
    //Choose one of these as a pattern:
    //PSYS_SRC_PATTERN_DROP                 Particles start at emitter with no velocity
    //PSYS_SRC_PATTERN_EXPLODE              Particles explode from the emitter
    //PSYS_SRC_PATTERN_ANGLE                Particles are emitted in a 2-D angle
    //PSYS_SRC_PATTERN_ANGLE_CONE           Particles are emitted in a 3-D cone
    //PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY     Particles are emitted everywhere except for a 3-D cone
    
    PSYS_SRC_PATTERN,          PSYS_SRC_PATTERN_EXPLODE
    
    ,PSYS_SRC_TEXTURE,           ""     //UUID of the desired particle texture  
    ,PSYS_PART_MAX_AGE,          3.25                //Lifetime, in seconds, that a particle lasts
    ,PSYS_SRC_MAX_AGE,           0.0
    ,PSYS_SRC_BURST_RATE,        0.01               //How long, in seconds, between each emission
    ,PSYS_SRC_BURST_PART_COUNT,  15                  //Number of particles per emission
    ,PSYS_SRC_BURST_RADIUS,      1.12                //Radius of emission
    ,PSYS_SRC_BURST_SPEED_MIN,   0.05                //Minimum speed of an emitted particle
    ,PSYS_SRC_BURST_SPEED_MAX,   0.05                //Maximum speed of an emitted particle
    ,PSYS_SRC_ACCEL,             <0.0,0.0,1.5>      //Acceleration of particles each second
    ,PSYS_PART_START_COLOR,      <1.0,1.0,0.0>      //Starting RGB color
    ,PSYS_PART_END_COLOR,        <0.4,0.0,0.0>      //Ending RGB color, if INTERP_COLOR_MASK is on 
    ,PSYS_PART_START_ALPHA,      0.8                //Starting transparency, 1 is opaque, 0 is transparent.
    ,PSYS_PART_END_ALPHA,        0.0                //Ending transparency
    ,PSYS_PART_START_SCALE,      <0.4,0.4,0.0>      //Starting particle size
    ,PSYS_PART_END_SCALE,        <0.1,0.7,0.0>      //Ending particle size, if INTERP_SCALE_MASK is on
    ,PSYS_SRC_ANGLE_BEGIN,       0.005*PI                //Inner angle for ANGLE patterns
    ,PSYS_SRC_ANGLE_END,         0.0                //Outer angle for ANGLE patterns
    ,PSYS_SRC_OMEGA,             <0.0,0.0,0.0>       //Rotation of ANGLE patterns, similar to llTargetOmega()
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
        llSetStatus( STATUS_DIE_AT_EDGE, TRUE);
        llSetTextureAnim (ANIM_ON | LOOP, ALL_SIDES, 4, 4, 0, 0, 15.0);
        particle_system_on();
    }
      
    on_rez(integer start_param)
    {
        if (!start_param) return;
        particle_system_on();
        llCollisionFilter("", llGetOwner(), FALSE);
        llSetDamage((float)start_param);
        llCollisionSound("", 1.0); 
        llSetTimerEvent(gTimeToDie);
    }

    collision_start(integer count)
    {
        integer type = llDetectedType(0);
        if (type & AGENT) {
            //llRegionSay(-600,"Rocket:Agent collision is detected.");
            // your damage logic goes here
            //llDie();
        } else if (llGetStartParameter()) {
            //llRegionSay(-600,"Rocket:Object collision is detected.");
            //llDie(); // die on collision --no ricochet--
        }
    }
    
    land_collision_start(vector pos) {
        if (llGetStartParameter()){
        //llRegionSay(-600,"Rocket:Land collision is detected.");
        //llDie(); // die on land collision --no bounce--
        }
    }
    
    timer()
    {
        //llRegionSay(-600,"Rocket:I timed out and am dying now.");
        llDie();
    }
}