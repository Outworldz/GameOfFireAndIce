
// Rev 1 from Phaze Demenese in Second life
// Rev 2 09-02-2015 allow link message to start this
// Rev 3 09-03-2015 count charaxcters to prevent overrezzing


// tuneables
integer debug = FALSE;
integer INTERVAL = 10; // how many seconds between rezziong a new character
integer MAX_CHARACTERS = 5;
vector relativePosOffset = <0, 0, -3>; // This will rez the box below me.  


// non tuneables
DEBUG(string str) {
    if (debug) llOwnerSay(llGetScriptName() + ":" + str);
}

integer iScoreChannel = 7434;
integer iChangeChannel = 1000000;     // incrementing channel for demon prims to use
vector vRelativeVel = ZERO_VECTOR; // Traveling in this prim's "forward" direction at 1m/s
integer iListener;
integer busy = FALSE; 
key AvatarKey ;

Rez()
{
    busy = TRUE;
            
    DEBUG("Character enters battle");
    llRegionSayTo(AvatarKey, 0,"Click them before they kill you! Click them, quickly!");
    vector myPos = llGetPos();
    rotation myRot = llGetRot();
    vector rezPos = myPos+relativePosOffset*myRot;
     
    string object = llGetInventoryName(INVENTORY_OBJECT,0);   
    DEBUG("Rezzing " + object);
    DEBUG("Channel:"+ (string) iChangeChannel);
    iListener = llListen(iChangeChannel,"","","");
    llRezObject(object, rezPos, ZERO_VECTOR, llGetRot(), iChangeChannel);
    llSetTimerEvent(INTERVAL);
}



default 
{
    
    link_message(integer Link, integer Num, string Txt, key ID)
    {
        if (Txt != "FIRE")
            return;
            
        if (busy)
            return;

        AvatarKey = ID;
        // we need a count of boxes in world
        llSensor(llGetInventoryName(INVENTORY_OBJECT,0),NULL_KEY,SCRIPTED,5,PI);        
    }

    // no players yet, rez one.
    no_sensor() {
        Rez();
    }
    
    sensor(integer n)
    {
         if (n < MAX_CHARACTERS) {
                Rez();
        }
    }
    
    timer()
    {
        busy = 0;
        llSetTimerEvent(0);
    }
    
    listen(integer channel, string name, key id, string message)
    {
        DEBUG("Heard:" + message);
        llListenRemove(iListener);
        DEBUG("Channel:" + (string) iChangeChannel);
        DEBUG("Key:" + (string) AvatarKey);
        llWhisper(iChangeChannel, (string) AvatarKey);  // tell the prim who to chase
        llRegionSay(iScoreChannel,llKey2Name(AvatarKey) + " started a battle" );      
        iChangeChannel += 10;;
    }   
}