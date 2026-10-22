# 跨專案拆分後交付結果（2026-10-22）

## 交付範圍
使用者明確授權後，依專案與分支分開提交推送。19 未動，未升版、建立 Release、合併或刪除分支。

| 專案／分支 | 提交 | 結果 |
|---|---|---|
| 13 Project-Hub／main | 8100419277a2613935300c4e929252c2be3a9338 | 五張無損 WebP、引用與交接，推送成功 |
| 16 正式版／master | 5085622c33331652b19736054ab6755c5f7e2b54 | 三組狀態回歸測試與交接，推送成功 |
| 16 beta／feat/jianghu-adventure | 9713f8c919e48b93202b267c4c4613fa95124e56 | 分支審查與交接，推送成功 |
| 18 AromaCraft-Studio／main | 89b6e0d42ac167187f586ceba499fed0496a9bd7 | 交接狀態更正，推送成功 |
| 07 auto-learning-bot／main | be86f5ecec1fa17a999ecb17388bf90f84de4bf3 | 上游維護邊界與模組地圖，推送成功 |
| 15 chainflow-inspector／main | d92a9fe2b9f0b877050d11bffb5f7622942f846f | 未發布 CHANGELOG、README 與交接，推送成功 |
| 控制中心／main | 包含本報告之提交 | 保存計畫、驗收清單與最終交接；推送後狀態以 Git 為準 |

上述六個工作目錄在推送後確認無未提交變更，與各自追蹤分支差異 0／0；中央另於本報告提交後核對。

## 部署證據
- 13 Pages 成功：https://github.com/lianghao02/Project-Hub/actions/runs/39721901954 （head 8100419）。
- 18 Pages 成功：https://github.com/lianghao02/AromaCraft-Studio/actions/runs/39722060766 （head 89b6e0d）。
- 16 Pages 成功：https://github.com/lianghao02/16_Wuxia-Typing-Legend/actions/runs/39721976798 （head 5085622）。

## 13 正式站驗收
正式網址：https://lianghao02.github.io/Project-Hub/ 。下載回應逐位元組與已推送提交比較，7/7 一致，HTTP 200；五張 WebP 均為 image/webp。

| 檔案 | bytes | SHA-256 |
|---|---:|---|
| data/projects.json | 12779 | e649e1882885caa52d2273469b8ea2567175e5b5ceb89cb9f1606d3595c57691 |
| assets/js/main.js | 26743 | f316426f290afd327502097ad6dddbd955685cf74bc275dfbdf8dba9e6ebbe69 |
| banner_chainflow-inspector.webp | 2838570 | e870b0e28fdba67621eae3c5386ad2b907a7cb10994e35c857643cf05f4928a9 |
| banner_AromaCraft-Studio.webp | 2314760 | 0574da82efbd4b5e34f577962c029dd01eb24cbb99d430078ef10ea12cb315f1 |
| banner_Subscription-Manager.webp | 2295830 | 9bb30ac8114879bede1aaafb0481a563ab1223355bae8d599b18f3938de5a00c |
| banner_Google-Photos-Takeout-Organizer.webp | 2085064 | f3eb932f5d37b20214466e730cc5ce090ad9531d153aa2616b4a27d3ee8108da |
| banner_PaperSwitch.webp | 1344970 | 7a958d368561cb9e1c1ac663c547db3bd49d333a82d915e7ecafe78d45f1e529 |

圖片均位於 images/。五張合計 14,984,478 → 10,879,194 bytes，減少 4,105,284 bytes（27.40%）；RGBA 像素比對沿用本輪本機 5/5 一致證據。

正式網址真實瀏覽器確認：16 件作品顯示；搜尋「鏈流」得到 1 件；清除搜尋恢復；「玄鐵神兵」分類顯示 5 件；返回全部後五張 WebP 全部 complete=true、解碼尺寸正確；console error／warn 均為 0。沒有操作專案外連、登入或正式使用者資料。

## 其他驗證
- 16 新增測試後 npm test 97/97；產品程式與版本不變。正式站 index.html、package.json、src/adventure.js、src/engine/AdventureEngine.js 與已推送提交一致。
- 18 前輪本機重跑 98/98；本輪只更正文件。正式站 index.html、sw.js 與已推送提交一致。
- 15 本輪隔離匯出測試 5/5；只補文件，未重跑完整 GUI 或線上採集。
- 07 upstream 更新至 9360d7c0a，未採用上游程式、未大拆 app.py；模組測試路徑已核對，未重跑全套平台操作。
- 各提交前 diff --check 與本輪文件敏感字串檢查通過。

## 保留項目
1. 04 原生桌面畫面／操作驗收：缺少可用原生視窗觀察工具，未執行；設定標題為「照片清冊產生器」，版本另核對應用程式內顯示。
2. 02 舊版已安裝 PWA 的真實手機無損更新：未取得實體裝置，未執行。
3. 16 PWA、24 按鍵門檻、英文獎勵變更與備份題庫分級未採用；beta 與備份保留。
4. 07 上游候選需具體案例再挑選，沒有宣稱已同步所有上游功能。

實機步驟見 post-refactor-acceptance.md。以上未完成項目不影響本輪已授權的文件、測試與展示站圖片交付。
