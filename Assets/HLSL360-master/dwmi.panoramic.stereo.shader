Shader "_dwmi/360/stereo.v1.0" {
    Properties{
        _Back("backdrop", Color) = (0,0,0,1)
        _Tint("tint", Color) = (1,1,1,1)
        _Edge("edge", Range(0,.5)) = 0
        _EdgeBias("edge bias", Range(1, 8)) = 1
        _DegLat("deg latitude", Range(1, 180)) = 180
        _DegLong("deg longitude", Range(0, 360)) = 360

        _DegSpacing("longitude spacing", Range(0, 15)) = 0

        _Rotation("Rotation", Range(0, 360)) = 270
        [Gamma] _Exposure("Exposure", Range(0, 8)) = 1.0
        [Enum(off, 0, on, 1)] _UseHDR("hdr", float) = 0

        // _Dim("dim amount", Range(0, 1)) = 0
        // _Grey("greyscale", Range(0, 1)) = 0

        [Enum(one, 1, two, 2, three, 3, four, 4)] _SplitCount("split count", float) = 1
        [Enum(off, 0, on, 1)] _Stereo("stereoscopic", float) = 0

        [Enum(back, 0, discard, 1)] _RenderOutOfBounds("render out of bounds", Float) = 0

        [NoScaleOffset] _INPUT0("_input0", 2D) = "grey" {}
        [NoScaleOffset] _INPUT1("_input1", 2D) = "grey" {}
        [NoScaleOffset] _INPUT2("_input2", 2D) = "grey" {}
        [NoScaleOffset] _INPUT3("_input3", 2D) = "grey" {}
    }

        SubShader{

            Tags { 
                "Queue"="Geometry-1"
            }

            Cull Front ZWrite Off 
            Blend SrcAlpha OneMinusSrcAlpha

            Pass {

                HLSLPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0

                #include "UnityCG.cginc"
                #include "includes/360.hlsl"

                fixed4 _Back;
                fixed4 _Tint;
                float _Edge;
                float _EdgeBias;

                float _DegLong;
                float _DegLat;
                float _DegSpacing;
                float _SplitCount;
                float _Stereo;

                float _Rotation;
                half _Exposure;

                // float _Dim;
                // float _Grey;

                int _ImageType;
                int _RenderOutOfBounds;

                sampler2D _INPUT0;
                sampler2D _INPUT1;
                sampler2D _INPUT2;
                sampler2D _INPUT3;

                int _UseHDR;
                float4 _INPUT0_HDR;
                float4 _INPUT1_HDR;
                // float4 _INPUT2_HDR;
                // float4 _INPUT3_HDR;

                half4 ProcessHDR (inout half4 color, float4 HDR) {
                    color.rgb = DecodeHDR(color, HDR);
                    return color;
                }

                inline float2 ToRadialCoords(float3 coords)
                {
                    float3 normalizedCoords = normalize(coords);
                    float latitude = acos(normalizedCoords.y);
                    float longitude = atan2(normalizedCoords.z, normalizedCoords.x);
                    float2 sphereCoords = float2(longitude, latitude) * float2(0.5 / UNITY_PI, 1.0 / UNITY_PI);

                    return float2(0.5, 1.0) - sphereCoords;
                }

                float3 RotateAroundYInDegrees(float3 vertex, float degrees)
                {
                    float alpha = degrees * UNITY_PI / 180.0;
                    float sina, cosa;
                    sincos(alpha, sina, cosa);
                    float2x2 m = float2x2(cosa, -sina, sina, cosa);

                    return float3(mul(m, vertex.xz), vertex.y).xzy;
                }

                float4 OutOfBounds() {
                    if (_RenderOutOfBounds == 1) discard;
                    return _Back;
                }

                half4 SampleInput (sampler2D input, float4 hdr, float2 coords) {
                    half4 col = tex2D(input, coords);
                    if (_UseHDR == 1) ProcessHDR(col, hdr);                    
                    return col; 
                }

                struct appdata_t {
                    float4 vertex : POSITION;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct v2f {
                    float4 vertex : SV_POSITION;
                    float3 texcoord : TEXCOORD0;
                    float4 stereolayout : TEXCOORD1;
                    UNITY_VERTEX_OUTPUT_STEREO
                };


                v2f vert(appdata_t v)
                {
                    v2f o;

                    float3 rotated = RotateAroundYInDegrees(v.vertex, _Rotation);
                    o.vertex = UnityObjectToClipPos(rotated);
                    o.texcoord = v.vertex.xyz;
                    o.stereolayout = float4(0, 0, 1, 1);
                    if (_Stereo == 1) o.stereolayout = float4(0, 1-unity_StereoEyeIndex, 1, 0.5); 

                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    float2 tc = ToRadialCoords(i.texcoord);

                    float shift = (_DegLong * 0.5) / 360;
                    tc.x = fmod(tc.x + shift, 1) * (360 / _DegLong);

                    if (tc.x > 1) return OutOfBounds();

                    float3 arrcoords = CoordsDegSimple(tc, _DegLat, _SplitCount, _DegSpacing);
                    arrcoords.xy = (arrcoords.xy + i.stereolayout.xy) * i.stereolayout.zw;

                    if (arrcoords.z == -1) return OutOfBounds();

                    if (arrcoords.z == 0) _Back = SampleInput(_INPUT0, _INPUT0_HDR, arrcoords.xy);
                    else if (arrcoords.z == 1) _Back = SampleInput(_INPUT1, _INPUT1_HDR, arrcoords.xy);
                    else if (arrcoords.z == 2) _Back = tex2D(_INPUT2, arrcoords.xy);
                    else if (arrcoords.z == 3) _Back = tex2D(_INPUT3, arrcoords.xy);

                    float alphablend = clamp((1 - abs((arrcoords.y - 0.5) * 2)) / _Edge, 0, 1);
                    _Back.a *= alphablend;
                    _Back.a = pow(_Back.a, _EdgeBias);
                    _Back.rgb *= _Exposure;


                    // fixed3 grey = Luminance(_Back) * _Dim;
                    // _Back.rgb = lerp(_Back.rgb, grey, _Grey);
                    _Back.a = 1;
                    return _Back * _Tint;
                }

                ENDHLSL
            }
    }

        Fallback Off
}