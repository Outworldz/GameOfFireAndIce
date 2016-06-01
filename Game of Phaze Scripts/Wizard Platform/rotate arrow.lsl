integer getPrimNum()
{
    integer j = llGetNumberOfPrims();
    integer i;
    
    for (i = 0; i <= j; i++)
    {
        list names = llGetLinkPrimitiveParams(i,[PRIM_NAME]);
        string name = llList2String(names,0);
       //llOwnerSay(name);
        if (name == "Spin")
        {
            return i;
        }   
    }
    return 0;
    
}


integer primnum;

integer positions = 4;

integer i;

rotate(integer N)
{

    vector xyz_angles = <0,0.0,N>; // This is to define a 90 degree change
    vector angles_in_radians = xyz_angles*DEG_TO_RAD; // Change to Radians
    rotation rot_xyzq = llEuler2Rot(angles_in_radians); // Change to a Rotation
    

    llSetLinkPrimitiveParamsFast( primnum, [PRIM_FULLBRIGHT,ALL_SIDES,FALSE,PRIM_ROT_LOCAL, rot_xyzq] );
    llSleep(.5);
    llSetLinkPrimitiveParamsFast( primnum, [PRIM_FULLBRIGHT,ALL_SIDES,TRUE] );
}
default
{
    state_entry()
    {
    
         primnum = getPrimNum();
    
        if (primnum) 
        {
            vector input = <0.0, 0.0, 0.0> * DEG_TO_RAD;
            rotation initrot = llEuler2Rot(input);
            llSetLinkPrimitiveParamsFast( primnum, [PRIM_ROT_LOCAL, initrot] );
            llSetTimerEvent(3.0);
        }
        else
        {
            llOwnerSay("Nothing named Spin");
        }
        
        
    }
 
    link_message( integer sender_num, integer num, string str, key id )
    {
        if (str == "spin")
        {
            llSetTimerEvent(0);
            rotate(num);
            llMessageLinked(LINK_SET,100,"Seat " + (string) num,id);
        }
        else if (str == "Not Playing Wizard Game")
        {
            llSetTimerEvent(3.0);
        }
    
    }
    timer() 
    {
        
            i += 90;
            rotate(i);

        
    }
}