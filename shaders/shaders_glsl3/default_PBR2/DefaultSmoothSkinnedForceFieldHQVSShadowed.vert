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
    float debugFlags;
};

uniform vec4 CB0[47];
uniform vec4 CB1[216];
in vec4 POSITION;
in vec4 NORMAL;
in vec2 TEXCOORD0;
in vec2 TEXCOORD1;
in vec4 COLOR0;
in vec4 COLOR1;
in vec4 TEXCOORD4;
in vec4 TEXCOORD5;
in vec4 TEXCOORD3;
out vec4 VARYING0;
out vec4 VARYING1;
out vec4 VARYING2;
out vec3 VARYING3;
out vec4 VARYING4;
out vec4 VARYING5;
out vec4 VARYING6;
out float VARYING7;

void main()
{
    vec3 v0 = (NORMAL.xyz * 0.0078740157186985015869140625) - vec3(1.0);
    vec4 v1 = TEXCOORD5 * vec4(0.0039215688593685626983642578125);
    int v2 = int(TEXCOORD4.x) * 3;
    float v3 = v1.x;
    int v4 = int(TEXCOORD4.y) * 3;
    float v5 = v1.y;
    int v6 = int(TEXCOORD4.z) * 3;
    float v7 = v1.z;
    int v8 = int(TEXCOORD4.w) * 3;
    float v9 = v1.w;
    vec4 v10 = (((CB1[v2 * 1 + 0] * v3) + (CB1[v4 * 1 + 0] * v5)) + (CB1[v6 * 1 + 0] * v7)) + (CB1[v8 * 1 + 0] * v9);
    vec4 v11 = (((CB1[(v2 + 1) * 1 + 0] * v3) + (CB1[(v4 + 1) * 1 + 0] * v5)) + (CB1[(v6 + 1) * 1 + 0] * v7)) + (CB1[(v8 + 1) * 1 + 0] * v9);
    vec4 v12 = (((CB1[(v2 + 2) * 1 + 0] * v3) + (CB1[(v4 + 2) * 1 + 0] * v5)) + (CB1[(v6 + 2) * 1 + 0] * v7)) + (CB1[(v8 + 2) * 1 + 0] * v9);
    float v13 = dot(v10, POSITION);
    float v14 = dot(v11, POSITION);
    float v15 = dot(v12, POSITION);
    vec3 v16 = vec3(v13, v14, v15);
    float v17 = dot(v10.xyz, v0);
    float v18 = dot(v11.xyz, v0);
    float v19 = dot(v12.xyz, v0);
    vec4 v20 = vec4(v13, v14, v15, 1.0) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 v21 = vec4(TEXCOORD1.x, TEXCOORD1.y, vec4(0.0).z, vec4(0.0).w);
    v21.x = max(0.0500000007450580596923828125, TEXCOORD1.x);
    float v22 = v20.w;
    vec4 v23 = ((exp2(TEXCOORD3 * 0.0625) - vec4(1.0)) * CB0[23].z) + vec4((0.5 * v22) * CB0[23].y);
    vec4 v24 = vec4(v13, v14, v15, 0.0);
    v24.w = COLOR1.z * 0.0039215688593685626983642578125;
    vec4 v25 = vec4(v17, v18, v19, 0.0);
    v25.w = inversesqrt(0.1745329201221466064453125 * COLOR1.y);
    gl_Position = v20;
    VARYING0 = vec4(TEXCOORD0.x, TEXCOORD0.y, v23.x, v23.y);
    VARYING1 = vec4(v21.x, v21.y, v23.z, v23.w);
    VARYING2 = COLOR0;
    VARYING3 = ((v16 + (vec3(v17, v18, v19) * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    VARYING4 = vec4(CB0[7].xyz - v16, v22);
    VARYING5 = v25;
    VARYING6 = v24;
    VARYING7 = NORMAL.w;
}

