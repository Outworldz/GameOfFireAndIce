integer is_on = FALSE;

particle_system_on()
{
    llParticleSystem([                   //KPSv1.0  
        PSYS_PART_FLAGS , 0 //Comment out any of the following masks to deactivate them
    //| PSYS_PART_BOUNCE_MASK           //Bounce on object's z-axis
    //| PSYS_PART_WIND_MASK             //Particles are moved by wind
    | PSYS_PART_INTERP_COLOR_MASK       //Colors fade from start to end
    | PSYS_PART_INTERP_SCALE_MASK       //Scale fades from beginning to end
    | PSYS_PART_FOLLOW_SRC_MASK         //Particles follow the emitter
    | PSYS_PART_FOLLOW_VELOCITY_MASK    //Particles are created at the velocity of the emitter
    //| PSYS_PART_TARGET_POS_MASK       //Particles follow the target
    //| PSYS_PART_EMISSIVE_MASK           //Particles are self-lit (glow)
    //| PSYS_PART_TARGET_LINEAR_MASK    //Undocumented--Sends particles in straight line?
    ,
    
    //PSYS_SRC_TARGET_KEY , "644cebff-4003-4eb1-8b14-d349112b3db7",   //Key of the target for the particles to head towards
                                                //This one is particularly finicky, so be careful.
    //Choose one of these as a pattern:
    //PSYS_SRC_PATTERN_DROP                 Particles start at emitter with no velocity
    //PSYS_SRC_PATTERN_EXPLODE              Particles explode from the emitter
    //PSYS_SRC_PATTERN_ANGLE                Particles are emitted in a 2-D angle
    //PSYS_SRC_PATTERN_ANGLE_CONE           Particles are emitted in a 3-D cone
    //PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY     Particles are emitted everywhere except for a 3-D cone
    
    PSYS_SRC_PATTERN,           PSYS_SRC_PATTERN_ANGLE_CONE
    
    ,PSYS_SRC_TEXTURE,           "3f124e44-597e-4975-b3d5-c17aec46a205"     //UUID of the desired particle texture  
    ,PSYS_PART_MAX_AGE,          3.3                //Lifetime, in seconds, that a particle lasts
    ,PSYS_SRC_BURST_RATE,        0.01               //How long, in seconds, between each emission
    ,PSYS_SRC_BURST_PART_COUNT,  5                  //Number of particles per emission
    ,PSYS_SRC_BURST_RADIUS,      0.1               //Radius of emission
    ,PSYS_SRC_BURST_SPEED_MIN,   1.0                //Minimum speed of an emitted particle
    ,PSYS_SRC_BURST_SPEED_MAX,   0.99                //Maximum speed of an emitted particle
    ,PSYS_SRC_ACCEL,             <0.0,0.0,0.0>      //Acceleration of particles each second
    ,PSYS_PART_START_COLOR,      <1.0,1.0,1.0>      //Starting RGB color
    ,PSYS_PART_END_COLOR,        <10.0,10.0,10.0>      //Ending RGB color, if INTERP_COLOR_MASK is on 
    ,PSYS_PART_START_ALPHA,      0.05                //Starting transparency, 1 is opaque, 0 is transparent.
    ,PSYS_PART_END_ALPHA,        0.0                //Ending transparency
    ,PSYS_PART_START_SCALE,      <0.9,0.9,0.05>      //Starting particle size
    ,PSYS_PART_END_SCALE,        <0.01,0.9,0.01>      //Ending particle size, if INTERP_SCALE_MASK is on
    ,PSYS_SRC_ANGLE_BEGIN,       0.0                //Inner angle for ANGLE patterns
    ,PSYS_SRC_ANGLE_END,         0.0               //Outer angle for ANGLE patterns
    ,PSYS_SRC_OMEGA,             <0.0,0.0,0.0>       //Rotation of ANGLE patterns, similar to llTargetOmega()
            ]);;
}
particle_system_off()
{
    llParticleSystem( [] );
}

default
{
    state_entry()
    {
      llSetColor(<1.000, 0.863, 0.000>, ALL_SIDES); 
    }

    touch_start(integer total_number)
    {
        
        if(is_on)
        {
        integer privchan = ((integer)("0x"+llGetSubString((string)llGetKey(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF;
        llSay(0,"I am toggled OFF "+(string)privchan);
        llSetColor(<1.000, 0.255, 0.212>, ALL_SIDES);
        llSetPrimitiveParams( [ PRIM_GLOW, ALL_SIDES, 0.08 ] ) ;
        particle_system_on();
        is_on = FALSE;
        }
        else
        {
         integer privchan = ((integer)("0x"+llGetSubString((string)llGetOwner(),-8,-1)) & 0x3FFFFFFF) ^ 0xBFFFFFFF;
         llSay(0,"I am  toggled ON" +(string)privchan);
        llSetColor(<0.180, 0.800, 0.251>, ALL_SIDES);
        llSetPrimitiveParams( [ PRIM_GLOW, ALL_SIDES, FALSE ] );
        particle_system_off();
        is_on = TRUE;
        }
    }
}
