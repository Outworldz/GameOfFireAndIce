string OBJ;

default
{
    state_entry()
    {
        llSensorRepeat(OBJ,"",SCRIPTED|ACTIVE,0.5,PI,10);
    }
    
    no_sensor()
    {
        OBJ = llGetInventoryName(INVENTORY_OBJECT,0);
        llRezObject(OBJ,llGetPos(),<0,0,0>,llGetRot(),0);
    }
}