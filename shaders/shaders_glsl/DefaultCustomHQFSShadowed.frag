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

struct MaterialParams
{
    float textureTiling;
    float plasticRoughness;
    float normalShadowScale;
    float normalDetailTiling;
    float normalDetailScale;
    float farTilingDiffuse;
    float farTilingNormal;
    float farTilingSpecular;
    float farDiffuseCutoff;
    float farNormalCutoff;
    float farSpecularCutoff;
    float optBlendColorK;
    float farDiffuseCutoffScale;
    float farNormalCutoffScale;
    float farSpecularCutoffScale;
    float isNonSmoothPlastic;
};

uniform vec4 CB0[47];
uniform vec4 CB2[4];
uniform sampler2D ShadowMapTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;
uniform sampler2D StudsMapTexture;
uniform sampler2D SpecularMapTexture;

varying vec4 VARYING0;
varying vec4 VARYING1;
varying vec4 VARYING2;
varying vec3 VARYING3;
varying vec4 VARYING4;
varying vec4 VARYING5;
varying vec4 VARYING6;
varying vec4 VARYING7;
varying float VARYING8;

void main()
{
    vec2 f0 = VARYING1.xy;
    f0.y = (fract(VARYING1.y) + VARYING8) * 0.25;
    float f1 = VARYING4.w * CB0[23].y;
    float f2 = clamp(1.0 - f1, 0.0, 1.0);
    vec2 f3 = VARYING0.xy * CB2[0].x;
    vec4 f4 = texture2D(DiffuseMapTexture, f3);
    vec3 f5 = (texture2D(NormalMapTexture, f3).xyz * 2.0) - vec3(1.0);
    vec2 f6 = (f5.xy + (((texture2D(NormalDetailMapTexture, f3 * CB2[0].w).xyz * 2.0) - vec3(1.0)).xy * CB2[1].x)).xy * f2;
    float f7 = f6.x;
    float f8 = f4.w;
    vec4 f9 = texture2D(SpecularMapTexture, f3);
    vec3 f10 = normalize(((VARYING6.xyz * f7) + ((cross(VARYING5.xyz, VARYING6.xyz) * VARYING6.w) * f6.y)) + (VARYING5.xyz * f5.z));
    vec3 f11 = vec4(((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f8 + CB2[2].w, 0.0, 1.0))) * f4.xyz) * (1.0 + (f7 * CB2[0].z))) * (texture2D(StudsMapTexture, f0).x * 2.0), f8).xyz;
    float f12 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f13 = VARYING3.yzx - (VARYING3.yzx * f12);
    vec4 f14 = vec4(clamp(f12, 0.0, 1.0));
    vec4 f15 = mix(texture3D(LightMapTexture, f13), vec4(0.0), f14);
    vec4 f16 = mix(texture3D(LightGridSkylightTexture, f13), vec4(1.0), f14);
    vec4 f17 = texture2D(ShadowMapTexture, VARYING7.xy);
    float f18 = (1.0 - ((step(f17.x, VARYING7.z) * clamp(CB0[24].z + (CB0[24].w * abs(VARYING7.z - 0.5)), 0.0, 1.0)) * f17.y)) * f16.y;
    vec3 f19 = (f11 * f11).xyz;
    float f20 = CB0[26].w * f2;
    float f21 = max(f9.y, 0.04500000178813934326171875);
    float f22 = f9.x * f20;
    vec3 f23 = -CB0[11].xyz;
    vec3 f24 = normalize(f23 + normalize(VARYING4.xyz));
    float f25 = clamp(dot(f10, f23), 0.0, 1.0);
    float f26 = f21 * f21;
    float f27 = max(0.001000000047497451305389404296875, dot(f10, f24));
    float f28 = dot(f23, f24);
    float f29 = 1.0 - f28;
    float f30 = f29 * f29;
    float f31 = (f30 * f30) * f29;
    vec3 f32 = vec3(f31) + (mix(vec3(0.039999999105930328369140625), f19, vec3(f22)) * (1.0 - f31));
    float f33 = f26 * f26;
    float f34 = (((f27 * f33) - f27) * f27) + 1.0;
    float f35 = 1.0 - f22;
    vec3 f36 = ((((((vec3(f35) - (f32 * (f20 * f35))) * CB0[10].xyz) * f25) * f18) + min((f15.xyz * (f15.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f16.x)), vec3(CB0[16].w))) * f19) + (((f32 * (((f33 + (f33 * f33)) / (((f34 * f34) * ((f28 * 3.0) + 0.5)) * ((f27 * 0.75) + 0.25))) * f25)) * CB0[10].xyz) * f18);
    vec4 f37 = vec4(f36.x, f36.y, f36.z, vec4(0.0).w);
    f37.w = f8;
    vec2 f38 = min(VARYING0.wz, VARYING1.wz);
    float f39 = min(f38.x, f38.y) / f1;
    vec3 f40 = mix(CB0[14].xyz, (sqrt(clamp((f37.xyz * clamp((clamp((f1 * CB0[24].x) + CB0[24].y, 0.0, 1.0) * (1.5 - f39)) + f39, 0.0, 1.0)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))))).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    gl_FragData[0] = vec4(f40.x, f40.y, f40.z, f37.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$StudsMapTexture=s0
//$$SpecularMapTexture=s5
