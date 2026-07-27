# pinyinapp

An offline-first Mandarin dictionary built with Flutter. Search by hanzi or by pinyin (with or
without tone marks) against a CC-CEDICT database bundled as a SQLite asset; the detail screen shows
tone-colored pinyin, plays the pronunciation, and translates the term. Favorites and history are
stored on device with Hive.

The dictionary works with no network. Translation and audio are the only online features.

## Setup

Beyond `flutter pub get`, there are two steps:

### 1. Generate the dictionary database

`assets/dictionary/cedict.sqlite` is **generated, not committed**. Download CC-CEDICT from
<https://www.mdbg.net/chinese/dictionary?page=cc-cedict>, unzip `cedict_ts.u8` into `tool/`, then
run:

```sh
dart run tool/build_dictionary.dart
```

An alternative source path can be passed as the first argument. Without the asset the app still
opens, but every search returns empty.

### 2. Google Cloud Translation API key

The key is read at compile time, via `--dart-define`:

```sh
flutter run --dart-define=GOOGLE_TRANSLATE_API_KEY=xxx
```

Without it the app runs and the dictionary works; only the translation on the detail screen shows
an error.

**Security note:** a `--dart-define` key ends up embedded in the binary and can be extracted from
a distributed APK. Restrict it in the Google Cloud Console: application restriction for Android
(package name + SHA-1), API restriction to the Cloud Translation API only, and budget/quota alerts.
Never commit the key.

## Development

```sh
flutter analyze                 # static analysis + lints
flutter test                    # tests
flutter run                     # default device; also -d chrome, -d windows, -d android
flutter build apk               # also: windows, web
```

Requires Dart SDK `^3.12.0`.

## Credits

- Dictionary data: **CC-CEDICT**, licensed under Creative Commons Attribution-ShareAlike (CC BY-SA).
- Pronunciation audio: **Youdao Dictionary**.
- Translations: **Google Cloud Translation**.
