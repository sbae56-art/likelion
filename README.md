# 🦷 OraQ - Oral Health AI Diagnosis App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/FastAPI-009688?style=flat-square&logo=fastapi&logoColor=white"/>
  <img src="https://img.shields.io/badge/TensorFlow-FF6F00?style=flat-square&logo=tensorflow&logoColor=white"/>
  <img src="https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white"/>
</div>

## 📌 Project Overview
**OraQ** is an intelligent application providing smart oral health guides by analyzing users' dental photos to predict risk levels (Risk / Caution / Normal).

Developed as part of the Likelion project, it features a cross-platform client built with Flutter and a powerful, reliable AI diagnosis backend powered by FastAPI and TensorFlow.

---

## 🏗 System Architecture

The overarching system architecture diagram for the OraQ project.

```mermaid
graph TD
    classDef frontend fill:#E3F2FD,stroke:#1565C0,stroke-width:2px;
    classDef backend fill:#E8F5E9,stroke:#2E7D32,stroke-width:2px;
    classDef ai fill:#FFF3E0,stroke:#EF6C00,stroke-width:2px;
    classDef db fill:#FCE4EC,stroke:#C2185B,stroke-width:2px;
    classDef auth fill:#F3E5F5,stroke:#4A148C,stroke-width:2px;

    %% Client Side
    subgraph Client ["Client (oral_health_ai - Flutter)"]
        UI_Auth["Login / Signup UI"]:::frontend
        UI_Profile["Profile Settings UI"]:::frontend
        UI_Scan["Oral Photo Upload UI"]:::frontend
        UI_History["Analysis History & Report UI"]:::frontend
    end

    %% External Auth
    GoogleAuth["Google OAuth 2.0 Provider"]:::auth

    %% Server Side
    subgraph Backend ["Backend API (FastAPI)"]
        Router_Auth["Auth Router (/auth)"]:::backend
        Router_User["User Router (/users)"]:::backend
        Router_Scan["Scan Router (/scans)"]:::backend
        
        JWT["JWT Authentication"]:::backend
        Preprocess["Image Preprocessor (224x224 Resize & Norm)"]:::backend
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
    UI_Auth -->|"1. Login/Signup Request"| Router_Auth
    UI_Auth -.->|"Request Google Mobile Token"| GoogleAuth
    GoogleAuth -.->|"Validate ID Token"| Router_Auth
    Router_Auth -->|"2. Issue JWT Token"| JWT
    Router_Auth -->|"Sync User Data"| T_Users
    
    %% Connections - Application Flow
    UI_Profile -->|"Update Profile (Age, Gender, Smoker, etc.)"| Router_User
    Router_User -->|"User Info CRUD"| T_Users
    
    UI_Scan -->|"API Auth Token + Multi-part Image"| Router_Scan
    Router_Scan -->|"Extract Image Bytes"| Preprocess
    Preprocess -->|"Normalized Tensor Array"| TF
    TF -->|"Return Risk Probability"| Router_Scan
    Router_Scan -->|"Save Diagnosis Report & Guide"| T_Scans
    
    UI_History -->|"Fetch Previous Scans"| Router_Scan
    Router_Scan -->|"Query History"| T_Scans
    
    T_Users -->|"1 : N Relationship"| T_Scans
```

---

## 💻 Tech Stack Summary

### Frontend (Application)
*   **Framework**: Flutter (Dart)
*   **Platforms**: Web, iOS, Android support

### Backend (API Server)
*   **Framework**: FastAPI (Python)
*   **Auth**: JSON Web Tokens (JWT) & Google OAuth2
*   **Database**: SQLite (`oraq_app.db`) + SQLAlchemy ORM
*   **Deployment**: Supports Local Backend and Hugging Face Spaces porting

### AI / Data Science
*   **Model Format**: TensorFlow 2.x `SavedModel` (`model_exp03b_saved`)
*   **Image Processing**: 224x224 RGB normalization using Pillow and Numpy operations

---

## 📂 Repository Structure

```text
likelion/
├── backend/                  # Local environment FastAPI backend (Main)
│   ├── main.py               # Entry point and global API router
│   ├── model_exp03b_saved/   # TensorFlow serving AI model directory
│   └── oraq_app.db           # SQLite DB for Users & Scans
├── hf_oraq_backend/          # Cloud deployment configuration for Hugging Face
│   ├── app.py                # Ported API Server
│   └── Dockerfile            # Containerization configuration
├── oral_health_ai/           # Cross-platform application frontend (Flutter)
│   ├── lib/                  # Dart UI & business logic
│   └── pubspec.yaml          # Package configurations
└── docs/                     # Static Web build output (for GitHub pages deployment)
```
