Shader "URP/MinimalDeferred"
{
    Properties
    {
        _BaseColor ("Base Color (sRGB)", Color) = (1, 0.2, 0.2, 1)
        _Metallic  ("Metallic", Range(0,1)) = 0
        _Smoothness("Smoothness", Range(0,1)) = 0.5
    }
    SubShader
    {
        Pass
        {
            Name "GBuffer"
            Tags { "LightMode"="UniversalGBuffer" }

            Cull Back
            ZWrite On
            ZTest LEqual

            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex   vert
            #pragma fragment frag

            #pragma multi_compile_fragment _ _WRITE_RENDERING_LAYERS
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT
            #pragma multi_compile_fragment _ _RENDER_PASS_ENABLED

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                
            #include "HL_GeneralHelper.hlsl"


            #if defined(UNITY_6000_0_OR_NEWER)
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/GBufferOutput.hlsl"
            #else
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
            #endif

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half  _Metallic;
                half  _Smoothness;
            CBUFFER_END

            struct Attributes {
                float3 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float3 normalWS    : TEXCOORD1;
            };

            Varyings vert (Attributes IN)
            {
                Varyings OUT;
                VertexPositionInputs pos = GetVertexPositionInputs(IN.positionOS);
                OUT.positionHCS = pos.positionCS;
                OUT.positionWS  = pos.positionWS;
                OUT.normalWS    = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            FragmentOutput frag (Varyings IN)
            {
                // Minimal material values
                half3 albedo     = _BaseColor.rgb;
                half  alpha      = _BaseColor.a;
                half  metallic   = _Metallic;
                half  smoothness = _Smoothness;
                half3 specular   = half3(1,1,1); // standard specular color
                half  occlusion  = 1.0h;
                half3 emission   = half3(0,0,0); // set this to albedo if you want flat/unlit look

                // Build the BRDF data
                BRDFData brdf;
                InitializeBRDFData(albedo, metallic, specular, smoothness, alpha, brdf);

                // Build minimal InputData the packer expects
                InputData inputData = (InputData)0;
                inputData.positionWS      = IN.positionWS;
                inputData.normalWS        = SafeNormalize(IN.normalWS);
                inputData.viewDirectionWS = SafeNormalize(_WorldSpaceCameraPos.xyz - IN.positionWS);

                // Pack material into URP's GBuffer and return MRTs
                return BRDFDataToGbuffer(brdf, inputData, smoothness, emission /*+ bakedGI*/, occlusion);
            }
            ENDHLSL
        }
    }
}