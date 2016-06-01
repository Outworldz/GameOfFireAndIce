// 4-13-2014
// sit script for wizard game


key lastKey;
key currentAVkey;
integer seated = FALSE;

default
{
    state_entry()
    {
        llSitTarget(<0,0,1.2>, ZERO_ROTATION);
        llSetSitText("Play Game");
        llSetText("", <1,1,1>, 1);
    }
    touch_start(integer i)
    {
        llSay(0,"Right click me and chose 'Sit Here'");
    }
    
   
    
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            currentAVkey = llAvatarOnSitTarget();
           // llOwnerSay((string) lastKey);
            
            if (currentAVkey != NULL_KEY)
            {
                llRequestPermissions(currentAVkey,PERMISSION_TRIGGER_ANIMATION);   
            }
            else if (seated)
            {
                llMessageLinked(LINK_SET,100,"Not Playing Wizard Game",lastKey);
                seated = FALSE;
            }
        }
    }
    
     run_time_permissions(integer perm)
    {
        if(PERMISSION_TRIGGER_ANIMATION & perm)
        {
            llStopAnimation("sit");
            llStartAnimation("ao-sweetness-stand2");
            lastKey = currentAVkey;
            llMessageLinked(LINK_SET,100,"Playing Wizard Game",currentAVkey);
            llMessageLinked(LINK_SET,(integer) llGetObjectDesc(),"spin",currentAVkey);
            seated = TRUE;
        }
    }

            
}


