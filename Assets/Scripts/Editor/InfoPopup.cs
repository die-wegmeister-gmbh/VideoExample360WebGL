using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace Editor
{
    [InitializeOnLoad]
    public class InfoPopup : EditorWindow
    {
        static InfoPopup()
        {
            EditorApplication.playModeStateChanged += EditorApplicationOnplayModeStateChanged;
        }

        private static void EditorApplicationOnplayModeStateChanged(PlayModeStateChange obj)
        {
            if (obj != PlayModeStateChange.EnteredPlayMode) return;
            if (File.Exists(GameManagerDataSO._GameManagerDataSO.FilePath)) return;
            EditorApplication.isPaused = true;
            Init();
        }

        private bool tested = false;

        static void Init()
        {
            InfoPopup window = ScriptableObject.CreateInstance<InfoPopup>();
            window.position = new Rect(Screen.width / 2, Screen.height / 2, 750, 150);
            window.Show();
        }

        void OnGUI()
        {
            EditorGUILayout.LabelField("Please, for the love of god, link a valid mp4 file in the GameManager. \n" +
                                       $"Or place a file at: {GameManagerDataSO._GameManagerDataSO.FilePath}", EditorStyles.wordWrappedLabel);
            GUILayout.Space(70);
            if (GUILayout.Button("Stop Playmode NOW!1!"))
            {
                EditorApplication.isPlaying = false;
                this.Close();
            }
        }
    }
}