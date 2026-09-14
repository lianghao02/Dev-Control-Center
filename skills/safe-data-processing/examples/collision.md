# 同名衝突處置代碼範例 (Examples: Collision Handling)

```csharp
using System.IO;

public static class CollisionResolver
{
    public static string ResolveUniquePath(string destinationPath)
    {
        if (!File.Exists(destinationPath)) return destinationPath;

        string directory = Path.GetDirectoryName(destinationPath)!;
        string fileNameWithoutExt = Path.GetFileNameWithoutExtension(destinationPath);
        string extension = Path.GetExtension(destinationPath);

        int counter = 1;
        string newPath;
        do
        {
            newPath = Path.Combine(directory, $"{fileNameWithoutExt} ({counter}){extension}");
            counter++;
        } while (File.Exists(newPath));

        return newPath;
    }
}
```
