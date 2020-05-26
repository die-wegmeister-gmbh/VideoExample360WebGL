using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class QuadScaler : MonoBehaviour
{
    [SerializeField] private Camera camera;
    private Vector3 newScale;

    private void Update()
    {
        if (!camera) return;
        newScale = Vector3.one;
        newScale.x = Screen.width * .001f;
        newScale.y = Screen.height * .001f;
        newScale.z = camera.nearClipPlane;
        transform.localScale = newScale;
    }
}