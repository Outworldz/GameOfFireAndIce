default
{
    link_message(integer sender, integer i, string s, key id) 
    {
 
    if(i == 66)
        {
        llParticleSystem([
            PSYS_PART_FLAGS,PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK | PSYS_PART_FOLLOW_SRC_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
            PSYS_PART_START_COLOR, <1,1,1.0>,
            PSYS_PART_END_COLOR, <1,1,1.0>,
            PSYS_PART_START_ALPHA, 0.5,
            PSYS_PART_END_ALPHA, 0.1,
            PSYS_PART_START_SCALE, <0.50,0.50,0.50>,
            PSYS_PART_END_SCALE, <1.4,1.4,1.44>,
            PSYS_SRC_ANGLE_BEGIN, 0.0,
            PSYS_SRC_ANGLE_END, 0.0,
            PSYS_SRC_BURST_RATE, 0.01,
            PSYS_SRC_BURST_PART_COUNT, 200000,
            PSYS_SRC_BURST_RADIUS, 0.5,
            PSYS_PART_MAX_AGE, 1.8,
            PSYS_SRC_TEXTURE, "dcab6cc4-172f-e30d-b1d0-f558446f20d4",
            PSYS_SRC_BURST_SPEED_MIN, 1.6,
            PSYS_SRC_BURST_SPEED_MAX, 2.2,
            PSYS_SRC_ACCEL, <0,0,0.40>
        ]);     
    }
    if(i == 65) {
        llParticleSystem([]);   
}    
}}
