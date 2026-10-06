"""建立獨立合成驗收包；使用既有專案環境，不安裝套件或讀取使用者資料。"""
from __future__ import annotations

import argparse
from dataclasses import asdict
from datetime import datetime
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys
from types import SimpleNamespace
from unittest.mock import patch
import uuid
import zipfile

CENTER = Path(__file__).resolve().parents[2]
WORKSPACE = CENTER.parent


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2), encoding="utf-8")


def hashes(folder):
    return {str(p.relative_to(folder)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in folder.rglob("*") if p.is_file()}


def generate_media(root):
    import av
    import numpy as np
    from PIL import Image, ImageDraw, ImageFilter
    from clipmask.ai.subtitles import SubtitleManager, SubtitleItem
    from clipmask.ai.vad import VoiceActivityDetector
    from clipmask.export.exporter import FastCopyExporter, RenderExporter
    from clipmask.media.source import VideoSource
    from clipmask.models.project import ProjectState, Track, Keyframe, MaskConfig, WorkRange

    photos = root / "10_照片" / "來源"
    photos.mkdir(parents=True)
    image = Image.new("RGB", (640, 480), "#c8dfdb")
    draw = ImageDraw.Draw(image)
    for x in range(0, 640, 16):
        draw.line((x, 0, 640-x, 479), fill="#153d52", width=3)
    exif = Image.Exif()
    exif[306] = "2024:06:15 10:30:00"
    image.save(photos / "清晰照片.jpg", exif=exif)
    shutil.copyfile(photos / "清晰照片.jpg", photos / "完全重複.jpg")
    image.filter(ImageFilter.GaussianBlur(18)).save(photos / "模糊照片.jpg", exif=exif)
    Image.new("RGB", (540, 1080), "#fff3cc").save(photos / "螢幕截圖.png")
    for folder, color in (("同名甲", "red"), ("同名乙", "blue")):
        (photos / folder).mkdir()
        Image.new("RGB", (640, 480), color).save(photos / folder / "同名照片.jpg", exif=exif)
    for path in list(photos.rglob("*")):
        if path.is_file():
            write_json(path.with_name(path.name + ".json"), {
                "title": path.name, "description": "純合成驗收素材",
                "photoTakenTime": {"timestamp": "1718418600"}})
    takeout = root / "10_照片" / "合成 Takeout.zip"
    with zipfile.ZipFile(takeout, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in photos.rglob("*"):
            if path.is_file():
                archive.write(path, "Takeout/Google Photos/" + path.relative_to(photos).as_posix())

    media = root / "12_影片"
    media.mkdir()
    source_path = media / "合成 測試影片.mp4"
    container = av.open(str(source_path), "w")
    video = container.add_stream("h264", rate=15)
    video.width, video.height, video.pix_fmt = 640, 360, "yuv420p"
    audio = container.add_stream("aac", rate=16000)
    audio.layout = "mono"
    for i in range(90):
        frame_image = np.full((360, 640, 3), (185, 215, 205), dtype=np.uint8)
        # 細紋方塊用來檢查遮罩；不是人臉，不宣稱測得真人辨識準確率。
        for x in range(180, 300, 4):
            frame_image[90:210, x:x+2] = (5, 5, 5)
        frame_image[25:50, 10+i*4:35+i*4] = (200, 40, 30)
        frame = av.VideoFrame.from_ndarray(frame_image, format="rgb24")
        for packet in video.encode(frame):
            container.mux(packet)
    times = np.arange(6 * 16000) / 16000
    samples = (0.25 * np.sin(2*np.pi*440*times)).astype(np.float32)
    samples[(times < 1) | ((times >= 2.5) & (times < 4)) | (times >= 5)] = 0
    for start in range(0, len(samples), 1024):
        chunk = samples[start:start+1024]
        frame = av.AudioFrame.from_ndarray(chunk.reshape(1, -1), format="fltp", layout="mono")
        frame.sample_rate, frame.pts, frame.time_base = 16000, start, Fraction(1, 16000)
        for packet in audio.encode(frame):
            container.mux(packet)
    for stream in (video, audio):
        for packet in stream.encode():
            container.mux(packet)
    container.close()
    before = hashes(media)
    source = VideoSource(str(source_path))
    project = ProjectState(source=source.metadata, work_range=WorkRange(0, 6), tracks=[
        Track(id="synthetic", label="合成細紋方塊", reviewed=True,
              mask=MaskConfig(strength=20, padding=0), keyframes=[
                  Keyframe(time=0, rect_px=(180, 90, 120, 120)),
                  Keyframe(time=6, rect_px=(180, 90, 120, 120))])],
        subtitles=[SubtitleItem(id=1, start_sec=1, end_sec=2.5, text="合成測試字幕")])
    source.close()
    write_json(media / "專案狀態.json", json.loads(project.to_json()))
    assert SubtitleManager.generate_srt_file(project.subtitles, str(media / "合成字幕.srt"))
    assert SubtitleManager.parse_srt_file(str(media / "合成字幕.srt"))[0].text == "合成測試字幕"
    redacted = media / "已驗證 遮罩字幕.mp4"
    assert RenderExporter.render_export(project, str(redacted))
    cut = media / "已驗證 快速剪輯.mp4"
    assert FastCopyExporter.export(str(source_path), 0, 3, str(cut))
    decoded = {}
    for path in (source_path, redacted, cut):
        with av.open(str(path)) as c:
            count = sum(1 for _ in c.decode(video=0))
            duration = c.duration / av.time_base
        with av.open(str(path)) as c:
            audio_count = sum(f.samples for f in c.decode(audio=0))
        assert count > 0 and audio_count > 0
        decoded[path.name] = {"影格": count, "音訊樣本": audio_count, "秒數": duration}
    with av.open(str(source_path)) as c:
        original = next(c.decode(video=0)).to_ndarray(format="rgb24")
    with av.open(str(redacted)) as c:
        masked = next(c.decode(video=0)).to_ndarray(format="rgb24")
    assert masked[95:205, 185:295].std() < original[95:205, 185:295].std() * 0.5
    segments = VoiceActivityDetector.scan_audio_speech_segments(str(source_path))
    assert segments, "音量活動標記未產生區間"
    assert before[source_path.name] == hashes(media)[source_path.name]
    write_json(root / "media-results.json", {
        "檔案": decoded, "音量活動": [asdict(s) for s in segments],
        "來源未變": True, "遮罩細紋降低": True,
        "限制": "音軌為音調而非真人語音；方塊不是人臉。"})


def check_photos(root):
    from main import DateParser, WinShellReader
    from smart_photo_organizer.v3_pipeline import AnalysisOptions, V3Pipeline

    source_root = root / "10_照片"
    before = hashes(source_root)
    results = {}
    for mode, source in (("folder", source_root / "來源"),
                         ("takeout_zip", source_root / "合成 Takeout.zip")):
        shell = WinShellReader()
        pipeline = V3Pipeline(str(source), str(root / "10_分析輸出" / mode),
                              mode, shell, DateParser())
        try:
            summary = pipeline.analyze(AnalysisOptions(short_video_enabled=False))
            assert not summary.errors, summary.errors
            assert summary.media_group_count == 6, asdict(summary)
            assert summary.category_counts.get("DUPLICATE", 0) >= 1, asdict(summary)
            assert summary.category_counts.get("SCREENSHOT", 0) >= 1, asdict(summary)
            preview = pipeline.preview_archive()
            results[mode] = {"分析": asdict(summary), "歸檔預覽": asdict(preview)}
        finally:
            pipeline.close()
            shell.stop()
    assert before == hashes(source_root), "照片或 ZIP 來源發生變更"
    write_json(root / "photo-results.json", {"流程": results, "來源未變": True,
        "正式 Shell": True,
        "限制": "使用正式 WinShellReader；實體搬移及完整滑鼠操作尚未驗收。"})


def check_chain(root):
    from chain_fund_tracer.controller import Controller
    from chain_fund_tracer.history import save_history_entry, load_history_snapshot
    from chain_fund_tracer.models import AnalysisResult, TraceStep, Transfer
    import socket
    folder = root / "15_離線圖譜"
    folder.mkdir()
    history = folder / "history"
    history.mkdir()
    steps = []
    for i in (1, 2):
        steps.append(TraceStep(direction="外部入金主路徑", hop=i,
            tx_hash="0x" + str(i)*64, timestamp=f"2024-06-15 10:0{i}:00 +0800",
            token="TEST", amount="100.000000", from_address="0x"+str(i)*40,
            to_address="0x"+str(i+1)*40, address="0x"+str(i)*40,
            classification="未知地址", label="虛構節點", label_source="合成測試",
            confidence="未知", relation="僅資金關聯", chain="Polygon"))
    result = AnalysisResult(query="合成測試（非真實案件）", network="Polygon",
        summary=["純合成驗收資料，未查詢鏈上 API。"], steps=steps,
        transfers=[Transfer(tx_hash=s.tx_hash, token=s.token, amount=s.amount,
            from_address=s.from_address, to_address=s.to_address) for s in steps],
        warnings=["所有地址、交易及金額均為虛構，不得作為案件證據。"])
    # 僅替換測試程序內的歷史目錄及對話框，正式程式及設定不變。
    with patch("chain_fund_tracer.history.get_history_dir", return_value=history), \
         patch.object(socket.socket, "connect", side_effect=AssertionError("離線驗收禁止連網")):
        entry = save_history_entry(result)
        restored = load_history_snapshot(entry.id)
        assert restored.to_dict() == result.to_dict()
        controller = Controller.__new__(Controller)
        controller._current_result = restored
        results = {}
        for kind, suffix in {"csv": ".csv", "txt": ".txt", "svg": ".svg",
                             "subpoena_csv": ".csv", "zip": ".zip", "agent_bundle": ".zip"}.items():
            path = folder / (kind + suffix)
            controller._window = SimpleNamespace(create_file_dialog=lambda *a, p=path, **k: (str(p),))
            response = controller.export_report(kind)
            assert response["success"], response
            assert path.stat().st_size > 0
            if suffix == ".zip":
                with zipfile.ZipFile(path) as archive:
                    assert archive.testzip() is None
            results[kind] = path.stat().st_size
    write_json(root / "chain-results.json", {"離線快照還原": True, "六格式輸出位元組": results,
        "限制": "正式案件歷史未讀寫，未測線上採集或真人身分判讀。"})


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage", choices=("media", "photo", "chain"))
    parser.add_argument("--root", type=Path)
    args = parser.parse_args()
    if args.stage:
        root = args.root.resolve()
        assert root.is_relative_to(CENTER / "artifacts" / "test-runs" / "synthetic-acceptance")
        assert (root / ".synthetic-pack").is_file()
        repo = WORKSPACE / {"media": "12_ClipMask-AI", "photo": "10_Smart-Photo-Organizer",
                            "chain": "15_chainflow-inspector"}[args.stage]
        sys.path[:0] = [str(repo), str(repo / "src")]
        {"media": generate_media, "photo": check_photos, "chain": check_chain}[args.stage](root)
        return
    root = CENTER / "artifacts" / "test-runs" / "synthetic-acceptance" / (datetime.now().strftime("%Y%m%d-%H%M%S") + "-" + uuid.uuid4().hex[:8])
    root.mkdir(parents=True, exist_ok=False)
    (root / ".synthetic-pack").write_text("純合成資料", encoding="utf-8")
    for stage, repo_name in (("media", "12_ClipMask-AI"), ("photo", "10_Smart-Photo-Organizer"),
                            ("chain", "15_chainflow-inspector")):
        interpreter = WORKSPACE / repo_name / ".venv" / "Scripts" / "python.exe"
        with (root / (stage + ".log")).open("w", encoding="utf-8") as log:
            subprocess.run([str(interpreter), "-X", "utf8", "-B", "-s", str(Path(__file__).resolve()),
                            "--stage", stage, "--root", str(root)], cwd=root, stdout=log,
                           stderr=subprocess.STDOUT, check=True, timeout=180)
    (root / "README.md").write_text("""# 合成驗收素材包

所有照片、影片、音軌、地址、交易與金額均為合成資料，沒有使用正式素材或案件。
本目錄在中央 artifacts/test-runs 內，不納入 Git；生成程式保存於 scripts/tests。

## 10 照片整理

以既有 RUN.bat 開啟專案，選擇本包的 `10_照片/來源`，或選擇 `10_照片/合成 Takeout.zip`。
輸出請選本包內另外新建的 `手動照片輸出`，不得與來源重疊。
預期共 6 組媒體與各自 sidecar；「清晰照片.jpg／完全重複.jpg」內容相同。
「同名甲／同名照片.jpg」與「同名乙／同名照片.jpg」分別為紅色與藍色，不能僅依檔名當成完全重複。
另有直向截圖與模糊照片。合成圖可能也被列為相似或模糊，這不代表真人照片分類準確率。
可查看報表、審核與歸檔預覽。若要實體整理，先複製本包來源作為可耗損工作副本。
本輪自動驗證僅分析及歸檔預覽，未搬移來源。
分析管線使用已修復的正式 WinShellReader；歷史逾時紀錄仍保存在中央報告，本次驗收另記錄實際結果。

## 12 影音

以既有啟動器開啟 ClipMask，載入 `12_影片/合成 測試影片.mp4`。
影片為 6 秒、640×360、15fps，有移動色塊及細紋方塊。
音軌在 1～2.5 秒及 4～5 秒播放音調，其餘靜音；音調用於驗證音量活動，不是語音辨識素材。
可於細紋方塊手動建立遮罩：x=180、y=90、寬=120、高=120，起訖 0～6 秒，巡看後確認。
加入 1～2.5 秒的「合成測試字幕」，再匯出至另外新檔名，比對已驗證的遮罩字幕與快速剪輯成品。
`合成字幕.srt` 可檢查字幕檔格式；`專案狀態.json` 是測試紀錄，不代表介面支援直接匯入該檔。
方塊不是人臉，不能拿「AI 沒偵測到臉」判定失敗。真人人臉、追蹤品質與完整滑鼠操作尚待驗收。

## 15 離線金流

`15_離線圖譜/svg.svg` 可直接用瀏覽器開啟查看虛構兩步金流。
CSV、TXT、調證 CSV、證據 ZIP、Agent 分析 ZIP 都由目前專案匯出器產生。
`history` 含可還原的合成歷史索引與快照；不得覆蓋正式專案的 history 或 settings.json。
本包沒有把虛構地址送到 RPC／Explorer；未驗證線上採集，也沒有把虛構標籤當成公開查核證據。
歷史還原及六種匯出已在隔離測試程序驗證，未宣稱正式介面已逐項點選。

## 驗證證據與限制

photo-results.json、media-results.json、chain-results.json 記錄實際檢查結果；SHA256.json 保存檔案雜湊。
視訊來源 90 影格；現行壓制匯出 89 影格、容器 6 秒，快速剪輯 45 影格、容器約 3.13 秒。
上述為實測數值，沒有將其宣稱為逐影格無損或任意切點精準匯出。
未修改業務程式、全域套件、虛擬環境或發布包；未 Commit／Push。
Win10、乾淨電腦、免安裝成品及真人辨識仍需獨立驗證。
""", encoding="utf-8")
    write_json(root / "SHA256.json", hashes(root))
    print(root)


if __name__ == "__main__":
    main()
