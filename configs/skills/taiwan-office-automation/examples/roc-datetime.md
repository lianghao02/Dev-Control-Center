# 民國日期與時間處理範例 (Examples: ROC Date & Time)

## 1. 範例轉換對照表
| 原始輸入字串 | 判定類型 | 解析結果 (ISO-8601) | 輸出民國顯示格式 |
| :--- | :--- | :--- | :--- |
| `114/09/05` | 民國斜線格式 | `2025-09-05` | `民國 114 年 9 月 5 日` |
| `1140905` | 民國 7 碼緊湊字串 | `2025-09-05` | `114/09/05` |
| `891231` | 民國 6 碼歷史資料 | `2000-12-31` | `89/12/31` |
| `130700` | 緊湊 6 碼時間戳 | `13:07:00` | `13:07:00` |
| `090530` | 帶前導零時間戳 | `09:05:30` | `09:05:30` |
| `9990101` | 非法/超界日期 | 無法解析 | `[警告：格式不符原值保留] 9990101` |

## 2. Python 處理代碼範例片段
```python
import re
from datetime import date, time

def parse_roc_date(raw_str: str) -> date | None:
    raw = raw_str.strip()
    # 匹配 1140905 或 114/09/05
    m = re.match(r"^(\d{2,3})[/\.\-]?(\d{2})[/\.\-]?(\d{2})$", raw)
    if not m:
        return None
    roc_year, month, day = int(m.group(1)), int(m.group(2)), int(m.group(3))
    ce_year = roc_year + 1911
    try:
        return date(ce_year, month, day)
    except ValueError:
        return None
```
