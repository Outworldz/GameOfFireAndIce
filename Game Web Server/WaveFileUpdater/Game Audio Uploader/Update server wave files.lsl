// ______           _  ______            _           _
// |  ___|         | | |  ___|          | |         (_)
// | |_ ___ _ __ __| | | |_ _ __ ___  __| | ___ _ __ ___  __
// |  _/ _ \ '__/ _` | |  _| '__/ _ \/ _` |/ _ \ '__| \ \/ /
// | ||  __/ | | (_| | | | | | |  __/ (_| |  __/ |  | |>  <
// \_| \___|_|  \__,_| \_| |_|  \___|\__,_|\___|_|  |_/_/\_\
//
// fred@mitsi.com
// Sound prim updater
// sends all the UUIDs of wave files in inventory to the script controller
// author Ferd Frederix
// Copyright 2009, All rights reserved
//
// Sound Updater


integer debug = TRUE ;
string Type= "PassSound";
//string Type= "FailSound";


integer  Busy = FALSE;

key http_request_id;
integer i;

integer TotalInventoryCount;

PutWave()
{
    string _InventoryName = llGetInventoryName(INVENTORY_SOUND,i);
    key _InventoryKey = llGetInventoryKey(_InventoryName);
    string _UUID_esc = (string) _InventoryKey;

    _UUID_esc = llEscapeURL(_InventoryKey);
    string _Name_esc = llEscapeURL(_InventoryName);

    string _url = "http://secondlife.mitsi.com/cgi/llgame.plx?Type=" + Type + "&SoundID=" +  _UUID_esc + "&Name=" + (string) _Name_esc;
    if (debug ) llOwnerSay(_url);
    Busy = TRUE;
    http_request_id = llHTTPRequest(_url, [], "");


}

default
{
    state_entry()
    {


    }

    touch_start(integer total_number)
    {
        TotalInventoryCount = llGetInventoryNumber(INVENTORY_SOUND);
        if (TotalInventoryCount == 0)
        {
            llOwnerSay("No sound files");
        }
        else
        {
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
        if (debug)
            llOwnerSay("Responded");
        
                if (request_id == http_request_id)
        {
            if (debug)
                llOwnerSay(body);

            Busy = FALSE;
            i++;
            if (i < TotalInventoryCount)
                llSetTimerEvent(1.0);
            else
                llOwnerSay("Done");
        }
    }
    timer()
    {
        llSetTimerEvent(0.0);
        PutWave();
    }
}