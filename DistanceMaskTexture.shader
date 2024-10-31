Shader "WSQ/Unlit/DistanceMaskTexture"
{
    Properties
    {
        [HDR]_Color("Albedo", Color) = (1,1,1,1)          // 基本颜色
        _MainTex ("Texture", 2D) = "white" {}             // 主要纹理
        _GradientTex ("Gradient Texture", 2D) = "white" {} // 渐变贴图
        _CamPos ("Camera Position", Vector) = (0, 0, 0, 0) // 摄像机位置

        // Stencil和Rendering相关的属性
        [Header(Stencil)]
        _Stencil ("Stencil ID [0;255]", Float) = 0
        _ReadMask ("ReadMask [0;255]", Int) = 255
        _WriteMask ("WriteMask [0;255]", Int) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilOp ("Stencil Operation", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilFail ("Stencil Fail", Int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)] _StencilZFail ("Stencil ZFail", Int) = 0

        [Header(Rendering)]
        _Offset("Offset", float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _Culling ("Cull Mode", Int) = 2
        [Enum(Off,0,On,1)] _ZWrite("ZWrite", Int) = 1
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Int) = 4
        [Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _ColorMask("Color Mask", Int) = 15
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    half4 _Color;
    sampler2D _MainTex;
    float4 _MainTex_ST;
    sampler2D _GradientTex;
    float3 _CamPos;

    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
        float3 worldPos : TEXCOORD1; // 世界空间坐标
    };

    v2f vert (appdata v)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz; // 世界坐标
        return o;
    }

    half4 frag (v2f i) : SV_Target
    {
        // 获取物体与摄像机之间的距离
        float dist = distance(i.worldPos, _CamPos);

        // 将距离映射到颜色渐变贴图上 (根据需要缩放到[0,1]范围)
        float maxDistance = 50.0;  // 根据场景设置最大距离
        float mappedDistance = saturate(dist / maxDistance);
        half4 gradientColor = tex2D(_GradientTex, float2(mappedDistance, 0.5));

        // 根据距离颜色与主颜色混合
        return tex2D(_MainTex, i.uv) * _Color * gradientColor;
    }

    ENDCG

    SubShader
    {
        Stencil
        {
            Ref [_Stencil]
            ReadMask [_ReadMask]
            WriteMask [_WriteMask]
            Comp [_StencilComp]
            Pass [_StencilOp]
            Fail [_StencilFail]
            ZFail [_StencilZFail]
        }

        Pass
        {
            Tags { "RenderType"="Opaque" "Queue" = "Geometry" }
            LOD 100
            Cull [_Culling]
            Offset [_Offset], [_Offset]
            ZWrite [_ZWrite]
            ZTest [_ZTest]
            ColorMask [_ColorMask]

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

        // Pass to render object as a shadow caster
        Pass
        {
            Name "ShadowCaster"
            Tags { "LightMode" = "ShadowCaster" }
            LOD 80
            Cull [_Culling]
            Offset [_Offset], [_Offset]
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_shadowcaster
            ENDCG
        }
    }
}
