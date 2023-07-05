using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DitherCamera : MonoBehaviour {
    public Material m_DitherMaterial;
    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if(m_DitherMaterial == null) return;
        Graphics.Blit(source, destination, m_DitherMaterial);
    }
}
