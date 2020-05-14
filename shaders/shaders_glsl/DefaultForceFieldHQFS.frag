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
    vec4 Exposure_DoFDistance;
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
uniform sampler2D DiffuseMapTexture;

varying vec2 VARYING0;
varying vec2 VARYING1;
varying vec4 VARYING2;
varying vec4 VARYING4;
varying vec4 VARYING5;

void main()
{
    float f0 = length(VARYING4.xyz);
    vec4 f1 = texture2D(DiffuseMapTexture, VARYING0);
    float f2 = f1.x;
    float f3 = (f2 > 0.0) ? ((1.0 - clamp(abs(f2 - CB0[14].w) * 13.0, 0.0, 1.0)) * f1.w) : 0.0;
    float f4 = max(max(1.0 - clamp(abs(dot(normalize(VARYING5.xyz), VARYING4.xyz / vec3(f0))) * 2.0, 0.0, 1.0), 0.0), f3);
    float f5 = VARYING2.w * max(mix(f3, 1.0, f4) * f4, VARYING1.x);
    vec4 f6 = vec4(VARYING2.xyz * VARYING2.xyz, f5);
    float f7 = clamp(exp2((CB0[13].z * f0) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f8 = mix(CB0[14].xyz, f6.xyz, vec3(f7));
    float f9 = f7 * f5;
    vec4 f10 = vec4(f8.x, f8.y, f8.z, f6.w);
    f10.w = f9;
    vec3 f11 = sqrt(clamp(f10.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    vec4 f12 = vec4(f11.x, f11.y, f11.z, f10.w);
    f12.w = f9;
    gl_FragData[0] = f12;
}

//$$DiffuseMapTexture=s3
