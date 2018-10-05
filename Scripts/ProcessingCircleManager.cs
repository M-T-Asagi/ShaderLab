using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProcessingCircleManager : MonoBehaviour
{

    [SerializeField]
    new MeshRenderer renderer;

    Material mat;

    void Start()
    {
        mat = renderer.material;
        ResetState();
    }

    public void UpdateState(float state)
    {
        mat.SetFloat("_State", state);
    }

    public void ResetState()
    {
        mat.SetFloat("_State", 0);
    }
}
