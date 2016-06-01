// 3-15-2015
// hovertext above demon head

default
{
    state_entry()
    {
        llSetText("?",<1,1,1>,1);
    }

    link_message(integer sender, integer num, string str, key id)
    {
        llSetText(str,<1,1,1>,1);

    }
} 