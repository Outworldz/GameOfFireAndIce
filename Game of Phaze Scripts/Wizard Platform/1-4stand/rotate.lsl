default
{
    state_entry()
    {
       llSetTextureAnim(ANIM_ON | SMOOTH | ROTATE | LOOP, 0,1,1,0, TWO_PI, 0.5);
    }

    on_rez(integer p)
    {
        llResetScript();
        
    }
}
