SendPos()
{
    vector pos = llGetLocalPos() + llGetRootPosition();
    llMessageLinked(LINK_SET,100,"Pos" + llGetObjectDesc() + "|" + (string) pos,llGetOwner());
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
