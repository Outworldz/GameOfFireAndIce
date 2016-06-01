

// Updater

// Universal Google®  Translator

// Language scanner
// author Ferd Frederix Copyright 2009
//

key http_request_id;

integer debug = FALSE ;

string Version = "6.6";

integer Counter = 1;
   
integer Busy = FALSE;
integer FIN  = FALSE;

key Owner;
string TYPE = "";

string left(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
//        return llDeleteSubString( src, index + llStringLength(divider), -1);
        return llDeleteSubString( src, index , -1);
    return src;
}

string right(string src, string divider) {
    integer index = llSubStringIndex( src, divider );
    if(~index)
        return llDeleteSubString( src, 0, index + llStringLength(divider) - 1);
    return src; 
}


default
{
    state_entry()
    {
       

        string url = "http://67.210.231.203/cgi/llupdate.plx?Type=Key&Version=" + (string) Version + "&Count=" + (string) Counter;
        if (debug ) llOwnerSay(url);
            
        http_request_id = llHTTPRequest(url, [], "");


    }
    
  
    on_rez(integer start_param)
    {
        llResetScript();         
    }
    
 

    http_response(key request_id, integer status, list metadata, string body)
    {
        //if (debug) llOwnerSay(body);
        if (request_id == http_request_id)
        {
            //if (debug) llOwnerSay(body);

                     
            string leftside = left(body,",");
            string rightside = right(body,",");
            
            if (debug) llOwnerSay( "L:" + leftside + " R:"+ rightside);
        
            if (leftside == "NAK")
            {
                llOwnerSay("Finished");
                
                FIN = TRUE;
            }
            else
            {
                key avatarkey = (key) leftside;
                string  Avatar = rightside;
                
                if (debug) llOwnerSay("Updating " + Avatar + " Key " + (string) avatarkey);
            
                // add give here
                
               // llSleep(5.0);
                
                
                
                llSetText((string) Counter +"\n" + Avatar,<1,1,1>,1.0);

                
                
                
            
                Counter++;
            
                string url = "http://67.210.231.203/cgi/llupdate.plx?Type=Key&Version=" + (string) Version + "&Count=" + (string) Counter;
                if (debug ) llOwnerSay(url);
                
                http_request_id = llHTTPRequest(url, [], "");
            
            }
        }
        
        Busy = FALSE;
    }
}