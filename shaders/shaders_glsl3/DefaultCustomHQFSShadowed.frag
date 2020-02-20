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

struct LightShadowGPUTransform
{
    mat4 transform;
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
uniform vec4 CB8[24];
uniform vec4 CB2[4];
uniform sampler2D ShadowAtlasTexture;
uniform sampler3D LightMapTexture;
uniform sampler3D LightGridSkylightTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;
uniform sampler2D StudsMapTexture;
uniform sampler2D SpecularMapTexture;

in vec4 VARYING0;
in vec4 VARYING1;
in vec4 VARYING2;
in vec3 VARYING3;
in vec4 VARYING4;
in vec4 VARYING5;
in vec4 VARYING6;
in vec4 VARYING7;
in float VARYING8;
out vec4 _entryPointOutput;

void main()
{
    vec2 f0 = VARYING1.xy;
    f0.y = (fract(VARYING1.y) + VARYING8) * 0.25;
    float f1 = VARYING4.w * CB0[23].y;
    float f2 = clamp(1.0 - f1, 0.0, 1.0);
    vec2 f3 = VARYING0.xy * CB2[0].x;
    vec4 f4 = texture(DiffuseMapTexture, f3);
    vec3 f5 = (texture(NormalMapTexture, f3).xyz * 2.0) - vec3(1.0);
    vec2 f6 = (f5.xy + (((texture(NormalDetailMapTexture, f3 * CB2[0].w).xyz * 2.0) - vec3(1.0)).xy * CB2[1].x)).xy * f2;
    float f7 = f6.x;
    float f8 = f4.w;
    vec4 f9 = texture(SpecularMapTexture, f3);
    vec3 f10 = normalize(((VARYING6.xyz * f7) + ((cross(VARYING5.xyz, VARYING6.xyz) * VARYING6.w) * f6.y)) + (VARYING5.xyz * f5.z));
    vec3 f11 = -CB0[11].xyz;
    float f12 = dot(f10, f11);
    vec3 f13 = vec4(((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f8 + CB2[2].w, 0.0, 1.0))) * f4.xyz) * (1.0 + (f7 * CB2[0].z))) * (texture(StudsMapTexture, f0).x * 2.0), f8).xyz;
    float f14 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f15 = VARYING3.yzx - (VARYING3.yzx * f14);
    vec4 f16 = vec4(clamp(f14, 0.0, 1.0));
    vec4 f17 = mix(texture(LightMapTexture, f15), vec4(0.0), f16);
    vec4 f18 = mix(texture(LightGridSkylightTexture, f15), vec4(1.0), f16);
    float f19 = f18.y;
    vec3 f20 = VARYING7.xyz - CB0[41].xyz;
    vec3 f21 = VARYING7.xyz - CB0[42].xyz;
    vec3 f22 = VARYING7.xyz - CB0[43].xyz;
    vec4 f23 = vec4(VARYING7.xyz, 1.0) * mat4(CB8[((dot(f20, f20) < CB0[41].w) ? 0 : ((dot(f21, f21) < CB0[42].w) ? 1 : ((dot(f22, f22) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f20, f20) < CB0[41].w) ? 0 : ((dot(f21, f21) < CB0[42].w) ? 1 : ((dot(f22, f22) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f20, f20) < CB0[41].w) ? 0 : ((dot(f21, f21) < CB0[42].w) ? 1 : ((dot(f22, f22) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f20, f20) < CB0[41].w) ? 0 : ((dot(f21, f21) < CB0[42].w) ? 1 : ((dot(f22, f22) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f24 = textureLod(ShadowAtlasTexture, f23.xy, 0.0);
    vec2 f25 = vec2(0.0);
    f25.x = CB0[45].z;
    vec2 f26 = f25;
    f26.y = CB0[45].w;
    float f27 = (2.0 * f23.z) - 1.0;
    float f28 = exp(CB0[45].z * f27);
    float f29 = -exp((-CB0[45].w) * f27);
    vec2 f30 = (f26 * CB0[46].y) * vec2(f28, f29);
    vec2 f31 = f30 * f30;
    float f32 = f24.x;
    float f33 = max(f24.y - (f32 * f32), f31.x);
    float f34 = f28 - f32;
    float f35 = f24.z;
    float f36 = max(f24.w - (f35 * f35), f31.y);
    float f37 = f29 - f35;
    float f38 = (f12 > 0.0) ? mix(f19, mix(min((f28 <= f32) ? 1.0 : clamp(((f33 / (f33 + (f34 * f34))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f29 <= f35) ? 1.0 : clamp(((f36 / (f36 + (f37 * f37))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f19, clamp((length(VARYING7.xyz - CB0[7].xyz) * CB0[45].y) - (CB0[45].x * CB0[45].y), 0.0, 1.0)), CB0[46].x) : 0.0;
    vec3 f39 = (f13 * f13).xyz;
    float f40 = CB0[26].w * f2;
    float f41 = max(f9.y, 0.04500000178813934326171875);
    float f42 = f9.x * f40;
    vec3 f43 = normalize(f11 + normalize(VARYING4.xyz));
    float f44 = clamp(f12, 0.0, 1.0);
    float f45 = f41 * f41;
    float f46 = max(0.001000000047497451305389404296875, dot(f10, f43));
    float f47 = dot(f11, f43);
    float f48 = 1.0 - f47;
    float f49 = f48 * f48;
    float f50 = (f49 * f49) * f48;
    vec3 f51 = vec3(f50) + (mix(vec3(0.039999999105930328369140625), f39, vec3(f42)) * (1.0 - f50));
    float f52 = f45 * f45;
    float f53 = (((f46 * f52) - f46) * f46) + 1.0;
    float f54 = 1.0 - f42;
    vec3 f55 = ((((((vec3(f54) - (f51 * (f40 * f54))) * CB0[10].xyz) * f44) * f38) + min((f17.xyz * (f17.w * 120.0)).xyz + (CB0[8].xyz + (CB0[9].xyz * f18.x)), vec3(CB0[16].w))) * f39) + (((f51 * (((f52 + (f52 * f52)) / (((f53 * f53) * ((f47 * 3.0) + 0.5)) * ((f46 * 0.75) + 0.25))) * f44)) * CB0[10].xyz) * f38);
    vec4 f56 = vec4(f55.x, f55.y, f55.z, vec4(0.0).w);
    f56.w = f8;
    vec2 f57 = min(VARYING0.wz, VARYING1.wz);
    float f58 = min(f57.x, f57.y) / f1;
    vec3 f59 = mix(CB0[14].xyz, (sqrt(clamp((f56.xyz * clamp((clamp((f1 * CB0[24].x) + CB0[24].y, 0.0, 1.0) * (1.5 - f58)) + f58, 0.0, 1.0)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))))).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    _entryPointOutput = vec4(f59.x, f59.y, f59.z, f56.w);
}

//$$ShadowAtlasTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$StudsMapTexture=s0
//$$SpecularMapTexture=s5
