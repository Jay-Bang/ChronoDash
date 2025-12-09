# ChronoDash: Cyberpunk Style Interval Watch App

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white) ![Provider](https://img.shields.io/badge/State-Provider-7952B3?logo=dailymotion&logoColor=white) ![Test](https://img.shields.io/badge/Test-Pass-green)

## 1. 프로젝트 개요

이 프로젝트는 Flutter의 `CustomPainter`와 정교한 애니메이션 제어, 그리고 완벽한 상태 관리를 학습하기 위해 제작된 고급 타이머 애플리케이션입니다.  
단순한 유틸리티 앱을 넘어, **사이버펑크(Cyberpunk) 감성의 HUD 인터페이스**와 몰입감 넘치는 인터랙션 경험(UX)을 제공하는 것을 목표로 했습니다.

## 2. 주요 기능 (Key Features)

### 🏃‍♂️ Immersive Workout HUD
- **Edge Neon Gauge:** 디바이스의 모서리 곡률(`RRect`)에 완벽하게 맞춘 진행 바를 `PathMetrics`로 수학적으로 계산하여 드로잉합니다.
- **Dynamic Warp Effect:** 현재 구간의 속도(Speed)에 반응하여 입자(Starfile)의 이동 속도가 실시간으로 변하는 'Warp Speed' 효과를 구현했습니다.
- **Cyberpunk Aesthetics:** 네온 글로우(Glow), `Orbitron` 폰트, 다크 모드 UI로 일관된 SF 분위기를 연출했습니다.

### 🛠️ Custom Program Editor
- **Drag & Drop Editing:** `ReorderableListView`를 사용하여 직관적으로 운동 루틴의 순서를 변경할 수 있습니다.
- **3D Time Picker:** iOS/Galaxy 스타일의 물리적 스크롤 경험을 주는 3D 휠 피커(`ListWheelScrollView`)를 직접 구현하여 시간 설정을 재미있게 만들었습니다.
- **Persistence:** 사용자가 커스텀한 프로그램은 `SharedPreferences`와 JSON 직렬화를 통해 영구 저장됩니다.

### 🌎 Professional Engineering 
- **Localization (i18n):** `flutter_localizations`를 사용하여 한국어(Ko)와 영어(En)를 완벽하게 지원합니다. 시스템 언어 설정에 따라 자동으로 전환됩니다.
- **Unit Testing:** 핵심 비즈니스 로직인 `TimerProvider`에 대해 `mockito`를 활용한 단위 테스트(Unit Test)를 작성하여 코드의 안정성을 검증했습니다.
- **Social Sharing:** `RepaintBoundary`를 활용하여 운동 기록(Mission Log) 화면을 이미지로 캡처하고, SNS에 공유할 수 있는 기능을 구현했습니다.

## 3. 기술 스택 및 구현 포인트

- **언어:** Dart
- **프레임워크:** Flutter (v3.x)
- **Architecture:** MVVM (Provider Pattern)
- **핵심 기술:**
  - **CustomPaint:** `Canvas` API와 `PathMetrics`를 활용한 고성능 커스텀 UI 드로잉.
  - **Animations:** `AnimationController`와 `TickerProvider`를 활용한 60FPS 부드러운 애니메이션.
  - **State Management:** `Provider`를 통한 의존성 주입(DI)과 로직 분리.
  - **Interaction:** `GestureDetector`와 `HapticFeedback`을 결합한 촉각적인 사용자 경험.

## 4. 로컬 개발 환경 설정

### 4.1. 사전 준비
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio 또는 VSCode

### 4.2. 프로젝트 설치
```sh
git clone https://github.com/Jay-Bang/ChronoDash.git
cd ChronoDash
```

### 4.3. 의존성 설치
```sh
flutter pub get
```

### 4.4. 테스트 실행
```sh
flutter test
```

### 4.5. 앱 실행
```sh
flutter run
```

## 5. 실행 결과 (Screenshots)

| **Flight Plan (Editor)** | **Running (HUD)** | **Mission Log (Share)** |
|:---:|:---:|:---:|
| <!-- 이미지 링크 삽입 --> | <!-- 이미지 링크 삽입 --> | <!-- 이미지 링크 삽입 --> |
| 3D Scroll Picker & Edit | Dynamic CustomPainter | Localization & Share |

---
*Built with 💙 by Jay Bang*
