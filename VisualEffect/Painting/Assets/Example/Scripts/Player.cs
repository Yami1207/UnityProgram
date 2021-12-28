using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class Player : MonoBehaviour
{
    [SerializeField]
    private bool m_UsedFaceNormal = false;

    [SerializeField]
    private float m_MaxRayDistance = 10.0f;

    [SerializeField]
    private LayerMask m_RayLayerMask = 0;

    [SerializeField]
    private float m_Gravity = 0.5f;

    [SerializeField]
    private float m_MoveSpeed = 0.2f;

    [SerializeField]
    private float m_SensitivityX = 10f;

    [SerializeField]
    private float m_SensitivityY = 10f;

    [SerializeField]
    private float m_MaxPitch = 45.0f;

    [SerializeField]
    private Camera m_Camera;

    private CharacterController m_Controller;

    private readonly Dictionary<KeyCode, System.Func<Vector3>> m_MoveDict = new Dictionary<KeyCode, System.Func<Vector3>>();

    public void Awake()
    {
        m_Controller = this.GetComponent<CharacterController>();

        m_MoveDict.Add(KeyCode.W, () => { return this.transform.forward; });
        m_MoveDict.Add(KeyCode.S, () => { return -this.transform.forward; });
        m_MoveDict.Add(KeyCode.A, () => { return -this.transform.right; });
        m_MoveDict.Add(KeyCode.D, () => { return this.transform.right; });

        this.StartCoroutine(this.SetPlayerAsync());
    }

    public void Tick(float time)
    {
        this.UpdatePosition();
        this.UpdateCamera();
    }

    private void UpdatePosition()
    {
        Vector3 move = Vector3.zero;
        if (m_Controller.isGrounded)
        {
            Dictionary<KeyCode, System.Func<Vector3>>.Enumerator iter = m_MoveDict.GetEnumerator();
            while (iter.MoveNext())
            {
                if (Input.GetKey(iter.Current.Key))
                    move += iter.Current.Value();
            }
            iter.Dispose();
        }
        m_Controller.Move(Vector3.Normalize(move) * m_MoveSpeed - Vector3.up * m_Gravity);
    }

    private void UpdateCamera()
    {
        if (m_Camera == null)
            return;

        float pitch = m_Camera.transform.rotation.eulerAngles.x;
        if (Input.GetMouseButton(1))
        {
            Vector3 euler = this.transform.rotation.eulerAngles;
            euler.y += Input.GetAxis("Mouse X") * m_SensitivityY;
            this.transform.rotation = Quaternion.Euler(euler);

            pitch = pitch >= 180.0f ? pitch - 360.0f : pitch;
            pitch -= Input.GetAxis("Mouse Y") * m_SensitivityX;
            if (Mathf.Abs(pitch) > m_MaxPitch) pitch = pitch < 0.0f ? -m_MaxPitch : m_MaxPitch;
            m_Camera.transform.rotation = Quaternion.Euler(pitch, euler.y, 0.0f);
        }

        Vector3 forward = m_Camera.transform.forward;
        m_Camera.transform.position = this.transform.position;

        if (Input.GetMouseButtonUp(0))
        {
            RaycastHit raycastHit;
            Ray ray = m_Camera.ScreenPointToRay(Input.mousePosition);
            if (Physics.Raycast(ray, out raycastHit, m_MaxRayDistance, m_RayLayerMask))
            {
                float ratio = 0.1f;

                if (!m_UsedFaceNormal)
                {
                    Vector3 pos = raycastHit.point - ratio * ray.direction;
                    Vector3 dir = ray.direction;

                    Vector3 up = Vector3.Normalize(Vector3.Cross(dir, this.transform.right));
                    Painting.Core.instance.CreatePaint(pos, Quaternion.LookRotation(dir, up), dir);
                }
                else
                {
                    // 使用碰撞面法线作为投影方向
                    Vector3 pos = raycastHit.point + ratio * raycastHit.normal;
                    Vector3 dir = -raycastHit.normal;
                    Vector3 up = Vector3.Normalize(Vector3.Cross(dir, this.transform.right));
                    Painting.Core.instance.CreatePaint(pos, Quaternion.LookRotation(dir, up), dir);
                }
            }
        }
    }

    private IEnumerator SetPlayerAsync()
    {
        while (Main.instance == null)
            yield return 0;
        Main.instance.player = this;
    }
}
