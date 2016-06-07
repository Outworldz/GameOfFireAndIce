// :CREATED: 9-8-2014
// :REV: 1.0
// :DESCRIPTION: 
// Vehicle code for the Elephant  Rider.  
//5/27/2015 Reworked by Vegaslon Plutonian to play nice with the dragon flight script. Added mode switching by pushing forward twice to run and holding up control to jump and fly. 
//12/11/2015 Vegaslon Plutonian fixed dragon death.

// :CODE:


integer PRODUCTION = FALSE;
integer debug = FALSE;         // set to TRUE or FALSE for debug chat on various actions
integer DragonChannelBack = 549898; // channel the dragon talks back on.
integer DragonChannel = 549897; // secret channel to comm with Dragons. set to zero to not care about them
 
// OpenSim & ODE
// NPC animations

string NPCSit = "Sit";
string NPCStand = "dragon stand";
string NPCWalk = "Dragon Walk";
string NPCRun = "dragon run";
string NPCLeap= "Dragon Takeoff";
string NPCTakeoff ="Dragon Takeoff";
string NPCLand= "Dragon Land";
string NPCFall = "dragon fall";
string NPCGlide = "Dragon Glide2";

string whatsplaying = "";      // the currently playing NPC automation

integer Private = 0;    // Change to 1 to prevent others riding.
float  gallop= 1.0;
vector Sitpos = <0,0,2.0>;
vector SitrotV = <0,0,01>;
rotation Sitrot; 
integer animation_allowed = FALSE;
key Agent; 

float forward_power = 6; //Power used to go forward (1 to 30)
float reverse_power = -6; //Power ued to go reverse (-1 to -30)
float turning_ratio = 0.5; //How sharply the vehicle turns. Less is more sharply. (.1 to 10)


float Speed;
integer NPCisRunning;

string AvatarSit = "horse_sit";
string AvatarWalk = "horse_sit walk";
string AvatarRun = "horse_sit gallop";

string last_animation;
float forward_timer=0;
float walk_timer=0;
//---SOUND VARIABLES---------------------------------------------------

string       gSoundLoopSlow =           "Dinosaur Footstep";
string       gSoundLoopAggressive =     "Dinosour Footstep";

string gOldSound;
string gNewSound;

DEBUG(string str)
{
    if (debug)
        llOwnerSay(llGetScriptName()+":" +  str);                    // Send the owner debug info so you can chase NPCS
}

// pipeline for animations for the owner
AvatarAnimate(string animation)
{
    if (animation != last_animation) {
        DEBUG("Avatar Animate " + animation);
        llStartAnimation(animation);
        llStopAnimation(last_animation);
        last_animation = animation;
    }
}

WalkSound(){
    vector vel = llGetVel();
    float speed = llVecMag(vel);
    if (Speed < 0.1){
        //gTurnMulti=1.012345;
        llStopSound();
     } else if (Speed > 0.1){
        // gTurnMulti=2.012345;
        gNewSound = gSoundLoopSlow;
    } else {
      //  gTurnMulti=3.012345;
        gNewSound = gSoundLoopAggressive;
    }
    
    if (gOldSound != gNewSound){
        llLoopSound(gNewSound,1.0);
        gOldSound = gNewSound;
    }  
}

SetMaterial()
{
    llSetPrimitiveParams([PRIM_MATERIAL, PRIM_MATERIAL_GLASS]);
    llMessageLinked(LINK_ALL_OTHERS, 0, "SetMat", NULL_KEY);    // Tell daughter pims on ground to be glass
}


// and for the NPC
NPCPlay(string what, float howlong)
{
    if (whatsplaying != what) {
        DEBUG("Playing NPC animation " + what + ", stopping " + whatsplaying);
        osNpcStopAnimation(NPCKey, whatsplaying);
        osNpcPlayAnimation(NPCKey, what);
        
        llSleep(howlong);
        whatsplaying = what;
    }       
}


setVehicle()
{
    //car
    llSetVehicleType(VEHICLE_TYPE_CAR);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.2);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.80);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 0.50);
    llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 0.10);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 1.0);
    llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.1);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.1);
    llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.1);
    llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <10.0, 2.0, 1000.0>);
    llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <0.1, 0.1, 0.1>);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.1);
    llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 5.0);
}
fly()
{
    llReleaseControls();
    llSetTimerEvent(0.0);
    NPCPlay(NPCTakeoff,2);
    gOldSound="";
    llMessageLinked(LINK_SET,0,"Seated",Agent);
}
land()
{
    
    llMessageLinked(LINK_SET,0,"Unseated","");
    llSetTimerEvent(0.3);
    NPCPlay(NPCLand,2);
    NPCPlay(NPCStand,0);
    llRequestPermissions(Agent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA| PERMISSION_TAKE_CONTROLS);
}

    
Init()
{
    llSetStatus(STATUS_PHYSICS, FALSE);

    vector rotv = llRot2Euler(llGetRot());
    rotation rot = llEuler2Rot(<0,0,rotv.z>);
    llSetRot(rot);
    
    llSetVehicleType(VEHICLE_TYPE_NONE);
    NPCisRunning = FALSE;
}

string KeyValueGet(string var) {
    list dVars = llParseString2List(llGetObjectDesc(), ["&"], []);
    do {
        list data = llParseString2List(llList2String(dVars, 0), ["="], []);
        string k = llList2String(data, 0);
        if(k != var) jump continue;
        //DEBUG("got " + var + " = " +  llList2String(data, 1));
        return llList2String(data, 1);
        @continue;
        dVars = llDeleteSubList(dVars, 0, 0);
    } while(llGetListLength(dVars));
    return "";
}


KeyValueSet(string var, string val) {

    //DEBUG("set " + var + " = " + val);
    list dVars = llParseString2List(llGetObjectDesc(), ["&"], []);
    if(llGetListLength(dVars) == 0)
    {
        llSetObjectDesc(var + "=" + val);
        return;
    }
    list result = [];
    do {
        list data = llParseString2List(llList2String(dVars, 0), ["="], []);
        string k = llList2String(data, 0);
        if(k == "") jump continue;
        if(k == var && val == "") jump continue;
        if(k == var) {
            result += k + "=" + val;
            val = "";
            jump continue;
        }
        string v = llList2String(data, 1);
        if(v == "") jump continue;
        result += k + "=" + v;
        @continue;
        dVars = llDeleteSubList(dVars, 0, 0);
    } while(llGetListLength(dVars));
    if(val != "") result += var + "=" + val;
    llSetObjectDesc(llDumpList2String(result, "&"));
}


key NPCKey;

StartNPC() {
    NPCKey = osNpcCreate("Dragon", "Walker", llGetPos()+<0,0,20>, "Appearance", OS_NPC_SENSE_AS_AGENT);    // no OS_NPC_SENSE_AS_AGENT allowed due to llSensor Use
    llMessageLinked(LINK_SET,0,"NPCkey",NPCKey);

    KeyValueSet("key",  NPCKey);       
    llSleep(2);
            
    osNpcSit(NPCKey,llGetKey(), OS_NPC_SIT_NOW);     
}

init_followCam(){
    
    llSetCameraParams([
                       CAMERA_ACTIVE, 1,                     // 0=INACTIVE  1=ACTIVE
                       CAMERA_BEHINDNESS_ANGLE, 45.0,         // (0 to 180) DEGREES
                       CAMERA_BEHINDNESS_LAG, 1.0,           // (0 to 3) SECONDS
                       CAMERA_DISTANCE, 4.0,                 // ( 0.5 to 10) METERS
                       CAMERA_PITCH, 10.0,                    // (-45 to 80) DEGREES
                       CAMERA_POSITION_LOCKED, FALSE,        // (TRUE or FALSE)
                       CAMERA_POSITION_LAG, 0.01,             // (0 to 3) SECONDS
                       CAMERA_POSITION_THRESHOLD, 2.0,       // (0 to 4) METERS
                       CAMERA_FOCUS_LOCKED, FALSE,           // (TRUE or FALSE)
                       CAMERA_FOCUS_LAG, 0.01 ,               // (0 to 3) SECONDS
                       CAMERA_FOCUS_THRESHOLD, 0.01,          // (0 to 4) METERS
                       CAMERA_FOCUS_OFFSET, <2.0,0.0,0.0>   // <-10,-10,-10> to <10,10,10> METERS
                      ]);
}

default
{
    state_entry()
    {
        Init();
        SetMaterial();
        llListen(DragonChannel,"","","");
        llSitTarget(Sitpos, Sitrot); 
        osNpcRemove(KeyValueGet("key"));
        NPCisRunning = FALSE;        
    }
    
    on_rez(integer rn)
    {
        llResetScript();
    }
        link_message(integer sender_number, integer number, string message, key id)
    {
        if(message=="land")
            land();
         
         else if (message == "Dead")    {

                 if (NPCisRunning) {
                    DEBUG("Remove NPC");
                    osNpcRemove(KeyValueGet("key"));
                    NPCisRunning = FALSE;
                
                    
                    
                    if (PRODUCTION)
                    {
                        llUnSit(Agent);
                        llDie();
                    }
            }
        }
    }
    
    changed(integer change)
    {    

        if (change & CHANGED_REGION) //note that it's & and not &&... it's bitwise!
        {
            llResetScript();
            
        }
        if (change & CHANGED_LINK)
        {
            DEBUG("CHANGED_LINK");
            key avatarKey = llAvatarOnLinkSitTarget(2);
            key  npcKey  = llAvatarOnSitTarget();
            
            DEBUG("Key on Seat  = " + (string) avatarKey);
            DEBUG("Key on ROOT  = " + (string) npcKey);
                        
                        
            if (avatarKey  != NULL_KEY &&  npcKey == NULL_KEY)
            {
                StartNPC();    
                llWhisper(0,"Use arrow keys to steer.  PG Up to gallop, Pg Down to walk.");
                Agent = avatarKey; 
                NPCisRunning = TRUE;
                DEBUG("Starting platform for " + (string) Agent);
                llRequestPermissions(Agent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_CONTROL_CAMERA| PERMISSION_TAKE_CONTROLS);
                return;
            }
                        
            if ( avatarKey == NULL_KEY)
            {
                if (NPCisRunning) {
                    DEBUG("Remove NPC");
                    osNpcRemove(KeyValueGet("key"));
                    NPCisRunning = FALSE;
                    
                    Init(); // shut down physics
                    llReleaseControls();
                     llTriggerSound("singlemoo",1.0);
                    
                    animation_allowed = FALSE;
                    
                    NPCPlay(NPCStand,0.1); 
                    llSetTimerEvent(0.0);
                    
                    llTriggerSound("59245__zozzy__z-moo01",1.0);
                    llSleep(2);
                    
                    llMessageLinked(LINK_SET,0,"Reset","");
                    
                    
                    if (PRODUCTION)
                    {
                        llDie();
                    }
                }
            }
            
            if (npcKey  != NULL_KEY)
            {                
                if( osIsNpc(npcKey) )
                {
                    DEBUG("Cow Seated");
                    whatsplaying = "sit";
                    NPCPlay(NPCStand,0); 
                }
            }   
        }
        
        if (change & CHANGED_REGION_RESTART)
        {
            llResetScript();
        }
    }
    
    run_time_permissions(integer perm)
    {
        if (perm)
        {
            //llOwnerSay("Perms check");
            if (perm & PERMISSION_CONTROL_CAMERA)
            {
                init_followCam();
            }

            if (perm & PERMISSION_TAKE_CONTROLS)
            {
               
                
                llSetTimerEvent(0.3);
                NPCPlay(NPCStand,0);
                
                llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP | CONTROL_RIGHT | CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT | CONTROL_LBUTTON, TRUE, FALSE);
                setVehicle();
           
                llSleep(0.1);
                llSetStatus(STATUS_PHYSICS, TRUE);
                llSleep(.1);
            }
            if (perm & PERMISSION_TRIGGER_ANIMATION)
            {
                last_animation="sit";
                AvatarAnimate(AvatarSit);
            }
             
        }
    }
    
    
    control(key id, integer level, integer edge)
    {
        integer reverse=1;
        vector angular_motor;
        
        //get current speed
        vector vel = llGetVel();
        Speed = llVecMag(vel);
        //DEBUG((string)Speed);

        //car controls
        if(level & CONTROL_FWD)
        {
            llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <10.0, 2.0, 1000.0>);
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <forward_power * gallop,0,0>);
            reverse=1;
            
            if(edge & CONTROL_FWD)
            {
        float tm = llGetTime()-walk_timer;
        
             if(tm<0.3)
             {
                if (gallop == 1.0)
                llTriggerSound("GrowlSound",1.0); 

                     gallop = 2.0;
                }
            }
            
        }
        if (~level & edge & CONTROL_FWD)
        {
           gallop = 1.0; 
            walk_timer=llGetTime();
        }
         // if (~level & edge & CONTROL_FWD) llOwnerSay("forward released");
        
        if(level & CONTROL_BACK)
        {
            llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <10.0, 2.0, 1000.0>);
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <reverse_power,0,0>);
            reverse = -1;
        }

        if(level & (CONTROL_RIGHT|CONTROL_ROT_RIGHT))
        {
            angular_motor.z -= Speed / turning_ratio * reverse;
        }
        
        if(level & (CONTROL_LEFT|CONTROL_ROT_LEFT))
        {
            angular_motor.z += Speed / turning_ratio * reverse;
        }
        
        if(level & (CONTROL_UP))
        {
            
            if(forward_timer==0)
                    forward_timer=llGetTime();
            else
            {
             float tm = llGetTime()-forward_timer;
            // llOwnerSay((string)tm);
             if(tm<0.3)
                {
                    
                  NPCPlay(NPCLeap,0); 
                    llApplyImpulse(<0,0,llGetMass()*12>,FALSE); //Rotates object.
                   // forward_timer=0;
                }
            else
            {
                forward_timer=0;
                
                fly();
            //if (gallop == 1.0)
              //   llTriggerSound("singlemoo",1.0); 

           // gallop = 2.0;
            }
            }
            
        }
        if (~level & edge & CONTROL_UP)
            forward_timer=0;
        
        if(level & (CONTROL_DOWN))
        {
             if (gallop == 2.0)
                 llTriggerSound("GrowlSound",1.0);
           
            gallop = 1.0;
        }
                if ((level & edge & CONTROL_LBUTTON)) {

            llMessageLinked(LINK_SET, 66, "fire", "");

        } 
        else if (edge & CONTROL_LBUTTON) { // !level implied.
            llMessageLinked(LINK_SET, 65, "",  "");

        }
        

        llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor);

          
        
    } //end control    
    listen(integer channel, string name, key id, string message)
    {
                if (channel == DragonChannel && (key) message == llGetKey())
        {
            
            if (Agent != NULL_KEY)
                llSay(DragonChannelBack, (string) Agent);
            return;
        } 
    }    

    timer(){
        if(NPCisRunning){
            vector vel = llGetVel();

            Speed = llVecMag(vel);
            //DEBUG("vecMag Speed " + (string)Speed);   
            if (vel.z< -5){
                if ((whatsplaying != NPCFall)&&(whatsplaying != NPCGlide))
                    NPCPlay(NPCFall,1);
                else
                    NPCPlay(NPCGlide,0);
            }        

            else if(Speed > 0.1)
            {
                if (gallop == 1.0) {
                    AvatarAnimate(AvatarWalk);
                    NPCPlay(NPCWalk,0);
                }
                else  {
                    AvatarAnimate(AvatarRun);
                    NPCPlay(NPCRun,0); 
                }
                    
                llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1.0, 2.0, 1000.0>);
                llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <0,0,0>);
            }
            else {
                AvatarAnimate(AvatarSit);
                NPCPlay(NPCStand,0);
            }
            WalkSound();
            llSetTimerEvent(0.3);          // If restarted timer() appears to keep working  
        }else{
            llSetTimerEvent(0.0);
        }
    }
    
} //end default