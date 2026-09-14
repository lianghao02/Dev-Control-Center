# 重複檔案多維度判定規範 (Duplicate Detection)

## 1. 嚴禁單純以檔名判定重複
- 檔名（如 `IMG_0001.jpg`、`新建文字文件.txt`、`未命名.xlsx`）在不同相機、目錄或設備極易重複。
- **嚴禁僅憑「檔名相同」就認定「內容重複」而直接跳過或刪除**。

## 2. 四級重複判定階梯
1. **Level 1: 檔案大小比對 (File Size)**：
   - 大小不同，100% 不是同一檔案，直接排除。
2. **Level 2: 前 4KB/8KB 頭尾快速 Hash (Fast Header/Tail Hash)**：
   - 針對大型多媒體檔案快速篩選，節省完整讀取 I/O。
3. **Level 3: 全檔案 SHA-256 雜湊 (Full Binary Hash)**：
   - 經 Level 1 與 2 命中後，進行全文 SHA-256 比對。雜湊相同則 100% 判定為完全重複檔案 (Exact Binary Duplicate)。
4. **Level 4: 中繼資料語意判定 (Perceptual / Metadata Duplicate)**：
   - 針對不同壓縮率或改名相片：比對 EXIF 拍攝時間戳（DateTimeOriginal）、相機型號與感知雜湊（pHash / dHash）。
   - 此類重複僅能標註為「高度疑似重複 (Likely Duplicate)」，**不可自動刪除**，需交由使用者審查確認。
