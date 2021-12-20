using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class GenerateCloudWizard : ScriptableWizard
{
    public int width = 256;
    public int height = 256;

    public bool is_png_format = false;

    /// <summary>
    /// 云稀疏度
    /// </summary>
    [Range(0.0f, 1.0f)]
    public float cloud_emptiness = 0.45f;

    /// <summary>
    /// 云锐利度
    /// </summary>
    [Range(0.0f, 1.0f)]
    public float cloud_sharpness = 0.7f;

    public string out_file = "";

    [MenuItem("Tools/Cloud/Generate Texture")]
    static void GenerateCloudTexture()
    {
        ScriptableWizard.DisplayWizard<GenerateCloudWizard>("Generate Cloud Texture", "Generate");
    }

    void OnWizardUpdate()
    {
        helpString = "Generate Cloud Texture.";
        isValid = (width > 0) && (height > 0) && out_file.Length != 0;
    }

    void OnWizardCreate()
    {
        string _file = Application.dataPath + "/Scripts/Environment/" + out_file;
        this.GenerateCloud(_file);
    }

    private void GenerateCloud(string _file)
    {
        float[] _octave_weights = { 0.5f, 0.25f, 0.125f, 0.0625f };
        float _one_over_texture_width = 1.0f / width, _one_over_texture_height = 1.0f / height;
        float _scale = 2.0f;

        // 生成分形噪声值
        // 共生成四次噪声值，每次频率都会增强2倍，噪声值都会乘上权重值后，分别保存在rgba通道上
        Color[] _texture_pixels = new Color[width * height];
        for (int _octave = 0; _octave < 4; ++_octave)
        {
            float _xy_offset = Random.Range(15.0f, 25.0f);
            for (int _i = 0; _i < height; ++_i)
            {
                for (int _j = 0; _j < width; ++_j)
                {
                    float _noise = SimplexNoise.SeamlessNoise(_one_over_texture_width * _j, _one_over_texture_height * _i, _scale, _scale, _xy_offset);
                    _noise = (_noise * 0.5f + 0.5f) * _octave_weights[_octave];
                    _texture_pixels[width * _i + _j][_octave] = _noise;
                }
            }

            _scale *= 2.0f;
        }

        float _spacing = 1.0f / (cloud_sharpness - cloud_emptiness);
        for (int _i = 0; _i < _texture_pixels.Length; ++_i)
        {
            float _noise_pixel = _texture_pixels[_i].r + _texture_pixels[_i].g + _texture_pixels[_i].b + _texture_pixels[_i].a;
            _noise_pixel = Mathf.Clamp01((Mathf.Clamp(_noise_pixel, cloud_emptiness, cloud_sharpness) - cloud_emptiness) * _spacing);
            _texture_pixels[_i] = new Color(_noise_pixel, _noise_pixel, _noise_pixel, _noise_pixel);
        }

        // 创建云纹理对象
        Texture2D _cloud_texture = new Texture2D(width, height, TextureFormat.ARGB32, false);
        _cloud_texture.filterMode = FilterMode.Bilinear;
        _cloud_texture.wrapMode = TextureWrapMode.Repeat;
        _cloud_texture.SetPixels(_texture_pixels);
        _cloud_texture.Apply(false, false);

        // 导出纹理数据
        if (is_png_format)
        {
            byte[] bytes = _cloud_texture.EncodeToPNG();
            System.IO.File.WriteAllBytes(_file + ".png", bytes);
        }
        else
        {
            byte[] bytes = _cloud_texture.EncodeToJPG();
            System.IO.File.WriteAllBytes(_file + ".jpg", bytes);
        }
    }
}
