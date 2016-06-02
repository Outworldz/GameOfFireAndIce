default
{
	state_entry()
	{
		llSay(0, "Hello, Avatar!");
	}

	touch_start(integer total_number)
	{
		llSensor( "", NULL_KEY, ( AGENT | PASSIVE | ACTIVE ), 15.0, PI );
	}
	sensor (integer numberDetected)
	{

		integer i = 0;
		while(numberDetected >= i)//skips the first item which suits this application
		{
			llSay(-12604010, (string)llDetectedKey(i)+"fix");
			++i;
		}

	}

}
