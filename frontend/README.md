# frontend

A new Flutter project.

## Add Custom Icons

1. Open https://www.fluttericon.com
2. Upload custom SVG icons & select the icons (by clicking on them)
3. Choose a meaningful name (e.g. IngoIcons)
4. When all necessary icons are uploaded -> click on download -> the result is a zip folder with several files
5. import the .ttf file into a folder in the assets (folder icons)
6. place the .dart class inside your lib folder
7. add this to the pubspec.yaml file:

```yaml
fonts:
  - family: IngoIcons
    fonts:
      - asset: assets/icons/IngoIcons.ttf
```
