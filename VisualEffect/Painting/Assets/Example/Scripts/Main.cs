using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Main : MonoBehaviour
{
    private static Main s_Instance;
    public static Main instance { get { return s_Instance; } }

    private Player m_Player;
    public Player player { set { m_Player = value; } get { return m_Player; } }

    void Awake()
    {
        s_Instance = this;
    }

    private void Update()
    {
        float time = Time.deltaTime;

        if (Painting.Core.instance != null)
            Painting.Core.instance.Tick(time);

        if (m_Player != null)
            m_Player.Tick(time);
    }
}
