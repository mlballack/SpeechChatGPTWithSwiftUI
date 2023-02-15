# SpeechChatGPTWithSwiftUI
SwiftUIとGPT-3を利用したChatGPTのような音声対話アプリです。

<img width="250" src="https://user-images.githubusercontent.com/77086210/218990125-3ddfca76-3f94-4f99-a495-5b8e278ef5d2.gif">

## アプリの仕組み
アプリの仕組みとしては、
1. 音声入力をする（`AVAudioEngine`）
1. 入力データを音声認識でテキスト化する（`SFSpeechRecognizer`）
1. 認識結果をOpenAIのAPIに渡す
1. OpenAIのAPIからレスポンスを画面に表示し、読み上げる（`AVSpeechSynthesizer`）

といった流れで、音声を介してChatGPTのような対話をしているように見せています。

## Requirements
### 動作環境
- iOS 16

### 開発者の環境
- macOS Monterey 12.6
- Xcode 14.2
- Swift 5.7

## References
##### 【音声録音】
- [WebSocket + AVAudioEngineを駆使してApple Watchでリアルタイム音声認識してみた](https://amivoice-tech.hatenablog.com/entry/2021/06/14/123000)
##### 【音声認識】
- [WebSocket + AVAudioEngineを駆使してApple Watchでリアルタイム音声認識してみた](https://amivoice-tech.hatenablog.com/entry/2021/06/14/123000)
- [iOS App Dev Tutorials - Transcribing speech to text](https://developer.apple.com/tutorials/app-dev-training/transcribing-speech-to-text)
- [【Xcode】【SwiftUi】簡単！音声認識（文字起こし）（リアルタイム）](https://note.com/moss_it/n/n7e30658d3a4e)
##### 【音声合成】
- [【Swift5】 iOSで利用できる標準の音声合成(AVSpeechSynthesizer)の使い方のメモ](https://qiita.com/maKunugi/items/dc9da201a663c8773c8c)
##### 【ChatGPT / GPT-3】
- [OpenAI - Documents - API Reference - Completions](https://platform.openai.com/docs/api-reference/completions)
- [GitHub - OpenAISwift](https://github.com/adamrushy/OpenAISwift)
- [【Xcode/Swift】SwiftUIでChatGPTを使う方法](https://ios-docs.dev/swiftui-chatgpt/)
- [ChatGPTを使ったアプリ(サービス)、ChatGPTじゃない説](https://qiita.com/Tyamamoto1007/items/464e142c2d88d314ab6c)
- [この記事はすべてAIが書いています。](https://qiita.com/minorun365/items/a830ba65158c7df688d6)
- [ChatGPTにコードレビューしてもらったらサンドバッグにされた件](https://qiita.com/gon_kojiri/items/87e9562c0d8a0d37341a)
- [ChatGPTが出たのでVRChatに音声対話型AI Botを作った。](https://qiita.com/GesonAnko/items/3789e87ff30a3a08e3dd)
- [【GPT-3】PythonでGPT-3を用いてChatGPT風のコマンドラインツールを作ろう！](https://aiacademy.jp/media/?p=3559)
