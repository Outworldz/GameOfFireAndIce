// a script for a HUD or other wearable button to show game progress.

default
{
    touch_start(integer total_number)
    {
        string url = "http://www.outworldz.com/cgi/llgamer2.plx?AvatarKey=" + llDetectedKey(0);
        
        llLoadURL(llDetectedKey(0),"View your game progress",url);
    }
}

