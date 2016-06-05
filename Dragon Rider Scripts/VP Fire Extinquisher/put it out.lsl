
 integer held;

default
{
    state_entry()
    {
        if (llGetAttached()) {
            llRequestPermissions(llGetOwner(), PERMISSION_TAKE_CONTROLS | PERMISSION_TRIGGER_ANIMATION);
        }
 
    }
        on_rez(integer pam)
{
 
  llResetScript();
}
 


    touch_start(integer numberDetected)
    {
        llSensorRepeat("", NULL_KEY, ACTIVE , 6, PI / 2 , .1);

         llMessageLinked(LINK_SET, 66, "fire", "");

         // look for avatars (i.e. not moving objects) on all sides of the object
    }
    touch_end(integer numberdetected)
    {
        llSensorRemove();
        llMessageLinked(LINK_SET, 65, "",  "");

}
 run_time_permissions (integer p) {
        if (p & PERMISSION_TRIGGER_ANIMATION) {
            llStartAnimation("hold_r_handgun");

 
        }
        if (p & PERMISSION_TAKE_CONTROLS) {
            llTakeControls(CONTROL_ML_LBUTTON | CONTROL_DOWN, 1, 0);
        }
    }

 
    sensor (integer numberDetected)
    {
        string msg = "Detected " + (string)numberDetected + " avatar(s): " + llDetectedName(0);
        integer i = 0;
        while(numberDetected > i)//skips the first item which suits this application
        {
            llSay(999999,(string)llDetectedKey(i));
            
            ++i;
        }
        //llOwnerSay( msg);
    }
 
    no_sensor()
    {
    
    }
    control(key id, integer level, integer edge)
    {
        if (level & edge & CONTROL_ML_LBUTTON) {
        llSensorRepeat("", NULL_KEY, ACTIVE, 6, PI / 2 , .1);
            llMessageLinked(LINK_SET, 66, "fire", "");
            llStartAnimation("hold_r_handgun");
            held = 1;
        } else if (edge & CONTROL_ML_LBUTTON) { // !level implied.
            if (!held)
                return;
            held = 0;
            llMessageLinked(LINK_SET, 65, "",  "");
llSensorRemove();
            llStopAnimation("hold_r_handgun");
            llStopAnimation("aim_r_handgun");
            llSetTimerEvent(0.0);
        }}

}