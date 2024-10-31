using UnityEngine;

[ExecuteInEditMode]
public class DistanceMaskController : MonoBehaviour
{
    public Material material; // 将要应用的材质
    public Texture2D gradientTexture; // 渐变贴图
    public Camera cam; // 摄像机

    private void Start()
    {
        if (cam == null)
            cam = Camera.main; // 默认设置为主摄像机
    }

    void Update()
    {
        if (material != null && cam != null)
        {
            // 更新摄像机位置
            material.SetVector("_CamPos", cam.transform.position);
            
            // 更新渐变贴图
            if (gradientTexture != null)
                material.SetTexture("_GradientTex", gradientTexture);
        }
    }
}
