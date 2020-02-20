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

uniform vec4 CB1[216];
uniform vec4 CB0[47];
in vec4 POSITION;
in vec2 TEXCOORD0;
in vec4 COLOR0;
in vec4 TEXCOORD1;
in vec4 TEXCOORD2;
out vec3 VARYING0;
out vec2 VARYING1;

void main()
{
    vec4 v0 = TEXCOORD2 * vec4(0.0039215688593685626983642578125);
    int v1 = int(TEXCOORD1.x * 3.0);
    float v2 = v0.x;
    int v3 = int(TEXCOORD1.y * 3.0);
    float v4 = v0.y;
    int v5 = int(TEXCOORD1.z * 3.0);
    float v6 = v0.z;
    int v7 = int(TEXCOORD1.w * 3.0);
    float v8 = v0.w;
    vec4 v9 = vec4(dot((((CB1[v1 * 1 + 0] * v2) + (CB1[v3 * 1 + 0] * v4)) + (CB1[v5 * 1 + 0] * v6)) + (CB1[v7 * 1 + 0] * v8), POSITION), dot((((CB1[(v1 + 1) * 1 + 0] * v2) + (CB1[(v3 + 1) * 1 + 0] * v4)) + (CB1[(v5 + 1) * 1 + 0] * v6)) + (CB1[(v7 + 1) * 1 + 0] * v8), POSITION), dot((((CB1[(v1 + 2) * 1 + 0] * v2) + (CB1[(v3 + 2) * 1 + 0] * v4)) + (CB1[(v5 + 2) * 1 + 0] * v6)) + (CB1[(v7 + 2) * 1 + 0] * v8), POSITION), 1.0) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 v10 = v9;
    v10.z = 0.5;
    vec3 v11 = vec3(TEXCOORD0.x, TEXCOORD0.y, vec3(0.0).z);
    v11.z = COLOR0.w * 0.0039215688593685626983642578125;
    gl_Position = v10;
    VARYING0 = v11;
    VARYING1 = vec2(v9.zw);
}

