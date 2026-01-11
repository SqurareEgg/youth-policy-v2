# 청년 정책 교육 플랫폼 V2

청년들이 정책을 쉽게 학습하고 이수할 수 있는 교육 플랫폼입니다.

## 🚀 빠른 시작

```bash
# 의존성 설치
npm install

# 개발 서버 실행
npm run dev
# → http://localhost:9000

# 프로덕션 빌드
npm run build
```

## 📊 진도율 시스템

- 상세페이지 방문: 10%
- QnA 학습 완료: 20%
- 영상 학습 완료: 40%
- OX 퀴즈 통과: 30%
- **총 100% 달성 시 이수 완료**

## 🔧 기술 스택

- **Frontend**: Vue 3 + Quasar Framework v2
- **Backend**: Supabase (PostgreSQL + Auth)
- **State Management**: Pinia
- **Build**: Vite
- **Deploy**: Vercel

## 📁 프로젝트 구조

```
YouthV2/
├── src/
│   ├── pages/
│   │   ├── auth/          # 인증 페이지 (랜딩, 로그인, 회원가입)
│   │   ├── category/      # 카테고리 상세페이지
│   │   ├── learning/      # QnA/영상/퀴즈 페이지
│   │   └── IndexPage.vue  # 메인 (교육 선택)
│   ├── layouts/
│   │   └── MainLayout.vue # 메인 레이아웃
│   ├── router/
│   ├── boot/
│   │   └── supabase.js    # Supabase 설정
│   └── css/
├── supabase/
│   └── migrations/
│       └── 001_initial_schema.sql
└── .env                   # 환경 변수
```

## 🔑 Supabase 설정

### 1. 환경 변수 (`.env`)

```env
VITE_SUPABASE_URL=your_supabase_url_here
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 2. 데이터베이스 스키마

Supabase Dashboard → SQL Editor에서 실행:

```sql
supabase/migrations/001_initial_schema.sql
```

### 3. 이메일 인증 비활성화 (개발용)

Supabase Dashboard → Authentication → Settings:
- "Enable email confirmations" **체크 해제**
- 회원가입 후 바로 로그인 가능

## 📄 주요 페이지

| 페이지 | 경로 | 설명 |
|--------|------|------|
| 랜딩 | /landing | 로그인/회원가입 선택 |
| 로그인 | /auth/login | 이메일 로그인 |
| 회원가입 | /auth/register | 이메일 회원가입 (즉시 가입) |
| 메인 | /main | 6개 교육 카테고리 선택 |
| 카테고리 상세 | /category/:id | 학습 진도 및 메뉴 |
| QnA 학습 | /category/:id/qna | Q&A 아코디언 |
| 영상 학습 | /category/:id/video | YouTube 영상 |
| OX 퀴즈 | /category/:id/quiz | OX 퀴즈 (60점 이상 통과) |
| 프로필 | /profile | 마이페이지 (이수율 표시) |

## 🎯 6개 교육 카테고리

1. 📍 청년 지역 정주
2. 🏠 청년 주거 지원
3. ❤️ 청년 복지 정책
4. 💰 청년 금융 지원 정책
5. 🗳️ 청년 참여 정책
6. 🎓 청년 교육 정책

## 🚀 배포

### Vercel 배포

1. GitHub에 푸시
2. Vercel에서 프로젝트 import
3. 환경 변수 설정:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`
4. Framework Preset: **Quasar**
5. Build Command: `quasar build`
6. Output Directory: `dist/spa`

### 로컬 빌드 테스트

```bash
npm run build
# dist/spa/ 폴더 생성
```

## 🐛 디버깅

모든 주요 함수에 console.log가 추가되어 있습니다:

- `🔧` - 설정/초기화
- `🔐` - 로그인
- `📝` - 회원가입
- `🔒` - 인증 가드
- `🏠` - 페이지 로드
- `✅` - 성공
- `❌` - 에러
- `⚠️` - 경고

Chrome DevTools Console에서 확인하세요.

## 📦 개발 정보

- **버전**: 2.0.0
- **라이선스**: MIT
- **Node.js**: >=16.0.0

---

## V1과의 차이점

| 항목 | V1 | V2 |
|------|----|----|
| 정책 구조 | 다수의 개별 정책 | **6개 고정 교육 카테고리** |
| 학습 방식 | 영상 + 퀴즈 | **QnA + 영상 + 퀴즈 통합** |
| 진도 추적 | 2단계 | **4단계 (상세 10% + QnA 20% + 영상 40% + 퀴즈 30%)** |
| 이수 증명 | 없음 | **프로필에 이수율 표시** |
| 이메일 인증 | 필수 | **선택 (개발 시 비활성화 권장)** |
