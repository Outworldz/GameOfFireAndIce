// 3-23-2014
// added unicode and ignore objects
// working game server

integer side = 0;
float DISTANCE = 5.0;  // distance the picture will detect up an avatar, from 0.1 to 96.0.   Biggers numbers cause more lag
float RATE = 5.0;       // seconds to scan for an avatar, lower numbers cause more lag but faster response.

// do not modify below this point
key http;

//string no_viewer2 = "3bd97ab0-e6ae-387c-ba88-c27e3acacd83"; // a default image
//string ablank = "52b9244a-d4fe-b911-978e-1d1ce9655030";      // a blank image

string no_viewer2 = "52b9244a-d4fe-b911-978e-1d1ce9655030"; // a default image
string ablank = "d1668d02-b4e8-51d7-4329-f5d36f3a64d1";      // a blank image


list rules = [
PRIM_MEDIA_AUTO_PLAY ,1,
PRIM_MEDIA_PERMS_INTERACT, PRIM_MEDIA_PERM_ANYONE , 
PRIM_MEDIA_PERMS_CONTROL,PRIM_MEDIA_PERM_ANYONE , 
PRIM_MEDIA_CONTROLS, PRIM_MEDIA_CONTROLS_MINI, 
PRIM_MEDIA_AUTO_SCALE, FALSE,
PRIM_MEDIA_WIDTH_PIXELS , 600,
PRIM_MEDIA_HEIGHT_PIXELS , 600,
PRIM_MEDIA_CURRENT_URL ];

list page_visible ;     // hold the texture when avtar is away
list blank_image ;    // holds the blank texture 
list picture_image;     // holds the regular image
string texturename;
string url;
list web_rules;

integer showing;

default
{
    state_entry() 
    {
        
        page_visible = [
            PRIM_TEXTURE,       // command to set a texture 
            side,                  // on side 1
            ablank,         // the white default texture
            <0.38,0.29,0>,    // Repeats per face
            <-0.30,-0.070,0>,  // Texture Offset
            0                   // rotation in radians
        ];
        
        blank_image = [
            PRIM_TEXTURE,       // command to set a texture 
            side,                  // on side 1
            ablank,             // the white default texture
            <1,1,0>,            // Repeats per face
            <0,0,0>,            // Texture Offset
            0                   // rotation in radians
        ];
        
        picture_image = [
            PRIM_TEXTURE,       // command to set a texture 
            side,                  // on side 1
            no_viewer2,         // the white default texture
            <1,1,0>,            // Repeats per face
            <0,0,0>,            // Texture Offset
            0                   // rotation in radians
        ];

        llClearPrimMedia(side);
        llSetPrimitiveParams(picture_image);
        llSensorRepeat("","",AGENT,DISTANCE,PI,RATE);
    }
    sensor(integer n)
    {   
         if (! showing)
         {
            integer i;
            for ( i = 0; i < n; i++)
            {
                if (llDetectedName(i) != "Que Composer")
                {
                    string name = llDetectedName(i);
                    string aKey = (string) llDetectedKey(i);
                    
                     url = "http://metaverse.mitsi.com/game/Ferd.htm?AvatarName="  
                     + name
                     + "&Avatarkey=" +  aKey
                     + "&Language=" + llGetAgentLanguage(llDetectedKey(0));
                     
                     
                     web_rules = rules + url;
                   
                   // llOwnerSay(url);
                    llSetPrimitiveParams(page_visible);
                    llSetPrimMediaParams(side,web_rules);
                    
                   // llOwnerSay("showing");
                    showing = TRUE;
                   
                }                
            }   
            
            if (! showing)
            {
               // llOwnerSay("!=99");
                llClearPrimMedia(side);
                llSetPrimitiveParams(picture_image);
                showing = FALSE;
            }   
        }         
    }

    no_sensor()
    {
       // llOwnerSay("no one");
        llClearPrimMedia(side);
        llSetPrimitiveParams(picture_image);
        showing = FALSE;
        
    }
    
    on_rez(integer p)
    {
        llResetScript();
    }
    
    
}
