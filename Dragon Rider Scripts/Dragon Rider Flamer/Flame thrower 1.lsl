//Rezzes the flame prim if they are close to the particles.
default
{
    link_message(integer sn, integer num, string who, key id)
    {
        if (num == 66) {
            llSensorRepeat("", NULL_KEY, AGENT|ACTIVE, 10,PI , .1);
        } else {
            llSensorRemove();
        }
    }
 
    sensor(integer tn)
    {
        integer basechan = 65536 + (integer)llFrand(65536); 
        integer i;
        for (i = 0; i < tn; i++) {
            list my_list = llParseString2List(llDetectedName(i),["-"],[""]);
            if(llList2String(my_list,0)!="flame")
            {
            // step through all AGENTS returned by sensor sweep
            // This is a trick to calculate a point in front of me weapon_length away
            // Thanks Mephistopheles Thalheimer (SL) for this trick
            vector A = ( llGetPos() + < 0,0,5> * llGetRot());
            // Where is Defender
            vector D = llDetectedPos(i);
            if ( llVecDist(A,D) < 5.0 ) {
            llRezObject("flame", llGetPos(), ZERO_VECTOR, ZERO_ROTATION, basechan + i);
           // llOwnerSay(llDetectedName(i));
        }
            }
        }
        llSleep(.1); 
        for (i = 0; i < tn; i++) {
            llRegionSay(basechan + i, llDetectedKey(i));
        }
    }
} 