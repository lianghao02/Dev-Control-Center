# 複製優先架構實作範例 (Examples: Copy First)

```python
import shutil
from pathlib import Path

def safe_copy_file(src: Path, dst_dir: Path, collision_policy: str = "suffix") -> Path:
    """以唯讀方式將 src 複製至 dst_dir，支援衝突處理。"""
    if not src.is_file():
        raise FileNotFoundError(f"來源檔案不存在: {src}")
    
    dst_dir.mkdir(parents=True, exist_ok=True)
    target = dst_dir / src.name
    
    # 衝突處理
    if target.exists():
        if collision_policy == "skip":
            return target
        elif collision_policy == "suffix":
            counter = 1
            while target.exists():
                target = dst_dir / f"{src.stem} ({counter}){src.suffix}"
                counter += 1
                
    # 執行複製（保留修改時間等中繼資料）
    shutil.copy2(src, target)
    
    # 驗證檔案大小
    if target.stat().st_size != src.stat().st_size:
        target.unlink(missing_ok=True)
        raise IOError(f"寫入校驗失敗：大小不一致 ({src} -> {target})")
        
    return target
```
