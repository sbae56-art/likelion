# 🦷 OraQ - Oral Health AI Diagnosis App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white"/>
  <img src="https://img.shields.io/badge/TensorFlow-FF6F00?style=flat-square&logo=tensorflow&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white"/>
</div>

## 📌 Project Overview
**OraQ**는 인공지능 영상 분석을 통해 사용자의 구강 사진을 분석하고, 위험도(Risk / Caution / Normal)를 예측하여 스마트한 구강 건강 가이드를 제공하는 애플리케이션입니다.

멋쟁이사자처럼(Likelion) 프로젝트의 일환으로 제작되었으며, Flutter를 통한 크로스 플랫폼 클라이언트와 FastAPI/TensorFlow로 강력한 진단 추론 서버를 제공합니다.

---

## 🏗 System Architecture

OraQ 프로젝트의 전체 시스템 아키텍처 다이어그램입니다.

```mermaid
graph TD
    classDef frontend fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef backend fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    classDef ai fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px;
    classDef db fill:#FCE4EC,stroke:#C2185B,stroke-width:2px;
    classDef auth fill:#F3E5F5,stroke:#4A148C,stroke-width:2px;

    %% Client Side
    subgraph Client ["Client (oral_health_ai - Flutter)"]
        UI_Auth["로그인 / 회원가입 UI"]:::frontend
        UI_Profile["프로필 정보 UI"]:::frontend
        UI_Scan["구강 사진 업로드 UI"]:::frontend
        UI_History["분석 이력 및 리포트 UI"]:::frontend
    end

    %% External Auth
    GoogleAuth["Google OAuth 2.0"]:::auth

    %% Server Side
    subgraph Backend ["Backend API (FastAPI)"]
        Router_Auth["Auth Router (/auth)"]:::backend
        Router_User["User Router (/users)"]:::backend
        Router_Scan["Scan Router (/scans)"]:::backend
        
        JWT["JWT Authentication"]:::backend
        Preprocess["이미지 전처리 224x224 정규화"]:::backend
    end

    %% TF Model
    subgraph AIModel ["AI Inference Engine"]
        TF["TensorFlow Keras Model (model_exp03b_saved)"]:::ai
    end

    %% Database
    subgraph DB_Layer ["Database (SQLite)"]
        T_Users["Users Table"]:::db
        T_Scans["Scans Table"]:::db
    end

    %% Connections - Auth
    UI_Auth -->|"1. 로그인 / 가입 요청"| Router_Auth
    UI_Auth -.->|"Google 소셜 로그인 토큰 발급"| GoogleAuth
    GoogleAuth -.->|"ID Token 유효성 검증"| Router_Auth
    Router_Auth -->|"2. JWT 토큰 발급"| JWT
    Router_Auth -->|"DB 사용자 동기화"| T_Users
    
    %% Connections - Application Flow
    UI_Profile -->|"나이, 성별, 신체정보 등 등록"| Router_User
    Router_User -->|"유저 정보 CRUD"| T_Users
    
    UI_Scan -->|"API 인증 + 구강 이미지 Multipart 전송"| Router_Scan
    Router_Scan -->|"이미지 데이터 추출"| Preprocess
    Preprocess -->|"Tensor Array"| TF
    TF -->|"구강 건강 위험도 Probability 도출"| Router_Scan
    Router_Scan -->|"진단 리포트 및 가이드라인 DB 저장"| T_Scans
    
    UI_History -->|"과거 분석 이력 조회"| Router_Scan
    Router_Scan -->|"이력 쿼리"| T_Scans
    
    T_Users -->|"1 : N 관계"| T_Scans
```

---

## 💻 Tech Stack 종합

### Frontend (App)
*   **Framework**: Flutter (Dart)
*   **Platforms**: Web, iOS, Android 지원

### Backend (API Server)
*   **Framework**: FastAPI (Python)
*   **Auth**: JSON Web Tokens (JWT) & Google OAuth2
*   **Database**: SQLite (`oraq_app.db`) + SQLAlchemy ORM
*   **Deployment**: Local Backend 및 Hugging Face Spaces 대응 구조

### AI / Data Science
*   **Model Format**: TensorFlow 2.x `SavedModel` (`model_exp03b_saved`)
*   **Image Processing**: Pillow & Numpy 연산을 통한 224x224 RGB 정규화 (전처리)

---

## 📂 Repository Structure

```text
likelion/
├── backend/                  # 로컬 환경용 FastAPI 백엔드 (메인)
│   ├── main.py               # 진입점 및 전체 API 라우터
│   ├── model_exp03b_saved/   # TensorFlow 서빙 가능 AI 모델
│   └── oraq_app.db           # SQLite DB
├── hf_oraq_backend/          # Hugging Face 클라우드 배포용 구성
│   ├── app.py                # 포팅된 API 서버
│   └── Dockerfile            # 클라우드 호환을 위한 컨테이너라이징
├── oral_health_ai/           # 애플리케이션 프론트엔드 (Flutter)
│   ├── lib/                  # Dart UI 비즈니스 로직
│   └── pubspec.yaml          # 패키지 매니저
└── docs/                     # 프론트엔드 Web 정적 빌드 결과물 (GH Pages 배포용)
```
