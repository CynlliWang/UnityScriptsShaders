using UnityEngine;
using UnityEditor;
using System.IO;
using System.Text;

public class ExportObj : MonoBehaviour
{
    [MenuItem("Tools/Export Selected to OBJ")]
    static void ExportSelectedToObj()
    {
        if (Selection.activeGameObject == null)
        {
            Debug.LogError("No object selected. Please select an object to export.");
            return;
        }

        GameObject selectedObject = Selection.activeGameObject;

        // Combine meshes
        MeshFilter[] meshFilters = selectedObject.GetComponentsInChildren<MeshFilter>();
        CombineInstance[] combine = new CombineInstance[meshFilters.Length];

        for (int i = 0; i < meshFilters.Length; i++)
        {
            combine[i].mesh = meshFilters[i].sharedMesh;
            combine[i].transform = meshFilters[i].transform.localToWorldMatrix;
        }

        Mesh combinedMesh = new Mesh();
        combinedMesh.CombineMeshes(combine, true, true);

        // Export as OBJ
        string path = EditorUtility.SaveFilePanel("Save OBJ File", "", selectedObject.name + ".obj", "obj");
        if (string.IsNullOrEmpty(path)) return;

        ExportMeshToObj(combinedMesh, path);
        Debug.Log($"Exported {selectedObject.name} to {path}");
    }

    static void ExportMeshToObj(Mesh mesh, string filePath)
    {
        StringBuilder sb = new StringBuilder();

        sb.AppendLine("# Unity OBJ Exporter");
        foreach (Vector3 v in mesh.vertices)
        {
            sb.AppendLine($"v {v.x} {v.y} {v.z}");
        }

        foreach (Vector3 vn in mesh.normals)
        {
            sb.AppendLine($"vn {vn.x} {vn.y} {vn.z}");
        }

        foreach (Vector2 uv in mesh.uv)
        {
            sb.AppendLine($"vt {uv.x} {uv.y}");
        }

        for (int i = 0; i < mesh.subMeshCount; i++)
        {
            int[] triangles = mesh.GetTriangles(i);
            for (int j = 0; j < triangles.Length; j += 3)
            {
                sb.AppendLine($"f {triangles[j] + 1}/{triangles[j] + 1}/{triangles[j] + 1} " +
                              $"{triangles[j + 1] + 1}/{triangles[j + 1] + 1}/{triangles[j + 1] + 1} " +
                              $"{triangles[j + 2] + 1}/{triangles[j + 2] + 1}/{triangles[j + 2] + 1}");
            }
        }

        File.WriteAllText(filePath, sb.ToString());
    }
}
