using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class Pixelate : MonoBehaviour {
    public Shader pixelateShader;
    private Material pixelateMat;

    public int pixelNumber = 128;
    public int colorLevel = 5;

    private void OnRenderImage(RenderTexture source, RenderTexture destination) {
        if (pixelateMat == null) {
            pixelateMat = new Material(pixelateShader);
        }
        pixelateMat.SetFloat("_ColorLevel", colorLevel);
        pixelateMat.SetFloat("_Intensity", pixelNumber);
        Graphics.Blit(source, destination, pixelateMat);
    }
}
