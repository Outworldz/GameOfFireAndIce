// revisuiosn:

// added high score counter

string act = "act1";

// Beware of llOwnerSay spam if you turn debug on...
integer debug = FALSE;


integer countToReset = 0;
integer listenchannel = 7435;

// Borrowed from xyzzy10 scrip:
integer DISPLAY_STRING      = 204000;
integer DISPLAY_EXTENDED    = 204001;
integer REMAP_INDICES       = 204002;
integer RESET_INDICES       = 204003;
integer SET_FADE_OPTIONS    = 204004;
integer SET_FONT_TEXTURE    = 204005;
integer SET_LINE_COLOR      = 204006;
integer SET_COLOR           = 204007;
integer RESCAN_LINKSET      = 204008;
integer RESET_GROUP         = 204009;

list array = [0,10,1,11,2,12,3,13,4,14,5,15,6,16,7,17,8,18,9,19];

// =======================
// Main routine
// 3 states:  "default" "waiting" and "active"
// =======================
  
DEBUG( string msg)
{
    if (debug) llSay(0,msg);
    
    
}


list scores ; // 3 things score, key, name

integer STRIDE = 3;

integer channel = 7434;


HighScore()
{
    integer i;
    integer len = llGetListLength(scores);
    Blank();
    if (len == 0)
        Display("No one has played yet");

    if (len > 9)
        len = 9;
    
    string ToPrint  = "Magic Collection High Scores:";
    
    integer prim = llList2Integer(array,0);     // show on line 1
        
    //llOwnerSay("prim = " + (string) prim +", letter:" + dispMsg );
    llMessageLinked(LINK_THIS, DISPLAY_STRING, ToPrint, (string)prim);
        
    list score2 = llListSort(scores,STRIDE,FALSE);    // sort descengin, highest scores first;
    integer line = 2;
    for (i = 0; i < len; i+= STRIDE)
    {
        integer score = llList2Integer(score2,i);
        string name   = llList2String(score2,i+2);

        integer myprim = llList2Integer(array,line++);  //1 & 2 are taken by title
        
        //llOwnerSay("prim = " + (string) prim +", letter:" + dispMsg );
        llMessageLinked(LINK_THIS, DISPLAY_STRING, name, (string) myprim);

        
        ToPrint = (string) score;
        prim = llList2Integer(array,line++);
        llMessageLinked(LINK_THIS, DISPLAY_STRING, ToPrint, (string)prim );      // the rioght side is the score
        

    }
}



ShowScore(key avatarkey)
{
    string avatarname = llKey2Name(avatarkey);
    integer place = llListFindList(scores,[avatarkey]);
    if (place >= 0)
    {
        integer score = llList2Integer(scores,place-1);     // score is one less than the key
        Display(avatarname + "'s score is " + (string) score);
        llSetTimerEvent(20.0);
    }
}



Blank()
{
    integer letters;
    for (letters = 0; letters < 20; letters++) 
    {
        integer prim = llList2Integer(array,letters);
        llMessageLinked(LINK_THIS, DISPLAY_STRING, "",(string) prim);
    }
}


Display(string body)
{
    integer count1 = 0;//lines printed
    integer letters;
    
        
    integer i; //counter
    integer stringLength = llStringLength(body);
    list seperatedString = [];
    integer counter = 0;
    
    if (stringLength > 400)
        stringLength = 400;
    for (i = 0; i < stringLength; i+=20)
    {
        string dispMsg = llGetSubString(body, i, i+20);
        
        integer prim = llList2Integer(array,counter);
        
        //llOwnerSay("prim = " + (string) prim +", letter:" + dispMsg );
        llMessageLinked(LINK_THIS, DISPLAY_STRING, dispMsg, (string)prim);

        counter++;
        
    }
        // Overwrite any previously non-blank cells with blanks
    for (letters = counter; letters < 20; letters++) 
    {
        integer prim = llList2Integer(array,letters);
        llMessageLinked(LINK_THIS, DISPLAY_STRING, " ",(string) prim);
    }
}


score (key avatarkey, string avatarname) {
    
    integer place = llListFindList(scores,[avatarkey]);
    if (place >= 0)     // -1 means not in list, could be the 0th, 2nd, etc. as there are 2 things in the list
    {
        integer score = llList2Integer(scores,place-1) + 1;     // get the score from the slot one above the avatar key and add one to it
        scores = llListReplaceList(scores,[score],place-1, place-1);  // put it back in the list one slot above the key
    }
    else
    {
        scores += 1 ;                   // 1st element is the score, which is zero as this is the first time
        scores += avatarkey;            // not in list, add them to the list
        scores += avatarname;            // not in list, add them to the list
        
    }
}


zero(key avatarkey)
{
    integer place = llListFindList(scores,[avatarkey]);     // find their key
    if (place >= 0)         // if they are playing
    {
        scores = llListReplaceList(scores,[0],place-1, place-1);    // zero out the score with a [0]
    }    
}

default
{
    state_entry()
    {
        llListen(channel,"","","Pass");
        llListen(channel,"","","Fail");
        
        llMessageLinked(LINK_THIS, RESET_GROUP, "", "");
        
        llSleep(1.0);
        
       //if (debug)
       // {
       //     integer i;
       //     for (i = 0; i < 20; i++)
       //     {
       //         integer prim = llList2Integer(array,i);     // show on line 1
        
       //         llOwnerSay("prim = " + (string) prim +", letter:" + dispMsg );
       //         llMessageLinked(LINK_THIS, DISPLAY_STRING, (string) i, (string)prim);
       //    }
       //    llSleep(5.0);
       // }
        
        
        Display("Dust Collector Scores Appear Here");
        llSetTimerEvent(5.0);
        
        if (debug)
        {
            scores += 1 ;                   // 1st element is the score, which is zero as this is the first time
            scores += NULL_KEY;            // not in list, add them to the list
            scores += "Ferdzee"; 
            scores += 2 ;                   // 1st element is the score, which is zero as this is the first time
            scores += NULL_KEY;            // not in list, add them to the list
            scores += "Wavy"; 
        }
    }

        // protocol is camooand name, key avatar, and avatar name, comma delimited
    listen(integer channel,string name,key id,string message)
    {
        DEBUG("heard " + name + " message:" + message);
        
        list params = llParseString2List(message,[","],[]);     // make a list split on commans
        string command = llList2String(params,0);                  // get the command
        key kAvikey = (key) llList2String(params,1);               // get the avatr key
        string aviname  = llList2String(params,2);              // get the avatar name
         
        
        DEBUG("name = " + name + ", key = " + (string) kAvikey);
        
        if (command == "Pass")
        {
            // add one to the score
            score(kAvikey,aviname);
            ShowScore(kAvikey);
        }
        else if (command == "Fail")        // they collided, give them the score so they can rez rings and zero their counter
        {
            integer place = llListFindList(scores,[kAvikey]);
            if (place >= 0)     // -1 means not in list, could be the 0th, 2nd, etc. as there are 2 things in the list
            {
                integer score = llList2Integer(scores,place-1);     // score is one less than the key
                DEBUG("avikey," + (string)score);
                llShout(listenchannel,(string) kAvikey+ "," + (string)score);
                zero(kAvikey);               // zero their score
                ShowScore(kAvikey);         // and show it
            }
        }
    }
    

    touch_start(integer total_number)
    {
        
        string avatarname = llDetectedName(0);
        key AvatarKey = llDetectedKey(0);
        integer place = llListFindList(scores,[AvatarKey]);     // locate the key
        if (place >= 0)
        {
            integer score = llList2Integer(scores,place-1);     // the score is aloways one below the key, (the name is one above)
            Display(avatarname + "'s score is " + (string) score);
            llSetTimerEvent(20.0);
        }
        else
        {
            Display("You need to play the game first!");
            llSetTimerEvent(20.0);
        }
    }
    
    on_rez(integer startparam)
    {
        llResetScript();
    }
    
    timer()
    {
        HighScore();
        llSetTimerEvent(30);
    }
}
