# 常見主執行緒阻塞錯誤與修正對比 (Examples: Blocking UI Anti-patterns)

## ❌ 錯誤寫法（UI 假死凍結）
```python
def on_start_button_clicked():
    # 直接在主執行緒執行大量影像轉換
    for img in image_list:
        convert_image(img) # 視窗出現「沒有回應」，無法拖曳或取消
```

## ✅ 正確寫法（工作緒 + 進度通知）
```python
from PySide6.QtCore import QThread, Signal

class ConvertWorker(QThread):
    progress = Signal(int, str)
    finished = Signal()

    def run(self):
        for idx, img in enumerate(image_list):
            if self.isInterruptionRequested():
                break
            convert_image(img)
            self.progress.emit(idx + 1, img.name)
        self.finished.emit()
```
