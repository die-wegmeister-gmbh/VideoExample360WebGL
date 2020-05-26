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

#endif