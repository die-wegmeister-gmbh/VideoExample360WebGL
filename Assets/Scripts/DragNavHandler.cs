using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DragNavHandler : MonoBehaviour
{
    private float horizontal = 0;
    private float vertical = 0;
    private Vector3 initialMousePos;
    private Vector3 currentMousePos;
    [SerializeField] private float _dragSpeed = .1f;

    private void Update()
    {
        MouseDragUpdate();
        vertical = Mathf.Clamp(vertical, -90, 90);
    }

    private void LateUpdate()
    {
        transform.rotation = Quaternion.identity;
        transform.Rotate(Vector3.up, horizontal, Space.World);
        transform.Rotate(-transform.right, vertical, Space.World);
    }

    // private void RotationUpdate()
    // {
    //     transform.rotation = Quaternion.identity;
    //     transform.Rotate(transform.up,horizontal,Space.World);
    //     transform.Rotate(transform.right,vertical,Space.World);
    // }

    private void OnDrawGizmos()
    {
        Gizmos.matrix = transform.localToWorldMatrix;
        Gizmos.DrawFrustum(transform.position, 60, 100, 0, 2f);
    }

    void MouseDragUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0)) initialMousePos = Input.mousePosition;
        if (!Input.GetKey(KeyCode.Mouse0)) return;
        currentMousePos = Input.mousePosition;
        Vector2 drag = initialMousePos - currentMousePos;
        initialMousePos = currentMousePos;

        horizontal += drag.x * _dragSpeed;
        vertical += drag.y * _dragSpeed;
    }
}