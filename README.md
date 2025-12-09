# ChronoDash: Cyberpunk Style Interval Watch App

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white) ![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white) ![Provider](https://img.shields.io/badge/State-Provider-7952B3?logo=dailymotion&logoColor=white)

## 1. 프로젝트 개요

이 프로젝트는 Flutter의 `CustomPainter`와 애니메이션 제어를 깊이 있게 학습하기 위해 시작한 토이 프로젝트입니다.  
단순한 숫자로만 이루어진 기존의 타이머 앱에서 벗어나, **사이버펑크(Cyberpunk) 감성의 HUD 인터페이스**와 인터랙티브한 시각 효과를 도입하여 사용자에게 '마치 게임 속에서 달리는 듯한' 몰입감을 제공하는 것을 목표로 했습니다.

## 2. 주요 기능

- **Immersive HUD UI:** 디바이스의 모서리 곡률(`RRect`)에 완벽하게 맞춘 'Edge Neon Gauge'와 흔들림 없는 타뷸러(Tabular) 디지털 시계를 구현했습니다.
- **Dynamic Warp Effect:** 사용자의 현재 러닝 속도(Speed)에 따라 배경의 입자(Starfile) 이동 속도가 실시간으로 변하는 'Warp Speed' 효과를 제공합니다.
- **Interactive Workout Graph:** 전체 운동 흐름을 한눈에 볼 수 있는 그래프를 제공하며, 특정 구간을 터치하면 해당 시점으로 즉시 이동(Jump)할 수 있습니다.
- **Audio & Sensory Feedback:** `flutter_tts`를 활용한 로봇 음성 코칭("3, 2, 1, Go")과 적재적소의 햅틱 피드백(`HapticFeedback`)으로 운동 집중도를 높였습니다.
- **Data Visualization:** `TableCalendar`를 활용한 월간 'Mission Log'를 통해 운동 기록과 스트릭(Streak)을 관리할 수 있습니다.

## 3. 기술 스택 및 구현

- **언어:** Dart
- **프레임워크:** Flutter (v3.x)
- **핵심 구현 내용:**
  - **Advanced CustomPaint:** `PathMetrics`를 사용하여 단순 `Arc`가 아닌, 둥근 사각형(Rounded Rect) 경로를 따라 시계 방향으로 정확히 차오르는 프로그레스 바를 수학적으로 구현했습니다.
  - **Animation Optimization:** 메인 UI 스레드의 버벅임(Jank)을 방지하기 위해 배경 애니메이션 컨트롤러와 타이머 로직을 분리하여 최적화했습니다.
  - **State Management:** `Provider` 패턴을 사용하여 앱 전반의 타이머 상태(Running, Countdown, Finished)와 데이터 로직을 UI와 명확히 분리했습니다.
  - **UX Detail:** `FontFeature.tabularFigures()`를 적용하여 밀리초 단위의 빠른 숫자 변화에도 텍스트 너비가 흔들리지 않도록 디테일을 잡았습니다.

## 4. 개발 과정

- **총 소요 시간:** 약 24시간 (기획 및 디자인 포함)
- **목표:** 기본적인 Material Design 위젯에 의존하지 않고, 직접 캔버스(`Canvas`)에 그리는 커스텀 위젯 구현 능력과 복잡한 상태 관리(Timer + Audio + Animation) 능력을 함양하는 데 집중했습니다.

## 5. 로컬 개발 환경 설정

### 5.1. 사전 준비
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Android Studio 또는 VSCode

### 5.2. 프로젝트 설치
```sh
git clone https://github.com/Jay-Bang/ChronoDash.git
cd ChronoDash
```

### 5.3. 의존성 설치
```sh
flutter pub get
```

### 5.4. 앱 실행
```sh
flutter run
```

## 6. 실행 결과 (Screenshots)

| **Main (Flight Plan)** | **Running (HUD)** | **History (Mission Log)** |
|:---:|:---:|:---:|
| <!-- 이미지 링크 삽입 --> | <!-- 이미지 링크 삽입 --> | <!-- 이미지 링크 삽입 --> |
| 직관적인 운동 리스트 | 속도감 있는 워프 효과 | 월간 기록 캘린더 |

---
*Built with 💙 and ⚡️ in Flutter*
