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
    vec3 f11 = vec4(((mix(vec3(1.0), VARYING2.xyz, vec3(clamp(f8 + CB2[2].w, 0.0, 1.0))) * f4.xyz) * (1.0 + (f7 * CB2[0].z))) * (texture(StudsMapTexture, f0).x * 2.0), f8).xyz;
    float f12 = clamp(dot(step(CB0[19].xyz, abs(VARYING3 - CB0[18].xyz)), vec3(1.0)), 0.0, 1.0);
    vec3 f13 = VARYING3.yzx - (VARYING3.yzx * f12);
    vec4 f14 = vec4(clamp(f12, 0.0, 1.0));
    vec4 f15 = mix(texture(LightMapTexture, f13), vec4(0.0), f14);
    vec4 f16 = mix(texture(LightGridSkylightTexture, f13), vec4(1.0), f14);
    vec3 f17 = (f15.xyz * (f15.w * 120.0)).xyz;
    float f18 = f16.x;
    vec4 f19 = texture(ShadowMapTexture, VARYING7.xy);
    float f20 = (1.0 - ((step(f19.x, VARYING7.z) * clamp(CB0[24].z + (CB0[24].w * abs(VARYING7.z - 0.5)), 0.0, 1.0)) * f19.y)) * f16.y;
    vec3 f21 = normalize(VARYING4.xyz);
    vec3 f22 = (f11 * f11).xyz;
    float f23 = CB0[26].w * f2;
    float f24 = max(f9.y, 0.04500000178813934326171875);
    vec3 f25 = reflect(-f21, f10);
    float f26 = f24 * 5.0;
    vec3 f27 = vec4(f25, f26).xyz;
    vec4 f28 = texture(PrecomputedBRDFTexture, vec2(f24, max(9.9999997473787516355514526367188e-05, dot(f10, f21))));
    float f29 = f9.x * f23;
    vec3 f30 = mix(vec3(0.039999999105930328369140625), f22, vec3(f29));
    vec3 f31 = -CB0[11].xyz;
    vec3 f32 = normalize(f31 + f21);
    float f33 = dot(f10, f31);
    float f34 = clamp(f33, 0.0, 1.0);
    float f35 = f24 * f24;
    float f36 = max(0.001000000047497451305389404296875, dot(f10, f32));
    float f37 = dot(f31, f32);
    float f38 = 1.0 - f37;
    float f39 = f38 * f38;
    float f40 = (f39 * f39) * f38;
    vec3 f41 = vec3(f40) + (f30 * (1.0 - f40));
    float f42 = f35 * f35;
    float f43 = (((f36 * f42) - f36) * f36) + 1.0;
    float f44 = 1.0 - f29;
    float f45 = f23 * f44;
    vec3 f46 = vec3(f44);
    float f47 = f28.x;
    float f48 = f28.y;
    vec3 f49 = ((f30 * f47) + vec3(f48)) / vec3(f47 + f48);
    vec3 f50 = f46 - (f49 * f45);
    vec3 f51 = f10 * f10;
    bvec3 f52 = lessThan(f10, vec3(0.0));
    vec3 f53 = vec3(f52.x ? f51.x : vec3(0.0).x, f52.y ? f51.y : vec3(0.0).y, f52.z ? f51.z : vec3(0.0).z);
    vec3 f54 = f51 - f53;
    float f55 = f54.x;
    float f56 = f54.y;
    float f57 = f54.z;
    float f58 = f53.x;
    float f59 = f53.y;
    float f60 = f53.z;
    vec3 f61 = (mix(textureLod(PrefilteredEnvIndoorTexture, f27, f26).xyz * f17, textureLod(PrefilteredEnvTexture, f27, f26).xyz * mix(CB0[26].xyz, CB0[25].xyz, vec3(clamp(f25.y * 1.58823525905609130859375, 0.0, 1.0))), vec3(f18)) * f49) * f23;
    vec3 f62 = (((((((((f46 - (f41 * f45)) * CB0[10].xyz) * f34) + (CB0[12].xyz * (f44 * clamp(-f33, 0.0, 1.0)))) * f20) + (f50 * (((((((CB0[35].xyz * f55) + (CB0[37].xyz * f56)) + (CB0[39].xyz * f57)) + (CB0[36].xyz * f58)) + (CB0[38].xyz * f59)) + (CB0[40].xyz * f60)) + (((((((CB0[29].xyz * f55) + (CB0[31].xyz * f56)) + (CB0[33].xyz * f57)) + (CB0[30].xyz * f58)) + (CB0[32].xyz * f59)) + (CB0[34].xyz * f60)) * f18)))) + (CB0[27].xyz + (CB0[28].xyz * f18))) * f22) + ((((f41 * (((f42 + (f42 * f42)) / (((f43 * f43) * ((f37 * 3.0) + 0.5)) * ((f36 * 0.75) + 0.25))) * f34)) * CB0[10].xyz) * f20) + f61)) + (f17 * mix(f22, f61 * (1.0 / (max(max(f61.x, f61.y), f61.z) + 0.00999999977648258209228515625)), (vec3(1.0) - f50) * (f23 * (1.0 - f18))));
    vec4 f63 = vec4(f62.x, f62.y, f62.z, vec4(0.0).w);
    f63.w = f8;
    vec2 f64 = min(VARYING0.wz, VARYING1.wz);
    float f65 = min(f64.x, f64.y) / f1;
    vec3 f66 = mix(CB0[14].xyz, (sqrt(clamp((f63.xyz * clamp((clamp((f1 * CB0[24].x) + CB0[24].y, 0.0, 1.0) * (1.5 - f65)) + f65, 0.0, 1.0)).xyz * CB0[15].y, vec3(0.0), vec3(1.0))) + vec3((-0.00048828125) + (0.0009765625 * fract(52.98291778564453125 * fract(dot(gl_FragCoord.xy, vec2(0.067110560834407806396484375, 0.005837149918079376220703125))))))).xyz, vec3(clamp((CB0[13].x * length(VARYING4.xyz)) + CB0[13].y, 0.0, 1.0)));
    _entryPointOutput = vec4(f66.x, f66.y, f66.z, f63.w);
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
