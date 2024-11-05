using UnityEngine;
using UnityEditor;

public class CreateSkletonFromTransform : MonoBehaviour
{
    [MenuItem("Tools/Create Skeleton from Transform")]
    public static void GenerateSkeleton()
    {
        // 获取选中的对象
        GameObject selectedObject = Selection.activeGameObject;

        if (selectedObject == null)
        {
            Debug.LogError("请先选中一个对象！");
            return;
        }

        // 创建一个新的骨骼对象
        GameObject skeleton = new GameObject(selectedObject.name + "_Skeleton");
        skeleton.transform.position = selectedObject.transform.position;

        // 递归生成骨骼
        CreateBone(selectedObject.transform, skeleton.transform);
        
        Debug.Log("骨骼对象生成完成: " + skeleton.name);
    }

    private static void CreateBone(Transform sourceTransform, Transform parentBone)
    {
        // 创建一个新的骨骼节点
        GameObject bone = new GameObject(sourceTransform.name);
        bone.transform.SetParent(parentBone);
        bone.transform.localPosition = Vector3.zero; // 在父节点的位置上

        // 遍历子对象，递归创建骨骼
        foreach (Transform child in sourceTransform)
        {
            CreateBone(child, bone.transform);
        }
    }
}
