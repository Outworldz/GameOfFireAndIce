// :CATEGORY:Painting
// :NAME:Animated-Paintings
// :AUTHOR:Ferd Frederix
// :CREATED:2013-10-14 12:00:16
// :EDITED:2013-10-14 12:00:16
// :ID:1000
// :NUM:1537
// :REV:1
// :WORLD:Second Life
// :DESCRIPTION:
// Aquarium in a cylinder
// :CODE:
// :License:  Creative Commons CC-BY
// :Author: Ferd Frederix
// :Description:
// Shared media moving paintings
// :Code:

 
integer debug = FALSE;

// Makes a box <2.8, 1.8, 0.10>
// tapers the  x and y = 0.1
// required shared media aka Media on a Prim (MOAP)
// http://www.outworldz.com/game/justin.htm?Language=&Name=Justin%20the%20wise&AvatarKey=6f285c43-e656-42d9-b0e9-a78684fee15c&AvatarName=Ferd%20Frederix&PrimKey=testkey

string url = "http://www.outworldz.com/game/Tara.htm?";

key lastAvikey;
integer vis; // TRUE if visibole

float DISTANCE = 15.0;  // distance the picture will detect up an avatar, from 0.1 to 96.0.   Biggers numbers cause more lag
float RATE = 5.0;       // seconds to scan for an avatar, lower numbers cause more lag but faster response.

// do not modify below this point
string no_viewer2 = "Game Status"; // a V2 needed image
integer side = 1;
string ablank = "Game Status";      // a blank image
 
list page_visible ;     // hold the texture when avtar is away
list picture_image;     // holds the regular image
list web_rules;
string lastname; 
string newurl  ;

doit() {
    list rules = [
PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI, 
PRIM_MEDIA_HOME_URL,newurl,
PRIM_MEDIA_AUTO_PLAY ,TRUE,
PRIM_MEDIA_AUTO_LOOP, FALSE,
PRIM_MEDIA_AUTO_SCALE, FALSE,
PRIM_MEDIA_AUTO_ZOOM, TRUE,
PRIM_MEDIA_WIDTH_PIXELS , 500,
PRIM_MEDIA_HEIGHT_PIXELS , 300,
PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_ANYONE , 
PRIM_MEDIA_PERMS_CONTROL,PRIM_MEDIA_PERM_ANYONE , 
PRIM_MEDIA_CURRENT_URL ];


        lastname = llDetectedName(0);
        if (debug) llOwnerSay(lastname + " sensed");
        
        //llInstantMessage( llDetectedKey(0),"Enable Shared media.  Click the screen. ");
        newurl  = url + "Language=" + llEscapeURL(llGetAgentLanguage(llDetectedKey(0)))
                +"&Name=" + llEscapeURL(llGetObjectName())
                +"&AvatarKey=" + llEscapeURL((string) llDetectedKey(0))
                +"&AvatarName=" + llEscapeURL(llDetectedName(0)) 
                +"&PrimKey=" + llEscapeURL((string) llGetKey())
                +"&_=" + llEscapeURL((string) llFrand(1));

        if (debug) llOwnerSay(newurl);
        llSetPrimitiveParams([ PRIM_FULLBRIGHT,side, TRUE]);
        llSetPrimitiveParams(page_visible);
        
         web_rules = rules + newurl;
        llSetPrimMediaParams(side,web_rules);
        
       // llOwnerSay(llDumpList2String(web_rules,","));
        vis ++;
        lastAvikey = llDetectedKey(0); 
     
}  
  
default
{
    state_entry() 
    {
        //make boxed picture frame and set it to glow.
       llSetPrimitiveParams([ PRIM_FULLBRIGHT,side, FALSE]);
      // llSetScale(<1.5, 1.5, 2>);
      // llSetPrimitiveParams([ PRIM_TYPE,PRIM_TYPE_CYLINDER,0, <0,1,0>, 0, <0,0,0>, <0.950,0.950,0>, <0,0,0>]);
//
       
        page_visible = [
            PRIM_TEXTURE,       // command to set a texture 
            side,                  // on side 1
            ablank,         // the white default texture
            <0.777,0.57,0>,    // Repeats per face
            <-0.1,-0.2,0>,  // Texture Offset
            0                   // rotation in radians
        ];
        
          picture_image = [
            PRIM_TEXTURE,       // command to set a texture 
            side,                  // on side 1
            ablank,         // the white default texture
            <1,1,0>,            // Repeats per face
            <0,0,0>,            // Texture Offset
            0                   // rotation in radians
        ];

        llClearPrimMedia(ALL_SIDES);
        llSetPrimitiveParams(picture_image);
        llSensorRepeat("","",AGENT,DISTANCE,PI,RATE);
    }
    
    touch_start(integer n)
    {
        llSay(0,"Reset");
        vis = TRUE;
        doit();
    }
     
    sensor(integer nh)
    {           
        if (!vis++) {
            
            doit();
        }
    } 
   
    no_sensor()
    {
        if (vis) {   
            if (debug) llOwnerSay(lastname + "left");
            llClearPrimMedia(side);
            llSetPrimitiveParams(picture_image);
           lastAvikey =NULL_KEY;
        }
        vis = 0;
    }
    
    on_rez(integer p)
    {
        llResetScript();
    }
    

}
