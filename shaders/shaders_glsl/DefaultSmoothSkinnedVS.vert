#version 110

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
attribute vec4 POSITION;
attribute vec4 NORMAL;
attribute vec2 TEXCOORD0;
attribute vec2 TEXCOORD1;
attribute vec4 COLOR0;
attribute vec4 COLOR1;
attribute vec4 TEXCOORD4;
attribute vec4 TEXCOORD5;
varying vec2 VARYING0;
varying vec2 VARYING1;
varying vec4 VARYING2;
varying vec3 VARYING3;
varying vec4 VARYING4;
varying vec4 VARYING5;
varying vec4 VARYING6;
varying float VARYING7;

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
    vec3 v17 = vec3(dot(v10.xyz, v0), dot(v11.xyz, v0), dot(v12.xyz, v0));
    vec3 v18 = -CB0[11].xyz;
    float v19 = dot(v17, v18);
    vec3 v20 = CB0[7].xyz - v16;
    vec4 v21 = vec4(v13, v14, v15, 1.0);
    vec4 v22 = v21 * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    float v23 = COLOR1.y * 0.50359570980072021484375;
    float v24 = clamp(v19, 0.0, 1.0);
    vec3 v25 = (CB0[10].xyz * v24) + (CB0[12].xyz * clamp(-v19, 0.0, 1.0));
    vec4 v26 = vec4(v25.x, v25.y, v25.z, vec4(0.0).w);
    v26.w = (v24 * CB0[23].w) * (COLOR1.y * exp2((v23 * dot(v17, normalize(v18 + normalize(v20)))) - v23));
    vec4 v27 = vec4(dot(CB0[20], v21), dot(CB0[21], v21), dot(CB0[22], v21), 0.0);
    v27.w = COLOR1.z * 0.0039215688593685626983642578125;
    gl_Position = v22;
    VARYING0 = TEXCOORD0;
    VARYING1 = TEXCOORD1;
    VARYING2 = COLOR0;
    VARYING3 = ((v16 + (v17 * 6.0)).yxz * CB0[16].xyz) + CB0[17].xyz;
    VARYING4 = vec4(v20, v22.w);
    VARYING5 = v26;
    VARYING6 = v27;
    VARYING7 = NORMAL.w;
}

