#version 150

struct Globals
{
    mat4 ViewProjection;
    vec4 ViewRight;
    vec4 ViewUp;
    vec4 ViewDir;
    vec3 CameraPosition;
    vec3 AmbientColor;
    vec3 SkyAmbient;
    vec3 Lamp0Color;
    vec3 Lamp0Dir;
    vec3 Lamp1Color;
    vec4 FogParams;
    vec4 FogColor_GlobalForceFieldTime;
    vec3 Exposure;
    vec4 LightConfig0;
    vec4 LightConfig1;
    vec4 LightConfig2;
    vec4 LightConfig3;
    vec4 ShadowMatrix0;
    vec4 ShadowMatrix1;
    vec4 ShadowMatrix2;
    vec4 RefractionBias_FadeDistance_GlowFactor_SpecMul;
    vec4 OutlineBrightness_ShadowInfo;
    vec4 SkyGradientTop_EnvDiffuse;
    vec4 SkyGradientBottom_EnvSpec;
    vec3 AmbientColorNoIBL;
    vec3 SkyAmbientNoIBL;
    vec4 AmbientCube[12];
    vec4 CascadeSphere0;
    vec4 CascadeSphere1;
    vec4 CascadeSphere2;
    vec4 CascadeSphere3;
    float hybridLerpDist;
    float hybridLerpSlope;
    float evsmPosExp;
    float evsmNegExp;
    float globalShadow;
    float shadowBias;
    float shadowAlphaRef;
    float debugFlagsShadows;
};

uniform vec4 CB0[47];
in vec4 POSITION;
in vec4 NORMAL;
in vec2 TEXCOORD0;
in vec2 TEXCOORD1;
in vec4 COLOR0;
in vec4 COLOR1;
in vec4 TEXCOORD2;
in vec4 TEXCOORD3;
out vec4 VARYING0;
out vec4 VARYING1;
out vec4 VARYING2;
out vec3 VARYING3;
out vec4 VARYING4;
out vec4 VARYING5;
out vec4 VARYING6;
out vec4 VARYING7;
out float VARYING8;

void main()
{
    vec3 v0 = (NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0);
    vec3 v1 = (TEXCOORD2.xyz * 0.0078740157186985015869140625) - vec3(1.0);
    vec4 v2 = vec4(0.0);
    v2.w = (TEXCOORD2.w * 0.0078740157186985015869140625) - 1.0;
    vec4 v3 = vec4(POSITION.xyz, 1.0);
    vec4 v4 = v3 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    float v5 = v4.w;
    vec4 v6 = ((exp2(TEXCOORD3 * 0.0625) - vec4(1.0)) * CB0[23].z) + vec4((0.5 * v5) * CB0[23].y);
    vec4 v7 = vec4(dot(CB0[20], v3), dot(CB0[21], v3), dot(CB0[22], v3), 0.0);
    v7.w = COLOR1.w * 0.0039215688593685626983642578125;
    vec4 v8 = vec4(v0, 0.0);
    v8.w = 0.0;
    gl_Position = v4;
    VARYING0 = vec4(TEXCOORD0.x, TEXCOORD0.y, v6.x, v6.y);
    VARYING1 = vec4(TEXCOORD1.x, TEXCOORD1.y, v6.z, v6.w);
    VARYING2 = COLOR0;
    VARYING3 = ((POSITION.xyz + (v0 * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    VARYING4 = vec4(CB0[7].xyz - POSITION.xyz, v5);
    VARYING5 = v8;
    VARYING6 = vec4(v1.x, v1.y, v1.z, v2.w);
    VARYING7 = v7;
    VARYING8 = NORMAL.w;
}
