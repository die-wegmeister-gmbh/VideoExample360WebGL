using System;
using System.IO;
using UnityEngine;

[CreateAssetMenu(fileName = "Data", menuName = "ScriptableObjects/GameManagerData", order = 1)]
public class GameManagerDataSO : ScriptableObject
{
    private static GameManagerDataSO _gameManagerDataSO;

    public static GameManagerDataSO _GameManagerDataSO
    {
        get
        {
            if (_gameManagerDataSO)
            {
                return _gameManagerDataSO;
            }
            else
            {
                Debug.LogError("GameManagerData does not exist!\n" +
                               "This could result in chaos and destruction!");
                return null;
            }
        }
        private set
        {
            if (_gameManagerDataSO == null || _gameManagerDataSO == value)
                _gameManagerDataSO = value;
            else
            {
                Debug.LogWarning($"Eather you changed the Data, or there are at least two active Datasets.\n " +
                                 $"Conflicts found at: \n" +
                                 $"{_gameManagerDataSO.name}\n" +
                                 $"and\n" +
                                 $"{value.name}", value);
                _gameManagerDataSO = value;
            }
        }
    }

    [SerializeField] private bool active;

    [SerializeField, Tooltip("While true: baseVideoPath gets set to (Application.streamingAssetsPath)")]
    private bool streamingAssets = true;

    [SerializeField] private string baseVideoPath;
    [SerializeField] private string folderPath;
    [SerializeField] private string fileName;

    public string BaseVideoPath => streamingAssets ? Application.streamingAssetsPath : baseVideoPath;
    public string FolderPath => folderPath;
    public string FileName => fileName;

    public string FilePath
    {
        get { return Path.Combine(BaseVideoPath, FolderPath, FileName); }
    }

    private void OnValidate()
    {
        if (active) _GameManagerDataSO = this;
    }

    [ContextMenu("TestPath")]
    void TestPath()
    {
        Debug.Log(FilePath);
    }

    public void Init() => _gameManagerDataSO = this;
}