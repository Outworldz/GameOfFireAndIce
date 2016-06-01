// Nara
// 11-25-2015 in Opensim

integer debug = FALSE;
string myName = "Nara";
string file = "Nara.htm";
integer sound = FALSE;
vector repeats = <0.30,0.30,0>;
vector offset = <-0.29740,0.34510,0>;
float ARC = PI;
float DISTANCE = 18.0;  // distance the picture will detect up an avatar, from 0.1 to 96.0.   Bigger numbers cause more lag
float RATE = 2.0;       // seconds to scan for an avatar, lower numbers cause more lag but faster response.
 

//url ="http://secondlife.mitsi.com/grid.jpg";

///////////////////////////////


DEBUG (string msg)
{
    if (debug)
        llSay(0,llGetScriptName() + " : " + msg);
}
 
integer counter;    // safety timer
list http_request_id;
integer nobody = TRUE;

// do not modify below this point
string ablank = "7ea8ba3e-eb63-4633-a262-99e5bb0dee34";      // a blank image
string no_viewer2 = "7ea8ba3e-eb63-4633-a262-99e5bb0dee34"; // a default image

list rules = [
PRIM_MEDIA_AUTO_PLAY ,1,
PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_OWNER, 
PRIM_MEDIA_PERMS_CONTROL,PRIM_MEDIA_PERM_OWNER, 
PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI, 
PRIM_MEDIA_AUTO_SCALE, FALSE,
//PRIM_MEDIA_WIDTH_PIXELS , 800,
//PRIM_MEDIA_HEIGHT_PIXELS , 600,
PRIM_MEDIA_CURRENT_URL ];
integer side = 0;
list page_visible ;     // hold the texture when avtar is away

list picture_image;     // holds the regular image
integer listener;
list web_rules; 


Thinking()
{
    DEBUG("Thinking");
    if (sound) llTriggerSound("typing",1.0);
    llSetTimerEvent(1.0);
    counter = 0;
}

StopThinking()
{
    DEBUG("Stop Thinking");
    llSetTimerEvent(0);
    llMessageLinked(LINK_SET,1,"default","");
}

SitUp()
{
    DEBUG("Sit Up");
    llMessageLinked(LINK_SET,1,"open","");
}

LayDown()
{
    DEBUG("lay Down");
    llMessageLinked(LINK_SET,1,"close","");
}

send(string talker, string theysaid, string justSpeak)
{
    Thinking();
                
    // handle the initial spoken text w/o translation and suchnot
    
    if (llStringLength(justSpeak)) {
        theysaid = "";
    }
    
    string url = "http://www.outworldz.com/cgi/gods-2.plx"
        + "?q=" + llEscapeURL(theysaid)
        + "&s=" + llEscapeURL(justSpeak)
        + "&ID=" + llEscapeURL(llGetKey())
        + "&Name=" +"Nara"
        + "&AvatarName="+ llEscapeURL(talker);
   
 
    DEBUG(url);
    http_request_id += llHTTPRequest(url, [], "");    

}


default
{
    state_entry()
    {

        llMessageLinked(LINK_SET,1,"close","");
        
        string url = "http://www.outworldz.com/pandora/" + file + "?PrimKey=" + llEscapeURL(llGetKey());

        DEBUG(url);
        web_rules = rules + url ;
       
        if (debug) llOwnerSay(url);
        
        page_visible = [
            PRIM_TEXTURE,       // command to set a texture 
            side,                  // on side 1
            ablank,         // the white default texture
            repeats,    // Repeats per face
            offset,  // Texture Offset
           0                  // rotation in radians
        ];

         
               
        picture_image = [
            PRIM_TEXTURE,       // command to set a texture 
            side,                  // on side 1
            no_viewer2,         // the white default texture
            <1,1,0>,            // Repeats per face
            <0,0,0>,            // Texture Offset
            0                  // rotation in radians
        ]; 
            
        llClearPrimMedia(side);
        llSetPrimitiveParams(picture_image);
        llSensorRepeat("","",AGENT,DISTANCE,ARC,RATE);
        llSetPrimMediaParams(side,web_rules);
    }
    
    listen(integer channel, string name, key id, string message )
    {
        DEBUG(message);
        list details =  llGetObjectDetails( id, [OBJECT_CREATOR, OBJECT_POS] );
        key objkey =  llList2Key(details,0);
        if (objkey != NULL_KEY) {
            DEBUG("Was Object- rejected");
            return;
        }
            
            
        float dist = llVecDist( llList2Vector(details,1),llGetPos());
         if ( dist > DISTANCE) {
             DEBUG("too far- rejected");
            return;
        }
         


        send(name,message,"");
      
    }
    
    
    sensor(integer num_detected)
    {   
        if (nobody)
        {
            integer present;
            integer i;
            for (i = 0; i < num_detected; i++)
            {
                DEBUG(llKey2Name(llDetectedKey(i)));
                if (!osIsNpc(llDetectedKey(i)))
                    present++;
            }
            
            if (!present) {
                DEBUG("No avatars");
                return;
            }   
            
            DEBUG("Visible");
        
            llSetPrimitiveParams(page_visible);
            
            string lang = "en";
            string url = "http://www.outworldz.com/pandora/" 
                            + file 
                            + "?PrimKey="    + llEscapeURL(llGetKey()) 
                            + "&Language="   + lang
                            + "&AvatarName=" + llEscapeURL(llDetectedName(0))
                            + "&AvatarKey="  + llEscapeURL(llDetectedKey(0));

            DEBUG(url);
            web_rules = rules + url ;
        
            llSetPrimMediaParams(side,web_rules);

            listener = llListen(0,"","","");
            SitUp();
            send(llDetectedName(0),"","Hello! My name is Nara Malone.   I hope you have "
                + " Shared Media turned on. Click me so we can chat."
                + "I have been on a quest to create better storytelling tools, and interactive experiences for readers."
                +" I've teamed up with writers, artists, musicians and virtual world experts to bring you the best Hyper grid Story yet. This is our third year for this type of project."
                +" Twenty five artisans helped.  This is why events like O S C C, Avatar Fest, and Hyper grid Stories are important. They bring us together to share knowledge and work as teams to come up with wow-factor projects."
);
            
            nobody = FALSE;
        }
    }
    
    no_sensor()
    {
        if (! nobody)
        {
            DEBUG("InVisible");
            llWhisper(0,"Goodbye");
            StopThinking();
            LayDown();

            llClearPrimMedia(side);
            llSetPrimitiveParams(picture_image);
            
            llListenRemove(listener);
        }
        nobody = TRUE;
    } 
 
    http_response(key request_id, integer status, list metadata, string body)
    {
        integer i = llListFindList( http_request_id, [request_id]);
   
        DEBUG("response = " +body);        
        if (i > -1)
        {
            http_request_id =  llDeleteSubList(http_request_id,i,i);
            list params = llParseString2List(body,["|"],[]);
            string r = llList2String(params,1);
            llSay(0,r);
            StopThinking();        }
    }

    timer()
    {          
        llMessageLinked(LINK_SET,1,"typing","");
        if (counter++ > 30)
            LayDown();
    }

    
    on_rez(integer start)
    {
        llResetScript();
    }
    
    changed(integer what)
    {
        if (what & CHANGED_REGION_START)
            llResetScript();
    }
}
    