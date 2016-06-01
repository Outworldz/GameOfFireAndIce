//NOTES: ZERO_ROTATION for the launcher and the projectiles must be the same

string     gProjectileName         = "AIM-9LM-Projectile";
string     gShotSound             = "Missle_Launch";
float     gProjectileSpeed         = 55.0;
integer     gProjectileDamage     = 50; 
integer     gEnableProjectile;
integer     gEnableSound;
vector     gAimOffset=<3.2,-2.0,-2.0>;
integer  gLinkChannel         = 2;

say(string message)
{
    llOwnerSay(message);
}

inventorycheck()
{
    if (llGetInventoryKey(gProjectileName) != NULL_KEY) {
            gEnableProjectile = TRUE;
    } else {
        gEnableProjectile = FALSE;
        say("bullet not found: " + gProjectileName);
    }
    if (llGetInventoryKey(gShotSound) != NULL_KEY) {
        gEnableSound = TRUE;
    } else {
        gEnableSound = FALSE;
        say("sound not found: " + gShotSound);
    }
}

// wiki ---syntax---
//llRezObject(string inventory, vector pos, vector vel, rotation rot, integer param)
launchmissile(){
    if (gEnableSound) llTriggerSound(gShotSound, 1.0);
    //get launcher's position & rotation and rez projectile at a relative position with
    //the same rotation.
    rotation     rot = llGetRot();
    vector         aim = llRot2Fwd(rot);
    vector         pos = llGetPos() + gAimOffset + (aim * 1.0);
    vector         vel = aim * gProjectileSpeed;
    
    //llSay(0,"llRezObject(" + gProjectileName +",Position:" + (string)pos + ",Velocity:" +(string)vel + ",Rotation:" + (string)rot +")");
    
    if (gEnableProjectile) llRezObject(gProjectileName, pos, vel, rot, gProjectileDamage);
} 

default
{  
    state_entry()
    {
        inventorycheck();
    }
    
    touch_start(integer count){
    //launchmissile();
    }
    link_message(integer sender, integer num, string msg, key id){
        gProjectileSpeed = (float)msg;
    if(num==gLinkChannel) launchmissile();
    }
}