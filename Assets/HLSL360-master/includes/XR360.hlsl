#ifndef XR360_HLSL
#define XR360_HLSL

float2 RadialCoords (float3 pos_coords) 
{
    float3 n_coords = normalize(pos_coords);
    float latitude = acos(n_coords.y);
    float longitude = atan2(n_coords.z, n_coords.x);
    float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
    float2 coords = float2(0.5, 1.0) - sphereCoords;

    return coords;
}

float3 ToSplitCoords (float2 coords)
{
    bool split = coords.x*2 >=1;
    coords.x = fmod(coords.x*2, 1);

    float3 split_coords = float3(coords, !split ? 0 : 1);
    return split_coords;
}

float3 SplitRadialCoords (float3 pos_coords) 
{
    float3 n_coords = normalize(pos_coords);
    float latitude = acos(n_coords.y);
    float longitude = atan2(n_coords.z, n_coords.x);
    float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);
    float2 coords = float2(0.5, 1.0) - sphereCoords;

    bool split = coords.x*2 >=1;
    coords.x = fmod(coords.x*2, 1);

    float3 ocoords = float3(coords, !split ? 0 : 1);
    return ocoords;
}

float3 ArrayCoords (float2 radialcoords, int segments) {
    // split coords on x axis 
    float3 arraycoords = float3(radialcoords, 0);
    arraycoords.x = fmod(radialcoords.x * segments, 1);
    arraycoords.z = floor(radialcoords.x * segments);
    // arraycoords.xy => coords;
    // arraycoords.z => tex id;
    return arraycoords;
}

float3 Coords62 (float2 radialcoords) {
    // split coords on x axis 
    int segments = 6;
    float3 arraycoords = float3(radialcoords, 0);
    
    if (arraycoords.y < 0.1) {
        arraycoords.z = 7;
        arraycoords.y *= 10;
        return arraycoords;
    }

    if(arraycoords.y > 0.9) {
        arraycoords.z = 6;
        arraycoords.y = (arraycoords.y - 0.9) * 10;
        return arraycoords;
    }

    arraycoords.x = fmod(radialcoords.x * segments, 1);
    arraycoords.z = floor(radialcoords.x * segments);
    arraycoords.y = (arraycoords.y - 0.1) * 1.25;

    // arraycoords.xy => coords;
    // arraycoords.z => tex id;
    return arraycoords;
}

float3 CoordsMatrix (float2 coords, int count_x, int count_y) {
    float3 matrixcoords = float3(coords, 0);
    float x = coords.x * count_x;
    float y = coords.y * count_y;
    int z = (floor(y) * count_x) + floor(x);

    matrixcoords.x = fmod(x, 1);
    matrixcoords.y = fmod(y, 1);
    matrixcoords.z = z;

    return matrixcoords;
}

//------------------------------------------------------------------------//
float3 CoordsDeg (float2 coords, float high, float low) {
    float3 matrixcoords = float3(coords, 0);

    float y = matrixcoords.y;
    matrixcoords.y = matrixcoords.y * (high+low+1) - low;

    if(matrixcoords.y < 0 || matrixcoords.y > 1) matrixcoords.z = -1; // label out of bounds data

    return matrixcoords;
}
//------------------------------------------------------------------------//

//------------------------------------------------------------------------//
float3 CoordsDegSimple (float2 coords, float deg, int count_x, float spacing) {
    float3 matrixcoords = float3(coords, 0);
    // coords.x *= (180 + spacing) / 180;

    float x = coords.x * count_x;
    matrixcoords.x = fmod(x, 1);
    matrixcoords.x *= (180 + spacing) / 180;

    matrixcoords.z = floor(x);
    if(matrixcoords.x > 1) matrixcoords.z = -1;

    float ydeg = (matrixcoords.y) * (180/deg) - (((180 - deg)/2)/deg);
    // float ydeg = (matrixcoords.y) * 3 - 1;
    matrixcoords.y = ydeg; 

    if(matrixcoords.y < 0 || matrixcoords.y > 1) matrixcoords.z = -1; // label out of bounds data

    return matrixcoords;
}
//------------------------------------------------------------------------//


half4 ProcessHDR (inout half4 color, float4 HDR) 
{
    color.rgb = DecodeHDR(color, HDR);
    return color;
}

half4 SampleSplitSource (
    float3      splitcoords, 
    sampler2D   _in_0, 
    float4      _in_0_HDR, 
    sampler2D   _in_1, 
    float4      _in_1_HDR ) 
{
    half4 output = half4(1, 0, 0.25, 1); // base debug output
    switch (floor(splitcoords.z)) {
        case 0: 
            output = tex2D(_in_0, splitcoords.xy); 
            ProcessHDR(output, _in_0_HDR);
            break;
        case 1: 
            output = tex2D(_in_1, splitcoords.xy);
            ProcessHDR(output, _in_1_HDR);
            break;
    }
    return output;
}

half4 SampleSplitSource (
    float3      splitcoords, 
    sampler2D   _in_0, 
    sampler2D   _in_1 ) 
{
    half4 output = half4(1, 0, 0.25, 1);
    switch (floor(splitcoords.z)) {
        case 0: 
            output = tex2D(_in_0, splitcoords.xy); 
            break;
        case 1: 
            output = tex2D(_in_1, splitcoords.xy);
            break;
    }
    return output;
}

half4 SampleSingleBlended (sampler2D _in0, sampler2D _in1, float _blend, float3 coord) {
    half4 frameBuffer_out;
    half4 frameBuffer_one;
    half4 frameBuffer_two;
    if(_blend > 0 && _blend < 1) {
        frameBuffer_one = tex2D(_in0, coord.xy);
        frameBuffer_two = tex2D(_in1, coord.xy);
        frameBuffer_out = lerp(frameBuffer_one, frameBuffer_two, _blend);
    } 
    else {
        if(_blend == 0)
            frameBuffer_out = tex2D(_in0, coord.xy);
        else
            frameBuffer_out = tex2D(_in1, coord.xy);
    }
    return frameBuffer_out;
}



struct appdata_pos 
{
    float4 vertex : POSITION;
};

struct frag_in 
{
    float4 vertex : POSITION;
    float3 texcoord : TEXCOORD0;
};

frag_in base (appdata_pos i) 
{
    frag_in o;
    o.vertex = UnityObjectToClipPos(i.vertex);
    o.texcoord = i.vertex.xyz;
    return o;
}

half4 xr360output (frag_in i) : COLOR
{
    half4 output = half4(1, 0, 0.25, 1);
    return output;
}


#endif