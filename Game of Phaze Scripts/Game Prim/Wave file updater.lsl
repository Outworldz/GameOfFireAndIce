//
// fred@mitsi.com
// Sound prim updater
// sends all the UUIDs of wave files in inventory to the script controller
// author Ferd Frederix
// Copyright 2009, All rights reserved
//
// Sound Updater


DEBUG(string msg){
    if (debug) llSay(0,msg);
}
integer debug = TRUE ;
string Type;
string Type1= "PassSound";
string Type2= "FailSound";
string Type3= "RepeatSound";

integer  Busy = FALSE;
key http_request_id;
integer i;
integer TotalInventoryCount;

PutWave()
{
    //DEBUG("i=" + (string) i);
    string _InventoryName = llGetInventoryName(INVENTORY_SOUND,i);
    list strings = llParseString2List(_InventoryName,["-"],[]);
    string _Name_esc = llEscapeURL(llList2String(strings,1) + llList2String(strings,2));       
    string type = llList2String(strings,0);

    //DEBUG("Type:" + type);
    
    if (type == "Pass")
        Type = Type1;
    else if (type == "Fail")
        Type = Type2;
    else if (type == "Repeat")
        Type = Type3;
    else  {
        i++;
        if (i < TotalInventoryCount) {
            llSetTimerEvent(1.0);
            return;
        } else {
            llOwnerSay("Done");
            llSetTimerEvent(0);
            return;
        }
    }
    
    if (i < TotalInventoryCount) {
        Busy = TRUE;
        i++;

        key _InventoryKey = llGetInventoryKey(_InventoryName);
        string _UUID_esc = (string) _InventoryKey;

        _UUID_esc = llEscapeURL(_InventoryKey);
        string _url = "http://www.outworldz.com/cgi/llgame.plx?Type=" + Type + "&SoundID=" +  _UUID_esc + "&Name=" + (string) _Name_esc;
        DEBUG(_url);

        http_request_id = llHTTPRequest(_url, [], "");
    } else {
        llOwnerSay("Done");
        llSetTimerEvent(0);
    }
}

default
{

    touch_start(integer total_number)
    {
        if (Busy){
            llOwnerSay("Busy");
            return;
        }
        TotalInventoryCount = llGetInventoryNumber(INVENTORY_SOUND);
        if (TotalInventoryCount == 0){
            llOwnerSay("No sound files");
            return;
        }else{
            llOwnerSay("Sending " + (string)TotalInventoryCount + " Wave files" );
        }
        i = 0;
        llSetTimerEvent(1.0);
    }


    on_rez(integer start_param)
    {
        llResetScript();
    }

    http_response(key request_id, integer status, list metadata, string body)
    {       
        if (request_id == http_request_id)
        {
            DEBUG(body);
            Busy = FALSE;
        }
    }
    timer()
    {
        if (Busy)
            return;
        PutWave();
    }
}



