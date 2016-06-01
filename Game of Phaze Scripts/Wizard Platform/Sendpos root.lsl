SendPos()
{
    vector pos = llGetPos() ;
    llMessageLinked(LINK_SET,100,"Pos" + llGetObjectName() + "|" + (string) pos,llGetOwner());
}

default
{
    state_entry()
    {
        SendPos();
    }

    on_rez(integer total_number)
    {
        llResetScript();
    }
}
