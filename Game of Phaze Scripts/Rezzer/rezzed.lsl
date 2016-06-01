integer channel = 3454;
    
default
{
    state_entry() {
        
        // typing "/3454 derez" in chat  will remove this prim
        llListen(channel,"","","derez");

        // Rotates very slowly around a cylinder's local or global Z axis        
        llTargetOmega(llRot2Up(llGetLocalRot()), PI, 1.0);
    }
    on_rez(integer p) {
        llResetScript();
    }            
    listen(integer channel, string name, key id, string message)
    {
        llDie();
    }
}
