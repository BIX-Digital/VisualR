using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEditor;

public sealed class IOSPostBuildProcessor
{
    public static bool enableBitcode = false;
    public static bool skipInstall = true;

    [PostProcessBuildAttribute]
    public static void OnPostprocessBuild(BuildTarget target, string pathToBuiltProject)
    {
        switch (target)
        {
            case BuildTarget.iOS:
                Setup(pathToBuiltProject);
                break;
            default:
                break;
        }
    }

    private static void Setup(string pathToBuiltProject)
    {
        var project = new PBXProject();
        var pbxPath = PBXProject.GetPBXProjectPath(pathToBuiltProject);
        project.ReadFromFile(pbxPath);
        SetupFramework(project);
        SetupMain(project);
        project.WriteToFile(pbxPath);
    }

    private static void SetupFramework(PBXProject project)
    {
        Setup(project, project.GetUnityFrameworkTargetGuid());
    }

    private static void SetupMain(PBXProject project)
    {
        Setup(project, project.GetUnityMainTargetGuid());
    }

    private static void Setup(PBXProject project, string targetGUID)
    {
        project.SetBuildProperty(targetGUID, "ENABLE_BITCODE", enableBitcode ? "YES" : "NO");
        project.SetBuildProperty(targetGUID, "SKIP_INSTALL", skipInstall ? "YES" : "NO");
    }
}
