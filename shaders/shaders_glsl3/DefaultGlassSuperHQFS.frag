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
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform sampler2D PrecomputedBRDFTexture;
uniform sampler2D DiffuseMapTexture;
uniform sampler2D NormalMapTexture;
uniform sampler2D NormalDetailMapTexture;
uniform sampler2D StudsMapTexture;
uniform sampler2D SpecularMapTexture;
uniform sampler2D GBufferDepthTexture;
uniform sampler2D GBufferColorTexture;

in vec2 VARYING0;
in vec2 VARYING1;
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
    vec2 f0 = VARYING1;
    f0.y = (fract(VARYING1.y) + VARYING8) * 0.25;
    float f1 = clamp(1.0 - (VARYING4.w * CB0[23].y), 0.0, 1.0);
    vec2 f2 = VARYING0 * CB2[0].x;
    vec4 f3 = texture(DiffuseMapTexture, f2);
    vec2 f4 = texture(NormalMapTexture, f2).wy * 2.0;
    vec2 f5 = f4 - vec2(1.0);
    float f6 = sqrt(clamp(1.0 + dot(vec2(1.0) - f4, f5), 0.0, 1.0));
    vec2 f7 = (vec3(f5, f6).xy + (vec3((texture(NormalDetailMapTexture, f2 * CB2[0].w).wy * 2.0) - vec2(1.0), 0.0).xy * CB2[1].x)).xy * f1;
    float f8 = f3.w;
    vec3 f9 = ((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f8 + CB2[2].w, 0.0, 1.0))) * f3.xyz) * (1.0 + (f7.x * CB2[0].z))) * (texture(StudsMapTexture, f0).x * 2.0);
    vec4 f10 = mix(texture(SpecularMapTexture, f2 * CB2[1].w), texture(SpecularMapTexture, f2), vec4(clamp((f1 * CB2[3].z) - (CB2[2].z * CB2[3].z), 0.0, 1.0)));
    float f11 = f10.y;
    float f12 = VARYING2.w * 2.0;
    float f13 = clamp((f12 - 1.0) + f8, 0.0, 1.0);
    float f14 = clamp(f12, 0.0, 1.0);
    vec3 f15 = normalize(((VARYING6.xyz * f7.x) + (cross(VARYING5.xyz, VARYING6.xyz) * f7.y)) + (VARYING5.xyz * (f6 * 10.0)));
    float f16 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f17 = VARYING3.yzx - (VARYING3.yzx * f16);
    vec4 f18 = vec4(clamp(f16, 0.0, 1.0));
    vec4 f19 = mix(texture(LightMapTexture, f17), vec4(0.0), f18);
    vec4 f20 = mix(texture(LightGridSkylightTexture, f17), vec4(1.0), f18);
    vec3 f21 = (f19.xyz * (f19.w * 120.0)).xyz;
    float f22 = f20.x;
    vec4 f23 = texture(ShadowMapTexture, VARYING7.xy);
    float f24 = (1.0 - ((step(f23.x, VARYING7.z) * clamp(CB0[24].z + (CB0[24].w * abs(VARYING7.z - 0.5)), 0.0, 1.0)) * f23.y)) * f20.y;
    vec3 f25 = f9 * f9;
    float f26 = length(VARYING4.xyz);
    vec3 f27 = VARYING4.xyz / vec3(f26);
    vec3 f28 = f25 * f13;
    float f29 = CB0[26].w * f1;
    float f30 = max(9.9999997473787516355514526367188e-05, dot(f15, f27));
    vec3 f31 = reflect(-f27, f15);
    float f32 = f11 * 5.0;
    vec3 f33 = vec4(f31, f32).xyz;
    vec3 f34 = textureLod(PrefilteredEnvTexture, f33, f32).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f31.y * 1.58823525905609130859375, 0.0, 1.0)));
    vec4 f35 = texture(PrecomputedBRDFTexture, vec2(f11, f30));
    vec3 f36 = vec3(f22);
    vec3 f37 = mix(f21, f34, f36) * mix(vec3(1.0), f25, vec3(0.5));
    vec3 f38 = -CB0[11].xyz;
    vec3 f39 = normalize(f38 + f27);
    float f40 = dot(f15, f38);
    float f41 = clamp(f40, 0.0, 1.0);
    float f42 = f11 * f11;
    float f43 = max(0.001000000047497451305389404296875, dot(f15, f39));
    float f44 = dot(f38, f39);
    float f45 = 1.0 - f44;
    float f46 = f45 * f45;
    float f47 = (f46 * f46) * f45;
    vec3 f48 = vec3(f47) + (vec3(0.039999999105930328369140625) * (1.0 - f47));
    float f49 = f42 * f42;
    float f50 = (((f43 * f49) - f43) * f43) + 1.0;
    float f51 = f35.x;
    float f52 = f35.y;
    vec3 f53 = ((vec3(0.039999999105930328369140625) * f51) + vec3(f52)) / vec3(f51 + f52);
    vec3 f54 = f53 * f29;
    vec3 f55 = f15 * f15;
    bvec3 f56 = lessThan(f15, vec3(0.0));
    vec3 f57 = vec3(f56.x ? f55.x : vec3(0.0).x, f56.y ? f55.y : vec3(0.0).y, f56.z ? f55.z : vec3(0.0).z);
    vec3 f58 = f55 - f57;
    float f59 = f58.x;
    float f60 = f58.y;
    float f61 = f58.z;
    float f62 = f57.x;
    float f63 = f57.y;
    float f64 = f57.z;
    vec3 f65 = (mix(textureLod(PrefilteredEnvIndoorTexture, f33, f32).xyz * f21, f34, f36) * f53) * f29;
    float f66 = 1.0 - f30;
    float f67 = 1.0 - VARYING2.w;
    float f68 = mix(0.660000026226043701171875, 1.0, f67 * f67);
    mat4 f69 = mat4(CB0[0], CB0[1], CB0[2], CB0[3]);
    vec4 f70 = vec4(CB0[7].xyz - VARYING4.xyz, 1.0) * f69;
    vec4 f71 = vec4(CB0[7].xyz - ((VARYING4.xyz * (1.0 + ((3.0 * f68) / max(dot(VARYING4.xyz, f15), 0.00999999977648258209228515625)))) + (f15 * (3.0 * (1.0 - f68)))), 1.0) * f69;
    float f72 = f70.w;
    vec2 f73 = ((f70.xy * 0.5) + vec2(0.5 * f72)).xy / vec2(f72);
    float f74 = f71.w;
    vec2 f75 = ((f71.xy * 0.5) + vec2(0.5 * f74)).xy / vec2(f74);
    vec2 f76 = f75 - vec2(0.5);
    vec2 f77 = (f75 - f73) * clamp(vec2(1.0) - ((f76 * f76) * 4.0), vec2(0.0), vec2(1.0));
    vec2 f78 = normalize(f77) * CB0[23].x;
    vec4 f79 = texture(GBufferColorTexture, f73 + (f77 * clamp(min(texture(GBufferDepthTexture, f75 + f78).x * 500.0, texture(GBufferDepthTexture, f75 - f78).x * 500.0) - f72, 0.0, 1.0)));
    vec3 f80 = f79.xyz;
    vec3 f81 = ((f80 * f80) * CB0[15].x).xyz;
    vec3 f82 = f81 * mix(vec3(1.0), VARYING2.xyz, vec3(f14));
    vec4 f83 = vec4(f82.x, f82.y, f82.z, vec4(0.0).w);
    f83.w = mix(1.0, f79.w, dot(f82.xyz, vec3(1.0)) / (dot(f81, vec3(1.0)) + 0.00999999977648258209228515625));
    vec4 f84 = mix(mix(f83, vec4(mix(((((((((vec3(1.0) - (f48 * f29)) * CB0[10].xyz) * f41) + (CB0[12].xyz * clamp(-f40, 0.0, 1.0))) * f24) + (((vec3(1.0) - f54) * (((((((CB0[35].xyz * f59) + (CB0[37].xyz * f60)) + (CB0[39].xyz * f61)) + (CB0[36].xyz * f62)) + (CB0[38].xyz * f63)) + (CB0[40].xyz * f64)) + (((((((CB0[29].xyz * f59) + (CB0[31].xyz * f60)) + (CB0[33].xyz * f61)) + (CB0[30].xyz * f62)) + (CB0[32].xyz * f63)) + (CB0[34].xyz * f64)) * f22))) * f13)) + (CB0[27].xyz + (CB0[28].xyz * f22))) * f28) + ((f21 * mix(f28, f65 * (1.0 / (max(max(f65.x, f65.y), f65.z) + 0.00999999977648258209228515625)), f54 * (f29 * (1.0 - f22)))) * f13), f37, vec3(VARYING7.w)), 1.0), vec4(f13)), vec4(f37, 1.0), vec4(((f66 * f66) * 0.800000011920928955078125) * f14)) + vec4((((f48 * (((f49 + (f49 * f49)) / (((f50 * f50) * ((f44 * 3.0) + 0.5)) * ((f43 * 0.75) + 0.25))) * f41)) * CB0[10].xyz) * f24) + (f65 * f13), 0.0);
    float f85 = clamp(exp2((CB0[13].z * f26) + CB0[13].x) - CB0[13].w, 0.0, 1.0);
    vec3 f86 = textureLod(PrefilteredEnvTexture, vec4(-VARYING4.xyz, 0.0).xyz, max(CB0[13].y, f85) * 5.0).xyz;
    bvec3 f87 = bvec3(CB0[13].w != 0.0);
    vec3 f88 = mix(vec3(f87.x ? CB0[14].xyz.x : f86.x, f87.y ? CB0[14].xyz.y : f86.y, f87.z ? CB0[14].xyz.z : f86.z), f84.xyz, vec3(f85));
    vec4 f89 = vec4(f88.x, f88.y, f88.z, f84.w);
    f89.w = f85 * f84.w;
    vec3 f90 = sqrt(clamp(f89.xyz * CB0[15].y, vec3(0.0), vec3(1.0)));
    _entryPointOutput = vec4(f90.x, f90.y, f90.z, f89.w);
}

//$$ShadowMapTexture=s1
//$$LightMapTexture=s6
//$$LightGridSkylightTexture=s7
//$$PrefilteredEnvTexture=s15
//$$PrefilteredEnvIndoorTexture=s14
//$$PrecomputedBRDFTexture=s11
//$$DiffuseMapTexture=s3
//$$NormalMapTexture=s4
//$$NormalDetailMapTexture=s8
//$$StudsMapTexture=s0
//$$SpecularMapTexture=s5
//$$GBufferDepthTexture=s10
//$$GBufferColorTexture=s9
