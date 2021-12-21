using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class CloudShadowSystem : MonoBehaviour
{
    /// <summary>
    /// Shader相关属性
    /// </summary>
    private readonly static int PROPERTY_CLOUD_SHADOW_TEXTURE = Shader.PropertyToID("g_CloudShadowTexture");
    private readonly static int PROPERTY_CLOUD_SHADOW_COLOR = Shader.PropertyToID("g_CloudShadowColor");
    private readonly static int PROPERTY_CLOUD_SHADOW_VELOCITY = Shader.PropertyToID("g_CloudShadowVelocity");
    private readonly static int PROPERTY_CLOUD_SHADOW_TILE = Shader.PropertyToID("g_CloudShadowTile");

    /// <summary>
    /// 纹理UV平铺值
    /// </summary>
    [SerializeField]
    private Vector2 m_TileUV = new Vector2(120.0f, 80.0f);
    public Vector3 TileUV
    {
        set
        {
            m_TileUV = value;
            Shader.SetGlobalVector(PROPERTY_CLOUD_SHADOW_TILE, new Vector4(1.0f / m_TileUV.x, 1.0f / m_TileUV.y, 1.0f, 1.0f));
        }
        get { return m_TileUV; }
    }

    /// <summary>
    /// UV移动方向
    /// </summary>
    [SerializeField]
    private Vector3 m_Direction = new Vector3(1.0f, 0.0f, 1.0f);
    public Vector3 Direction
    {
        set
        {
            m_Direction = value;
            Shader.SetGlobalVector(PROPERTY_CLOUD_SHADOW_VELOCITY, m_Speed * Vector3.Normalize(m_Direction));
        }
        get { return m_Direction; }
    }

    /// <summary>
    /// 云影移动速度
    /// </summary>
    [SerializeField]
    private float m_Speed = 0.05f;
    public float Speed
    {
        set
        {
            m_Speed = value;
            Shader.SetGlobalVector(PROPERTY_CLOUD_SHADOW_VELOCITY, m_Speed * Vector3.Normalize(m_Direction));
        }
        get { return m_Speed; }
    }

    /// <summary>
    /// 云影颜色值
    /// </summary>
    [SerializeField]
    private Color m_Color = new Color(0.0f, 0.0f, 0.0f, 0.48f);
    public Color Color
    {
        set
        {
            m_Color = value;
            Shader.SetGlobalColor(PROPERTY_CLOUD_SHADOW_COLOR, m_Color);
        }
        get { return m_Color; }
    }

    /// <summary>
    /// 云纹理
    /// </summary>
    [SerializeField]
    private Texture2D m_Texture = null;
    public Texture2D CloudTexture
    {
        set
        {
            m_Texture = value;
            Shader.SetGlobalTexture(PROPERTY_CLOUD_SHADOW_TEXTURE, m_Texture);
        }
        get { return m_Texture; }
    }

    private void OnEnable()
    {
        this.SetGlobalAttributes();
    }

#if UNITY_EDITOR
    private void Update()
    {
        this.SetGlobalAttributes();
    }
#endif

    /// <summary>
    /// 设置云影相关参数
    /// </summary>
    private void SetGlobalAttributes()
    {
        Shader.SetGlobalTexture(PROPERTY_CLOUD_SHADOW_TEXTURE, m_Texture);
        Shader.SetGlobalColor(PROPERTY_CLOUD_SHADOW_COLOR, m_Color);
        Shader.SetGlobalVector(PROPERTY_CLOUD_SHADOW_VELOCITY, m_Speed * Vector3.Normalize(m_Direction));
        Shader.SetGlobalVector(PROPERTY_CLOUD_SHADOW_TILE, new Vector4(1.0f / m_TileUV.x, 1.0f / m_TileUV.y, 1.0f, 1.0f));
    }
}
