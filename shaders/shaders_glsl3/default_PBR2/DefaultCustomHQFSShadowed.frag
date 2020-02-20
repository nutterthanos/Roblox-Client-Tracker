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
uniform samplerCube PrefilteredEnvTexture;
uniform samplerCube PrefilteredEnvIndoorTexture;
uniform sampler2D PrecomputedBRDFTexture;
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
    vec3 f19 = (f17.xyz * (f17.w * 120.0)).xyz;
    float f20 = f18.x;
    float f21 = f18.y;
    vec3 f22 = VARYING7.xyz - CB0[41].xyz;
    vec3 f23 = VARYING7.xyz - CB0[42].xyz;
    vec3 f24 = VARYING7.xyz - CB0[43].xyz;
    vec4 f25 = vec4(VARYING7.xyz, 1.0) * mat4(CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 0], CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 1], CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 2], CB8[((dot(f22, f22) < CB0[41].w) ? 0 : ((dot(f23, f23) < CB0[42].w) ? 1 : ((dot(f24, f24) < CB0[43].w) ? 2 : 3))) * 4 + 3]);
    vec4 f26 = textureLod(ShadowAtlasTexture, f25.xy, 0.0);
    vec2 f27 = vec2(0.0);
    f27.x = CB0[45].z;
    vec2 f28 = f27;
    f28.y = CB0[45].w;
    float f29 = (2.0 * f25.z) - 1.0;
    float f30 = exp(CB0[45].z * f29);
    float f31 = -exp((-CB0[45].w) * f29);
    vec2 f32 = (f28 * CB0[46].y) * vec2(f30, f31);
    vec2 f33 = f32 * f32;
    float f34 = f26.x;
    float f35 = max(f26.y - (f34 * f34), f33.x);
    float f36 = f30 - f34;
    float f37 = f26.z;
    float f38 = max(f26.w - (f37 * f37), f33.y);
    float f39 = f31 - f37;
    float f40 = (f12 > 0.0) ? mix(f21, mix(min((f30 <= f34) ? 1.0 : clamp(((f35 / (f35 + (f36 * f36))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0), (f31 <= f37) ? 1.0 : clamp(((f38 / (f38 + (f39 * f39))) - 0.20000000298023223876953125) * 1.25, 0.0, 1.0)), f21, clamp((length(VARYING7.xyz - CB0[7].xyz) * CB0[45].y) - (CB0[45].x * CB0[45].y), 0.0, 1.0)), CB0[46].x) : 0.0;
    vec3 f41 = normalize(VARYING4.xyz);
    vec3 f42 = (f13 * f13).xyz;
    float f43 = CB0[26].w * f2;
    float f44 = max(f9.y, 0.04500000178813934326171875);
    vec3 f45 = reflect(-f41, f10);
    float f46 = f44 * 5.0;
    vec3 f47 = vec4(f45, f46).xyz;
    vec4 f48 = texture(PrecomputedBRDFTexture, vec2(f44, max(9.9999997473787516355514526367188e-05, dot(f10, f41))));
    float f49 = f9.x * f43;
    vec3 f50 = mix(vec3(0.039999999105930328369140625), f42, vec3(f49));
    vec3 f51 = normalize(f11 + f41);
    float f52 = clamp(f12, 0.0, 1.0);
    float f53 = f44 * f44;
    float f54 = max(0.001000000047497451305389404296875, dot(f10, f51));
    float f55 = dot(f11, f51);
    float f56 = 1.0 - f55;
    float f57 = f56 * f56;
    float f58 = (f57 * f57) * f56;
    vec3 f59 = vec3(f58) + (f50 * (1.0 - f58));
    float f60 = f53 * f53;
    float f61 = (((f54 * f60) - f54) * f54) + 1.0;
    float f62 = 1.0 - f49;
    float f63 = f43 * f62;
    vec3 f64 = vec3(f62);
    float f65 = f48.x;
    float f66 = f48.y;
    vec3 f67 = ((f50 * f65) + vec3(f66)) / vec3(f65 + f66);
    vec3 f68 = f64 - (f67 * f63);
    vec3 f69 = f10 * f10;
    bvec3 f70 = lessThan(f10, vec3(0.0));
    vec3 f71 = vec3(f70.x ? f69.x : vec3(0.0).x, f70.y ? f69.y : vec3(0.0).y, f70.z ? f69.z : vec3(0.0).z);
    vec3 f72 = f69 - f71;
    float f73 = f72.x;
    float f74 = f72.y;
    float f75 = f72.z;
    float f76 = f71.x;
    float f77 = f71.y;
    float f78 = f71.z;
    vec3 f79 = (mix(textureLod(PrefilteredEnvIndoorTexture, f47, f46).xyz * f19, textureLod(PrefilteredEnvTexture, f47, f46).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f45.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f20)) * f67) * f43;
    vec3 f80 = ((((((((f64 - (f59 * f63)) * CB0[10].xyz) * f52) * f40) + (f68 * (((((((CB0[35].xyz * f73) + (CB0[37].xyz * f74)) + (CB0[39].xyz * f75)) + (CB0[36].xyz * f76)) + (CB0[38].xyz * f77)) + (CB0[40].xyz * f78)) + (((((((CB0[29].xyz * f73) + (CB0[31].xyz * f74)) + (CB0[33].xyz * f75)) + (CB0[30].xyz * f76)) + (CB0[32].xyz * f77)) + (CB0[34].xyz * f78)) * f20)))) + (CB0[27].xyz + (CB0[28].xyz * f20))) * f42) + ((((f59 * (((f60 + (f60 * f60)) / (((f61 * f61) * ((f55 * 3.0) + 0.5)) * ((f54 * 0.75) + 0.25))) * f52)) * CB0[10].xyz) * f40) + f79)) + (f19 * mix(f42, f79 * (1.0 / (max(max(f79.x, f79.y), f79.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f68) * (f43 * (1.0 - f20))));
    vec4 f81 = vec4(f80.x, f80.y, f80.z, vec4(0.0).w);
    f81.w = f8;
    vec2 f82 = min(VARYING0.wz, VARYING1.wz);
    float f83 = min(f82.x, f82.y) / f1;
    vec3 f84 = mix(CB0[14].xyz, (sqrt(clamp((f81.xyz * clamp((clamp((f1 * CB0[24].x) + CB0[24].y, 0.0, 1.0) * (1.5 - f83)) + f83, 0.0, 1.0)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))))).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    _entryPointOutput = vec4(f84.x, f84.y, f84.z, f81.w);
}

//$$ShadowAtlasTexture=s1
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
