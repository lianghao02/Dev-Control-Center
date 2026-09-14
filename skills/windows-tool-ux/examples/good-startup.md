# 快速啟動與非同步初始化代碼範例 (Examples: Good Startup)

```csharp
public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        // 主視窗立即呈現，非同步進行耗時資源載入
        Loaded += async (s, e) => await InitializeInBackgroundAsync();
    }

    private async Task InitializeInBackgroundAsync()
    {
        StatusText.Text = "正在載入組態...";
        await Task.Run(() =>
        {
            // 耗時 I/O 置於背景緒
            Thread.Sleep(300); 
        });
        StatusText.Text = "就緒";
    }
}
```
