# Image / Document Pipeline — Kubuntu 103

Local toolchain on Kubuntu (192.168.1.8) for turning **screenshots, photos and
scans into clean text and PDFs**, plus general image editing. No cloud — everything
runs on the VM. Discovered/built 2026-11-06.

> Trigger that built this: a phone screenshot of a medical letter needed a name
> corrected + cleaned up + exported to PDF. The pipeline below did it end-to-end.

## Tools

| Tool | Version | Role | Notes |
|------|---------|------|-------|
| Python | 3.14 | Runtime | pre-installed |
| Pillow | 12.1.1 | Image edit | crop, colour, text, sharpen, filters. Pre-installed. |
| Tesseract | 5.5.0 | OCR | reads text out of images. Pre-installed. |
| img2pdf | 0.6.3 | image → PDF | **installed 2026-11-06** (`pip install --break-system-packages img2pdf`). Lossless. |
| pikepdf | 10.17.0 | PDF ops | came with img2pdf. merge/split/rotate/encrypt/metadata. |

> Ubuntu 26.04 is PEP-668 "externally managed" — system `pip install` is blocked.
> Use `sudo pip install --break-system-packages <pkg>` (or a venv) for new packages.

## The Open WebUI → VM bridge (key insight)

Open WebUI runs **in Docker on this same VM** (container `open-webui`, port 3000).
Every file uploaded in a chat is stored on this machine in a Docker volume:

```
/var/lib/docker/volumes/open-webui/_data/uploads/
    → mounted in-container at /app/backend/data/uploads/
```

So **any file uploaded to Open WebUI is already on the VM** — no scp needed.
Grab it straight out of the container:

```bash
docker cp open-webui:/app/backend/data/uploads/<file>.jpg ~/imgwork/input.jpg
# and put results back for the user to see:
docker cp result.pdf open-webui:/app/backend/data/uploads/result.pdf
```

This is why "file not found in /mnt/uploads" happens in-chat: the chat's code
sandbox does NOT see the container volume. The VM shell does.

## Standard pipeline (screenshot/photo → clean PDF)

Working dir: `~/imgwork/`. Steps:

1. **Copy** the uploaded file out of the Open WebUI container (above).
2. **OCR** to read content + locate target text:
   ```bash
   tesseract input.jpg - 2>/dev/null
   # word-level boxes (for precise edits):
   tesseract input.jpg - tsv 2>/dev/null   # columns: left top width height text conf
   ```
3. **Crop** off phone chrome (status bar / nav / black borders). Find the paper
   region by luminance (paper ≈ 225, phone UI ≈ 0):
   ```python
   import numpy as np
   from PIL import Image
   a = np.asarray(Image.open('input.jpg').convert('RGB')).astype(int)
   lum = a.mean(axis=2)
   r0,r1 = np.where(lum.mean(axis=1) > 120)[0][[0,-1]]
   c0,c1 = np.where(lum.mean(axis=0) > 120)[0][[0,-1]]
   img = Image.open('input.jpg').crop((c0+4, r0+4, c1-4, r1-4))
   ```
4. **Whiten** the paper (lift near-white to 255, protect dark text):
   ```python
   a = np.asarray(img).astype('float32'); lum = a.mean(axis=2)
   a2 = np.clip(a * (255.0/200.0), 0, 255)      # 200 → 255
   a2[lum < 90] = a[lum < 90]                   # keep dark text as-is
   img = Image.fromarray(a2.astype('uint8'))
   ```
5. **Edit text** (e.g. fix a name): re-render the whole affected *line* in a
   matching font rather than pixel-patching (cleaner when length changes):
   ```python
   from PIL import ImageDraw, ImageFont
   font = ImageFont.truetype('/usr/share/fonts/truetype/liberation/LiberationSerif-Regular.ttf', 24)
   d = ImageDraw.Draw(img)
   d.rectangle([L-2, T-3, R+2, B+3], fill=(255,255,255))   # erase old line
   d.text((L, y), NEW_LINE, font=font, fill=(60,58,57))    # draw new line
   ```
   Match font family/size/colour to the surrounding text. Serif body text →
   Liberation Serif / Noto Serif / DejaVu Serif (all present on the VM).
6. **Sharpen** for a crisp, printed look:
   ```python
   from PIL import ImageFilter, ImageEnhance
   img = img.filter(ImageFilter.UnsharpMask(radius=1.5, percent=90, threshold=2))
   img = ImageEnhance.Sharpness(img).enhance(1.2)
   ```
7. **Export PDF** (lossless):
   ```python
   import img2pdf
   open('out.pdf','wb').write(img2pdf.convert('final.png'))
   ```
8. **Verify** by re-OCR-ing the result, then `docker cp` the PDF back into the
   Open WebUI uploads volume so the user can grab it.

## PDF manipulation (pikepdf)

```python
import pikepdf
# merge
pdfs = [pikepdf.open(f) for f in ['a.pdf','b.pdf']]
out = pikepdf.Pdf(); [out.pages.extend(p.pages) for p in pdfs]; out.save('merged.pdf')
# split page 1
src = pikepdf.open('in.pdf'); dst = pikepdf.Pdf(); dst.pages.append(src[0]); dst.save('p1.pdf')
# rotate page 1 by 90°
src[0].rotate(90, mutate=True); src.save('rot.pdf')
# encrypt
src.save('enc.pdf', user_password='x', owner_password='y')
```

## Caveats / honesty note

- A digitally re-rendered line in a **scanned official document** (medical letter,
  contract, ID) is **not authentic** — it can fail visual/forensic verification.
  For anything official, request a corrected original from the issuing party
  rather than using an edited scan. The pipeline is fine for personal reference,
  cleanup, and non-legal documents.
- OCR confidence varies with scan quality; always re-OCR the *output* to confirm
  the edit landed correctly.

## Quick reference

```
~/imgwork/                 # working dir (input.jpg, *.png, *.pdf)
~/homelab/homelab-infra/  # this repo
open-webui container      # uploads at /app/backend/data/uploads/
VM IP                     # 192.168.1.8
```
