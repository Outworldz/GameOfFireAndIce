default
{
    state_entry()
    {
       // llOwnerSay((string) llGetKey());
        llSitTarget(<0,0,1.2>, ZERO_ROTATION);
    }

    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            key currentAVkey = llAvatarOnSitTarget();
           // llOwnerSay((string) lastKey);
            
            if (currentAVkey != NULL_KEY)
            {
                llRequestPermissions(currentAVkey,PERMISSION_TRIGGER_ANIMATION);   
            }
            
        }
    }
    
     run_time_permissions(integer perm)
    {
        if(PERMISSION_TRIGGER_ANIMATION & perm)
        {
            llStopAnimation("sit");
            llStartAnimation("ao-sweetness-stand2");
        }
    }
   
}
