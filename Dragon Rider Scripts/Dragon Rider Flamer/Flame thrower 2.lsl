default
{
    link_message(integer sender, integer i, string s, key id) 
    {
 
    if(i == 66)
        {
        llParticleSystem([
            PSYS_PART_FLAGS,PSYS_PART_INTERP_COLOR_MASK | PSYS_PART_INTERP_SCALE_MASK | PSYS_PART_EMISSIVE_MASK | PSYS_PART_FOLLOW_SRC_MASK,
            PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_ANGLE_CONE,
            PSYS_PART_START_COLOR, <1,1.0,1.0>,
            PSYS_PART_END_COLOR, <1,1,1.0>,
            PSYS_PART_START_ALPHA, 0.5,
            PSYS_PART_END_ALPHA, 0.1,
            PSYS_PART_START_SCALE, <0.02,0.02,0.50>,
            PSYS_PART_END_SCALE, <1.4,1.4,1.44>,
            PSYS_SRC_ANGLE_BEGIN, 0.0,
            PSYS_SRC_ANGLE_END, 0.0,
            PSYS_SRC_BURST_RATE, 0.01,
            PSYS_SRC_BURST_PART_COUNT, 200000,
            PSYS_SRC_BURST_RADIUS, 0.5,
            PSYS_PART_MAX_AGE, 3.8,
            PSYS_SRC_TEXTURE, "ed75ca05-1bc9-4d1e-ac83-44189188487f",
            PSYS_SRC_BURST_SPEED_MIN, 1.6,
            PSYS_SRC_BURST_SPEED_MAX, 3.2,
            PSYS_SRC_ACCEL, <0,0,0.40>
        ]);
         llSetPrimitiveParams([PRIM_POINT_LIGHT, TRUE, <1.0, 0.8, 0.3>, 1.0, 20.0, 0.5]); 
    
    }
    if(i == 65) {
        llParticleSystem([]);
         llSetPrimitiveParams([PRIM_POINT_LIGHT, FALSE, ZERO_VECTOR, 0.0, 0.0, 0.0]);
}    
}
}
  