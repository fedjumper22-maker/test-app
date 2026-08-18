# Web-to-APK Universal Template

## What's in here
- `generate_webapk_template.sh` — scaffolds a complete new web-to-APK Android
  project (manifest, gradle files, MainActivity, GitHub Actions workflow)
  with the icon system wired correctly from the start.
- `validate_icons.sh` — standalone check that catches the common icon
  failure causes (bad PNGs, wrong names, missing manifest line) before build.
- `sample_icons/` — verified-valid placeholder PNGs at all 5 required sizes,
  ready to swap for your real icon.

## Usage for a brand new project
```bash
./generate_webapk_template.sh MyApp com.example.myapp https://yourwebsite.com
cp validate_icons.sh MyApp/
cp -r sample_icons/* MyApp/app/src/main/res/
cd MyApp
git init && git add . && git commit -m "Initial commit"
# push to GitHub, Actions will build automatically
```

Then just replace the PNGs inside `app/src/main/res/mipmap-*/ic_launcher.png`
with your real icon at the same 5 sizes — everything else is already wired.

## Usage for an EXISTING project (like your current repo)
Just copy `validate_icons.sh` into the repo root and add this to
`.github/workflows/build.yml` before your Gradle build step:
```yaml
- name: Validate icons
  run: |
    chmod +x ./validate_icons.sh
    ./validate_icons.sh
```
