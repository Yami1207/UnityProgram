using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class LightingSetting : MonoBehaviour
{
    [SerializeField]
    private Transform m_Lights;

    void Update()
    {
        if (m_Lights == null)
            return;

        Vector4[] sphereLightCharacterA = new Vector4[3];
        Vector4[] sphereLightCharacterB = new Vector4[3];
        for (int i = 0; i < sphereLightCharacterA.Length; ++i)
            sphereLightCharacterA[i] = sphereLightCharacterB[i] = Vector4.zero;

        int count = Mathf.Min(3, m_Lights.childCount);
        for (int i = 0; i < count; ++i)
        {
            Light light = m_Lights.GetChild(i).GetComponent<Light>();
            if (light == null || light.type != LightType.Point)
                continue;

            sphereLightCharacterA[i] = light.color;

            Vector3 position = light.transform.position;
            sphereLightCharacterB[i] = new Vector4(position.x, position.y, position.z, light.range);
        }

        Shader.SetGlobalVectorArray("_XSphereLightCharacterA", sphereLightCharacterA);
        Shader.SetGlobalVectorArray("_XSphereLightCharacterB", sphereLightCharacterB);
    }
}
