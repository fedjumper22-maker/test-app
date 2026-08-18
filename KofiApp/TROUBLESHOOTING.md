# Web-to-APK Icon Troubleshooting — Complete Reference

Keep this file. If a future build ever fails after adding/changing icons,
work through this list top to bottom before asking anyone (human or AI) for help.

## The only 2 things that actually matter

1. **File format**: every `ic_launcher.png` must be a REAL png.
   Check with: `file app/src/main/res/mipmap-*/ic_launcher.png`
   Every line must say "PNG image data". If it says anything else
   (webp, HTML document, ASCII text, JPEG) — that file is renamed wrong
   and will break the build. Regenerate/re-export it properly.

2. **Manifest reference**: `AndroidManifest.xml` inside `<application>` must have:
   ```xml
   android:icon="@mipmap/ic_launcher"
   ```
   Check with: `grep 'android:icon' app/src/main/AndroidManifest.xml`

If both of those check out, your icon setup is correct, full stop.

## Required folder structure (never changes)

```
app/src/main/res/
├── mipmap-mdpi/ic_launcher.png     (48x48)
├── mipmap-hdpi/ic_launcher.png     (72x72)
├── mipmap-xhdpi/ic_launcher.png    (96x96)
├── mipmap-xxhdpi/ic_launcher.png   (144x144)
└── mipmap-xxxhdpi/ic_launcher.png  (192x192)
```

- Filename is always `ic_launcher.png`, all lowercase, no spaces.
- You technically only NEED one of these folders for the build to succeed
  (Android falls back), but include all 5 for icons to look sharp on every
  device.
- You do NOT need a `drawable/` folder, XML icon files, or `roundIcon`
  unless you're deliberately doing adaptive icons (you're not, for this
  template).

## Run this before every push (automated by validate_icons.sh)

```bash
./validate_icons.sh
```
This checks file validity, folder structure, and the manifest line
automatically, and fails loudly with the exact problem if something's wrong.

## If validate_icons.sh passes but the build STILL fails

At that point it is no longer an icon problem. Get the actual Gradle/AAPT
error text from the failed GitHub Actions run (Actions tab → failed run →
failed step → look for a red line with "error:" or "FAILED") and treat it
as a normal Gradle build error — most likely causes at that point are
`applicationId` mismatch, missing SDK version, or a dependency issue,
none of which are icon-related.

## Swapping in your real icon (per project)

1. Export your logo as a 1024x1024 PNG.
2. Resize to the 5 sizes above (any image tool, or Android Studio's
   Image Asset Studio if you have it installed) — keep the filename
   `ic_launcher.png` in every case.
3. Replace the placeholder files in `mipmap-*/` with your real ones.
4. Run `./validate_icons.sh` locally to confirm before pushing.
5. Commit, push, done.

## Starting a brand-new web-to-APK project (per project, ~5 min)

```bash
./generate_webapk_template.sh MyApp com.example.myapp https://yourwebsite.com
cp validate_icons.sh MyApp/
cp -r sample_icons/* MyApp/app/src/main/res/
cd MyApp
git init && git add . && git commit -m "Initial commit"
git remote add origin <your-new-empty-github-repo-url>
git push -u origin main
```
Then swap the placeholder icons for your real ones (steps above) and push again.
