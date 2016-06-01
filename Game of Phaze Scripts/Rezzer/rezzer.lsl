
// fiddly bits
vector POS = <0,0,2>; // rez objects 2 meters above this prim
integer channel = 3454;  // must match the number  in the Objects


// globals
key User;                 // place to hold the avatars key
integer dialogchannel;    // dialog boxes have their own channel
integer listener;         // holds the listener so we can delete it to control lag
list items;               // place to hold all object names

// kills all objects in 20 meters by saying derez on a channel
derez()
{
     llSay(channel,"derez");   
}

// destroy any old listener
// make a new random channel
// make a list of all OBJECTS in inventory
// display a dfialog box of choices

makeDialog(key User)
{
    if (listener)
        llListenRemove(listener);
    
    // random channel for menu listener
    dialogchannel = llCeil(llFrand(10000)+25000);
    listener = llListen(dialogchannel,"","","");

    items = ["Stop"];    // 0tyh element in the list is the lower left button.
    
    integer i;
    integer j = llGetInventoryNumber(INVENTORY_OBJECT); // how many OBJECTS in the prim
    for (i = 1; i <= j; i++)
    {
        items += llGetInventoryName(INVENTORY_OBJECT,i-1);
    }
    llDeleteSubList(items,11,99);  // this chops off items after the 11th, as the menu can only hold 12 including "Stop"
    llDialog(User,"Choose an Option",items,dialogchannel);
}

default
{
    touch_start(integer total_number)
    {
        User = llDetectedKey(0);    // save user away, we need it later
        makeDialog(User);           // bark up a dialog box
        llSetTimerEvent(60);        // 1 minute to choose an option
    }

    listen(integer channel, string name, key id, string message)
    {
        llSetTimerEvent(0);    // stop timer for saying "timed out", it didn't
        llListenRemove(listener);// always remove our dialog listener to stop lag

        // handle the messages that came in.
        if (message == "Stop") {
            derez();            // dertez the item and quit dialoging, he said "stop"
            
        } else {

            integer where = llListFindList(items,[message]); // find the menu item in the list of items

            // could be anywhere from the 0th to nth.  -1 if not found
            if (where >= 0)
            {
                derez();    // kill any dangly bits                
                llRezObject(message,(llGetPos() + POS) * llGetRot(),ZERO_VECTOR, ZERO_ROTATION,  1);
            }
            makeDialog(User);
        }
    }

    timer()
    {
        llWhisper(0,"Menu timed out");
        llSetTimerEvent(0);
    }
}