//Vega Plutonians break script, complete with damage smoke, configure ability, command driven healing
float maxhealth = 750;
float health;
string text;
string bullet;
string melee;
string ground;
string other;
// Particle Script 0.5
// Created by Ama Omega
// 3-26-2004
string turret="gunner2";
integer keystate = 0 ;

// Mask Flags - set to TRUE to enable
integer glow = FALSE;            // Make the particles glow
integer bounce = FALSE;          // Make particles bounce on Z plane of object
integer interpColor = TRUE;     // Go from start to end color
integer interpSize = TRUE;      // Go from start to end size
integer wind = TRUE;           // Particles effected by wind
integer followSource = FALSE;    // Particles follow the source
integer followVel = FALSE;       // Particles turn to velocity direction

// Choose a pattern from the following:
// PSYS_SRC_PATTERN_EXPLODE
// PSYS_SRC_PATTERN_DROP
// PSYS_SRC_PATTERN_ANGLE_CONE_EMPTY
// PSYS_SRC_PATTERN_ANGLE_CONE
// PSYS_SRC_PATTERN_ANGLE
integer pattern = PSYS_SRC_PATTERN_EXPLODE;

// Select a target for particles to go towards
// "" for no target, "owner" will follow object owner
//    and "self" will target this object
//    or put the key of an object for particles to go to
key target = "";

// Particle paramaters
float age = 7.5;                  // Life of each particle
float maxSpeed = 0.55;            // Max speed each particle is spit out at
float minSpeed = 0.51;            // Min speed each particle is spit out at
string texture = "8db6b463-36ce-4585-9c86-6609f2616960";                 // Texture used for particles, default used if blank
float startAlpha = 0.8;           // Start alpha (transparency) value
float endAlpha = 0.0;           // End alpha (transparency) value
vector startColor = <0.5,0.5,0.5>;    // Start color of particles <R,G,B>
vector endColor = <0,0,0>;      // End color of particles <R,G,B> (if interpColor == TRUE)
vector startSize = <1.01,1.01,0.0>;     // Start size of particles
vector endSize = <2.1,2.1,1>;       // End size of particles (if interpSize == TRUE)
vector push = <.1,0,1.1>;          // Force pushed on particles

// System paramaters
float rate = 0.1;            // How fast (rate) to emit particles
float radius = 0.0;          // Radius to emit particles for BURST pattern
integer count = 5;        // How many particles to emit per BURST
float outerAngle = 0;    // Outer angle for all ANGLE patterns
float innerAngle = 0.05;    // Inner angle for all ANGLE patterns
vector omega = <0,0,0>;    // Rotation of ANGLE patterns around the source
float life = 0;             // Life in seconds for the system to make particles

// Script variables
integer flags;
get_data()
{
	QueryId = llGetNotecardLine(FILENAME,line);
	line+=1;
}
updateParticles()
{
	list sys;
	flags = 0;
	if (target == "owner") target = llGetOwner();
	if (target == "self") target = llGetKey();
	if (glow) flags = flags | PSYS_PART_EMISSIVE_MASK;
	if (bounce) flags = flags | PSYS_PART_BOUNCE_MASK;
	if (interpColor) flags = flags | PSYS_PART_INTERP_COLOR_MASK;
	if (interpSize) flags = flags | PSYS_PART_INTERP_SCALE_MASK;
	if (wind) flags = flags | PSYS_PART_WIND_MASK;
	if (followSource) flags = flags | PSYS_PART_FOLLOW_SRC_MASK;
	if (followVel) flags = flags | PSYS_PART_FOLLOW_VELOCITY_MASK;
	if (target != "") flags = flags | PSYS_PART_TARGET_POS_MASK;
	sys = [  PSYS_PART_MAX_AGE,age,
		PSYS_PART_FLAGS,flags,
		PSYS_PART_START_COLOR, startColor,
		PSYS_PART_END_COLOR, endColor,
		PSYS_PART_START_SCALE,startSize,
		PSYS_PART_END_SCALE,endSize,
		PSYS_SRC_PATTERN, pattern,
		PSYS_SRC_BURST_RATE,rate,
		PSYS_SRC_ACCEL, push,
		PSYS_SRC_BURST_PART_COUNT,count,
		PSYS_SRC_BURST_RADIUS,radius,
		PSYS_SRC_BURST_SPEED_MIN,minSpeed,
		PSYS_SRC_BURST_SPEED_MAX,maxSpeed,
		PSYS_SRC_TARGET_KEY,target,
		PSYS_SRC_INNERANGLE,innerAngle,
		PSYS_SRC_OUTERANGLE,outerAngle,
		PSYS_SRC_OMEGA, omega,
		PSYS_SRC_MAX_AGE, life,
		PSYS_SRC_TEXTURE, texture,
		PSYS_PART_START_ALPHA, startAlpha,
		PSYS_PART_END_ALPHA, endAlpha
			];

	llParticleSystem(sys);
}
checkhealth()
{if(health<=0)
	{
		//age = 1;
		//life = 5;
		//startSize = <4,4,4>;
		//llTriggerSound("swordhit", 1);
		//updateParticles();
		llMessageLinked(LINK_ALL_OTHERS,1,"A","A");
		//llRezObject(llGetInventoryName(INVENTORY_OBJECT,0),llGetPos() ,<llFrand(6) - 3,llFrand(6) - 3,5>,llGetRot(),1);
		llMessageLinked(LINK_SET,0,"Dead","");
		//llDie();
	}

		else if(health<maxhealth*.10)
		{
			rate=0.1;
			count=5;
		}
		else if(health<maxhealth*.20)
		{
			rate=0.2;
			count=4;
		}
		else if(health<maxhealth*.30)
		{
			rate=0.3;
			count=3;
		}
		else if(health<maxhealth*.40)
		{
			rate=0.4;
			count=2;
		}
		else if(health<maxhealth*.50)
		{
			rate=0.5;
			count=1;
		}
		if(health<maxhealth*.5)
			updateParticles() ;
	}



key QueryId;
integer line;
string FILENAME="Configure";
float time;
default
{
	state_entry()
	{
		line=0;
		get_data();
	}
	dataserver(key Ide, string data1)
	{
		if(Ide == QueryId)
		{
			if(data1 != EOF)
			{
				list tp=llParseString2List(data1,["="],[]);
				string test = llList2String(tp,0);
				if(test=="health")
					maxhealth=(integer)llList2String(tp,1);
				else if(test=="text")
					text=llList2String(tp,1);
				else if(test=="bullet")
					bullet=llList2String(tp,1);
				else if(test=="melee")
					melee=llList2String(tp,1);
				else if(test=="ground")
					ground=llList2String(tp,1);
				else if(test=="other")
					other=llList2String(tp,1);
				get_data();
			}
			else
			{
				//llOwnerSay((string)maxhealth+" "+text+" "+bullet+" "+melee+" "+ground+" "+other);
				state running;
			}
		}
	}
}
state running
{
	state_entry()
	{
		llParticleSystem([]);
		llSetTimerEvent(1);
		llSetStatus(STATUS_DIE_AT_EDGE,TRUE);
		llListen(-12604010,"","",(string)llGetKey()+"fix");
		llListen(-80249,"","","");
		health= maxhealth;
		time=llGetTime()+2.0;

	}
	timer()
	{
		if (llToUpper(text)=="ON")
			llSetText((string)((integer)health) + " Health",<1,1,1>,1);
		else
			llSetText("",<1,1,1>,1);

	}
	collision_start(integer times)
	{
		if (llToUpper(bullet)=="ON")
		{
			integer i;
			for (i=0;i<times;i++)
			{
				//age = .5;
				//life = .2;
				//startSize = <.1,.1,.1>;
				//updateParticles();
				if ((llVecMag (llDetectedVel(i)) > 40.0&&llGetTime()>time))
				{
					float damage = llVecMag(llDetectedVel(0))+llVecMag(llGetVel());
					health-=15;
					time=llGetTime()+2.0;
				}
			}
		}
		checkhealth();
	}
	land_collision_start(vector where)
	{
		if (llToUpper(ground)=="ON")
		{
			//age = .5;
			//life = .2;
			//startSize = <.1,.1,.1>;
			//updateParticles();

			integer randSound = (integer)llFrand(2.99);
			float damage = llVecMag(llGetVel());
			health = health - damage;
		}
		checkhealth();
	}
	listen(integer channel,string namea, key id, string message)
	{
		if( message == (string)llGetKey()+"fix")
		{
			llSay(0, namea + " Fixed " + llKey2Name(llGetOwner())+"'s "+ llGetObjectName());
			health= maxhealth;
		}
		if (channel == -80249&&llGetTime()>time)
		{
			list i;
			string name =llGetObjectName();
			llParseString2List(message, [" "], []);


			if ( llSubStringIndex( message, "plAyEr "+ name) != -1)
			{
				if (llToUpper(melee)=="ON"){

					integer strlength = llStringLength(name) + 6;
					message = llDeleteSubString(message,0,strlength);

					i = llParseString2List(message, [" "], []);
					float damage = (float)llList2String(i, 1);
					health = health - damage;
					checkhealth();
				}


			}



		}

	}
}

