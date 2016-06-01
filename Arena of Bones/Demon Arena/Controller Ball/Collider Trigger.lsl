// :SHOW:
// :CATEGORY:NPC
// :NAME:All In One NPC Recorder and Player
// :AUTHOR:Ferd Frederix
// :KEYWORDS:
// :CREATED:2015-07-17 13:15:49
// :ID:27
// :NUM:1808
// :REV:3
// :WORLD:Second Life
// :DESCRIPTION:
// Sample collision script for NPC animator
// :CODE:
default
{
    state_entry()
    {
        llSay(0,"Script running");
        llSetText("",<1,1,1>,1.0);
        llVolumeDetect(FALSE);
        llVolumeDetect(TRUE);
        llSetTimerEvent(300);
    }
    
    timer()
    {
        llVolumeDetect(FALSE);
        llVolumeDetect(TRUE);
    }
    
    collision_start(integer n) {

        // make sure it is not an object- Objects have owners, avatars do not
        list x = llGetObjectDetails(llDetectedKey(0),[OBJECT_CREATOR]);
        key who = llList2Key(x,0);
        if (who != NULL_KEY)
            return;
             
        // make sure it is not an NPC
        if (osIsNpc(llDetectedKey(0)))
            return;
            
        llMessageLinked(LINK_SET,0, "FIRE",llDetectedKey(0));        
    }
     
    on_rez(integer p)
    {
        llResetScript();
    }
    
    changed(integer what)
    {
        if (what & CHANGED_REGION_START)
        {
            llResetScript();
        }
    }
}

