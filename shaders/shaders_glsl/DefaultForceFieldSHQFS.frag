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
uniform sampler2D GBufferDepthTexture;
uniform sampler2D DiffuseMapTexture;

varying vec2 VARYING0;
varying vec2 VARYING1;
varying vec4 VARYING2;
varying vec4 VARYING4;
varying vec4 VARYING5;

void main()
{
    vec4 f0 = vec4(CB0[7].xyz - VARYING4.xyz, 1.0) * mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    float f1 = f0.w;
    float f2 = texture2D(GBufferDepthTexture, ((f0.xy * 0.5) + vec2(0.5 * f1)).xy / vec2(f1)).x * 500.0;
    float f3 = length(VARYING4.xyz);
    vec4 f4 = texture2D(DiffuseMapTexture, VARYING0);
    float f5 = f4.x;
    float f6 = (f5 > 0.0) ? ((1.0 - clamp(abs(f5 - CB0[14].w) * 13.0, 0.0, 1.0)) * f4.w) : 0.0;
    float f7 = max(max(1.0 - clamp(abs(dot(normalize(VARYING5.xyz), VARYING4.xyz / vec3(f3))) * 2.0, 0.0, 1.0), (f2 > 499.0) ? 0.0 : (1.0 - clamp((f2 - f1) * 3.0, 0.0, 1.0))), f6);
    float f8 = VARYING2.w * max(mix(f6, 1.0, f7) * f7, VARYING1.x);
    vec4 f9 = vec4(VARYING2.xyz * VARYING2.xyz, f8);
    float f10 = clamp(exp2((CB0[13].z * f3) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f11 = mix(CB0[14].xyz, f9.xyz, vec3(f10));
    float f12 = f10 * f8;
    vec4 f13 = vec4(f11.x, f11.y, f11.z, f9.w);
    f13.w = f12;
    vec3 f14 = sqrt(clamp(f13.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    vec4 f15 = vec4(f14.x, f14.y, f14.z, f13.w);
    f15.w = f12;
    gl_FragData[0] = f15;
}

//$$GBufferDepthTexture=s10
//$$DiffuseMapTexture=s3
