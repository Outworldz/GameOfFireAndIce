// smoke for avatars arriveing
// 4-13-2014


integer debug = 0;

    updateParticles() {
        llParticleSystem(  [ 
           PSYS_SRC_TEXTURE, llGetInventoryName(INVENTORY_TEXTURE, 0), 
           PSYS_PART_START_SCALE, <15.5,15.5, 0>,  PSYS_PART_END_SCALE, <0,2.0, 0>, 
           PSYS_PART_START_COLOR, <255,140,0>,       PSYS_PART_END_COLOR, <.5,.2,0>, 
           PSYS_PART_START_ALPHA, 1.0,            PSYS_PART_END_ALPHA, 0.0,     
         
           PSYS_SRC_BURST_PART_COUNT, 1, 
           PSYS_SRC_BURST_RATE,  0.01,  
           PSYS_PART_MAX_AGE, 3.4, 
           PSYS_SRC_MAX_AGE, 0.0,  
        
           PSYS_SRC_PATTERN, 8, // 1=DROP, 2=EXPLODE, 4=ANGLE, 8=ANGLE_CONE,
           PSYS_SRC_ACCEL, <0.0,0.0,0.0>,  
           
        // PSYS_SRC_BURST_RADIUS, 0.0,
           PSYS_SRC_BURST_SPEED_MIN, .01,   PSYS_SRC_BURST_SPEED_MAX, 3.01, 
        
           PSYS_SRC_ANGLE_BEGIN,  1*DEG_TO_RAD,        PSYS_SRC_ANGLE_END, 0*DEG_TO_RAD,  
           PSYS_SRC_OMEGA, <0,0,0>, 
        
        // PSYS_SRC_TARGET_KEY,      llGetLinkKey(llGetLinkNum() + 1),       
              
           PSYS_PART_FLAGS, ( 0      
                                | PSYS_PART_INTERP_COLOR_MASK   
                                | PSYS_PART_INTERP_SCALE_MASK   
                                | PSYS_PART_EMISSIVE_MASK   
                                | PSYS_PART_FOLLOW_VELOCITY_MASK
                             // | PSYS_PART_WIND_MASK            
                             // | PSYS_PART_BOUNCE_MASK          
                             // | PSYS_PART_FOLLOW_SRC_MASK     
                             // | PSYS_PART_TARGET_POS_MASK     
                             // | PSYS_PART_TARGET_LINEAR_MASK    
            ) ] );
    }


string cmd;
    

default
{
    state_entry()
    {
         llParticleSystem([]);
        cmd = "smoke" +  llGetObjectDesc() ;
        llOwnerSay(cmd);
    }
    
    link_message(integer source, integer num, string msg, key id)
    {    
    
        if (debug)
            llOwnerSay("Ptim 90 report num:" + (string) num + " msg: " + msg);
            
        if (msg == cmd ) {
           // llOwnerSay("Particles");
            updateParticles() ;
            llSetTimerEvent(5);
        }
    }
    
    timer()
    {
        llSetTimerEvent(0);
        llParticleSystem([]);
        
    }
}

