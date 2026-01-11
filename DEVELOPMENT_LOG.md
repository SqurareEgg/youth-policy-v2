# 청년 정책 교육 플랫폼 V2 - 개발 작업 기록

**프로젝트**: 청년 정책 교육 플랫폼 V2
**시작일**: 2026-01-12
**기술 스택**: Vue 3 + Quasar + Supabase
**배포 URL**: https://youth-policy-v2.vercel.app
**GitHub**: https://github.com/SqurareEgg/youth-policy-v2

---

## 📋 목차

1. [프로젝트 개요](#프로젝트-개요)
2. [주요 변경사항 (V1 → V2)](#주요-변경사항-v1--v2)
3. [개발 과정](#개발-과정)
4. [데이터베이스 설계](#데이터베이스-설계)
5. [구현된 기능](#구현된-기능)
6. [진도율 계산 시스템](#진도율-계산-시스템)
7. [트러블슈팅](#트러블슈팅)
8. [배포 및 설정](#배포-및-설정)

---

## 프로젝트 개요

### 목적
청년들이 청년 정책을 체계적으로 학습하고, 학습 진도를 추적할 수 있는 교육 플랫폼 개발

### 핵심 요구사항
- **6개 고정 카테고리**: 지역정주, 주거지원, 복지정책, 금융지원, 참여정책, 교육정책
- **4단계 학습 시스템**:
  1. 상세페이지 방문 (10%)
  2. QnA 학습 (20%)
  3. 영상 학습 (40%)
  4. OX 퀴즈 (30%)
- **실시간 진도율 추적**
- **이메일 인증 없는 즉시 회원가입**
- **2025년 실제 청년 정책 데이터 기반**

---

## 주요 변경사항 (V1 → V2)

### 1. 카테고리 시스템
- **V1**: 동적 정책 목록 (여러 정책 표시)
- **V2**: 6개 고정 카테고리 (체계적 분류)

### 2. 진도율 계산
- **V1**: 상세 30% + 영상 30% + 퀴즈 40% = 100%
- **V2**: 상세 10% + QnA 20% + 영상 40% + 퀴즈 30% = 100%
  - QnA 학습 추가 (아코디언 형태)
  - 영상 비중 증가 (30% → 40%)

### 3. 학습 방식
- **V1**: 상세 설명, 영상, 퀴즈
- **V2**: QnA 아코디언 추가 (질문-답변 형식)

### 4. 데이터베이스
- **V1**: 6개 테이블
- **V2**: 8개 테이블 (qna_items, qna_view_logs 추가)

---

## 개발 과정

### Phase 1: 프로젝트 설정 및 초기화 (1일차)

#### 1.1 요구사항 분석
- V2 디자인 요구사항 확인
- 진도율 계산 방식 제안 (제안2 채택, 제안3 기각)
- 이메일 인증 제거 결정

#### 1.2 ERD 설계
- 8개 테이블 설계
- 진도율 자동 계산 트리거 설계
- RLS(Row Level Security) 정책 수립

문서: `C:\WebWork\YouthV1\YouthV2_ERD.md`

#### 1.3 화면 설계
- 7개 페이지 UX/UI 설계
- 반응형 그리드 레이아웃 (3x2 ↔ 2x3)

문서: `C:\WebWork\YouthV1\YouthV2_Screen_Design.md`

#### 1.4 프로젝트 생성
```bash
mkdir C:\WebWork\YouthV2
cd C:\WebWork\YouthV2
npm init -y
npm install -g @quasar/cli
npm install
```

**생성된 파일**:
- `package.json` - 프로젝트 의존성
- `quasar.config.js` - Quasar 설정 (ESM 형식)
- `index.html` - 엔트리 포인트
- `.env` - Supabase 환경변수

---

### Phase 2: Supabase 설정 (1일차)

#### 2.1 데이터베이스 스키마 생성

**파일**: `supabase/migrations/001_initial_schema.sql`

**주요 테이블**:
1. `user_profiles` - 사용자 프로필
2. `education_categories` - 6개 교육 카테고리
3. `qna_items` - QnA 학습 데이터
4. `category_videos` - 교육 영상
5. `category_quizzes` - OX 퀴즈
6. `user_category_progress` - 학습 진도율
7. `qna_view_logs` - QnA 열람 기록
8. `quiz_attempts` - 퀴즈 시도 기록

#### 2.2 진도율 자동 계산 트리거

```sql
CREATE OR REPLACE FUNCTION calculate_progress()
RETURNS TRIGGER AS $$
BEGIN
  -- 상세페이지 방문 (10%)
  IF NEW.page_visited THEN
    NEW.total_progress := 10;
  ELSE
    NEW.total_progress := 0;
  END IF;

  -- QnA 진도율 계산 (0~20%)
  IF NEW.qna_total_count > 0 THEN
    NEW.qna_progress := ROUND((NEW.qna_opened_count::FLOAT / NEW.qna_total_count) * 20);
    NEW.total_progress := NEW.total_progress + NEW.qna_progress;
  END IF;

  -- 영상 진도율 계산 (0~40%)
  IF NEW.video_duration > 0 THEN
    IF NEW.video_watch_time >= NEW.video_duration THEN
      NEW.video_progress := 40;
      NEW.video_completed := true;
    ELSE
      NEW.video_progress := ROUND((NEW.video_watch_time::FLOAT / NEW.video_duration) * 40);
    END IF;
    NEW.total_progress := NEW.total_progress + NEW.video_progress;
  END IF;

  -- 퀴즈 진도율 계산 (0~30%)
  IF NEW.quiz_passed THEN
    NEW.quiz_progress := 30;
    NEW.total_progress := NEW.total_progress + 30;
  END IF;

  -- 이수 완료 체크
  IF NEW.total_progress >= 100 THEN
    NEW.is_completed := true;
    IF NEW.completed_at IS NULL THEN
      NEW.completed_at := NOW();
    END IF;
  ELSE
    NEW.is_completed := false;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### 2.3 샘플 데이터 생성

**파일**: `supabase/002_insert_sample_data.sql`

**2025년 실제 청년 정책 기반**:
- 청년미래적금 (6~12% 정부 기여금)
- 청년 월세 지원 (월 20만원, 12개월)
- 대전시 청년 임대주택 (최대 10년)
- K-디지털 트레이닝 (월 116만원 훈련장려금)
- 청년 정신건강 검진 (10년 → 2년 단축)

**데이터 규모**:
- 카테고리: 6개
- QnA 항목: 34개
- 교육 영상: 6개
- OX 퀴즈: 60개 (카테고리당 10개)

출처:
- [대전청년내일재단](https://www.daejeon.go.kr/drh/DrhContentsHtmlView.do?menuSeq=6666)
- [2차 청년정책 기본계획](https://www.korea.kr/news/policyNewsView.do?newsId=148957171)
- [2025년 청년 주거·금융 지원 정책](https://angelsitter.co.kr/board.view.php?board=bbs&no=1822)

---

### Phase 3: 기본 페이지 구현 (1일차)

#### 3.1 인증 페이지

**LandingPage.vue**:
- 랜딩 페이지 (로그인/회원가입 버튼)
- 로그인 상태 확인 후 자동 리다이렉트

**LoginPage.vue**:
- Supabase `signInWithPassword`
- 에러 처리 및 알림

**RegisterPage.vue**:
- Supabase `signUp` (이메일 인증 없음)
- `user_profiles` 테이블에 프로필 직접 생성
- 회원가입 즉시 로그인 가능

#### 3.2 라우터 설정

**routes.js**:
```javascript
// 인증 가드
async function requireAuth(to, from, next) {
  const { data: { session } } = await supabase.auth.getSession()
  if (session) {
    next()
  } else {
    next('/auth/login')
  }
}

// 게스트 전용 가드
async function guestOnly(to, from, next) {
  const { data: { session } } = await supabase.auth.getSession()
  if (session) {
    next('/main')
  } else {
    next()
  }
}
```

#### 3.3 레이아웃

**MainLayout.vue**:
- QLayout, QHeader, QPageContainer 구조
- 로그아웃 버튼
- 네비게이션

---

### Phase 4: 로컬 테스트 및 에러 수정 (1일차)

#### 4.1 Quasar 설정 에러
**에러**: "Dynamic require of 'quasar/wrappers' is not supported"

**원인**: `quasar.config.js`가 CommonJS 형식

**해결**:
```javascript
// Before (CommonJS)
const { configure } = require('quasar/wrappers')
module.exports = configure(...)

// After (ESM)
import { configure } from 'quasar/wrappers'
export default configure(...)
```

#### 4.2 index.html 에러
**에러**: "Please remove <div id='q-app'> from /index.html"

**원인**: Quasar가 자동으로 q-app을 주입하므로 수동 추가 불필요

**해결**:
```html
<body>
  <!-- quasar:entry-point -->
</body>
```

#### 4.3 캐시 문제
**에러**: 빌드 오류 지속

**해결**:
```bash
npx quasar clean
npm run dev
```

**성공**: http://localhost:9000 에서 정상 작동

---

### Phase 5: GitHub 및 Vercel 배포 (1일차)

#### 5.1 GitHub 레포지토리 생성

```bash
cd /c/WebWork/YouthV2
git init
git add .
git commit -m "Initial commit: 프로젝트 기본 구조"
git remote add origin https://github.com/SqurareEgg/youth-policy-v2.git
git branch -M main
git push -u origin main
```

#### 5.2 Vercel 배포

**vercel.json**:
```json
{
  "buildCommand": "quasar build",
  "outputDirectory": "dist/spa",
  "installCommand": "npm install",
  "devCommand": "quasar dev",
  "rewrites": [
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

**환경 변수**:
- `VITE_SUPABASE_URL`: https://jqppkfmgciysgdydoenq.supabase.co
- `VITE_SUPABASE_ANON_KEY`: [사용자 제공 키]

**배포 URL**: https://youth-policy-v2.vercel.app

---

### Phase 6: Production 에러 수정 (1일차)

#### 6.1 White Screen 에러 (첫 번째)
**증상**: 배포 후 흰색 화면

**로그**:
```
[Route] 비로그인 상태 - /landing으로 이동
```

**원인**: 비동기 `redirect` 함수가 production 빌드에서 작동하지 않음

**해결**: `beforeEnter` 가드로 변경
```javascript
// Before
{
  path: '/',
  redirect: async () => {
    // async logic
    return '/landing'
  }
}

// After
{
  path: '/',
  component: () => import('../pages/auth/LandingPage.vue'),
  beforeEnter: async (to, from, next) => {
    // async logic
    next() // or next('/main')
  }
}
```

#### 6.2 QPage 에러 (두 번째)
**증상**: 여전히 흰색 화면

**로그**:
```
QPage needs to be a deep child of QLayout
```

**원인**: 인증 페이지들이 `<q-page>` 컴포넌트를 사용했지만 `<q-layout>` 없이 독립 페이지로 사용

**해결**: `<q-page>` → `<div class="fullscreen">`로 변경
- LandingPage.vue
- LoginPage.vue
- RegisterPage.vue

**결과**: 랜딩 페이지 정상 표시

---

### Phase 7: 회원가입 에러 수정 (1일차)

#### 7.1 "Database error saving new user"
**원인**: `user_profiles` 테이블이 생성되지 않음

**해결**: Supabase SQL Editor에서 `001_initial_schema.sql` 실행

#### 7.2 "Email signups are disabled"
**원인**: Supabase에서 이메일 회원가입 비활성화 상태

**해결**:
1. Authentication → Providers → Email
2. "Enable Email provider" ON
3. "Confirm email" OFF
4. Save

#### 7.3 여전히 "Database error saving new user"
**원인**: User Profile 자동 생성 트리거 권한 문제

**해결**: 트리거 제거, 코드에서 직접 생성
```javascript
// RegisterPage.vue
if (data.user) {
  const { error: profileError } = await supabase
    .from('user_profiles')
    .insert({
      id: data.user.id,
      name: formData.name,
      email: formData.email,
      age: formData.age
    })
}
```

**결과**: 회원가입 성공

---

### Phase 8: 메인 페이지 Supabase 연동 (2일차)

#### 8.1 IndexPage 개선
**이전**: 하드코딩된 더미 데이터

**변경**:
- Supabase에서 `education_categories` 조회
- 각 카테고리별 `user_category_progress` 조회
- 실시간 진도율 표시

**주요 코드**:
```javascript
const { data: categoriesData } = await supabase
  .from('education_categories')
  .select('*')
  .eq('is_active', true)
  .order('order_num', { ascending: true })

const categoriesWithProgress = await Promise.all(
  categoriesData.map(async (category) => {
    const { data: progressData } = await supabase
      .from('user_category_progress')
      .select('total_progress')
      .eq('user_id', user.id)
      .eq('category_id', category.id)
      .single()

    return {
      id: category.id,
      name: category.title,
      progress: progressData?.total_progress || 0,
      // ...
    }
  })
)
```

#### 8.2 CategoryDetailPage 구현
**기능**:
1. 카테고리 정보 표시
2. **상세페이지 방문 자동 체크 (10% 적립)**
3. QnA, 영상, 퀴즈 개수 표시
4. 세부 진도율 표시 (상세/QnA/영상/퀴즈)

**진도율 자동 생성**:
```javascript
let { data: progressData, error } = await supabase
  .from('user_category_progress')
  .select('*')
  .eq('user_id', user.id)
  .eq('category_id', route.params.id)
  .single()

if (error && error.code === 'PGRST116') {
  // 진도율 레코드 생성 (상세페이지 방문 = 10%)
  const { data: newProgress } = await supabase
    .from('user_category_progress')
    .insert({
      user_id: user.id,
      category_id: route.params.id,
      page_visited: true,  // 10% 적립
      qna_total_count: qnaCount.value
    })
    .select()
    .single()
}
```

---

### Phase 9: 학습 페이지 구현 (2일차)

#### 9.1 QnAPage.vue
**기능**:
- Supabase에서 `qna_items` 조회
- 아코디언 형태로 질문/답변 표시
- QnA 열람 시 `qna_view_logs` 기록
- 모든 QnA 열람 시 `qna_opened_count` 업데이트 (20% 반영)

**진도율 업데이트**:
```javascript
// QnA 열람 로그 생성
await supabase.from('qna_view_logs').insert({
  user_id: user.id,
  qna_id: qnaId,
  category_id: categoryId
})

// 열람한 QnA 개수 확인
const { data: viewedCount } = await supabase
  .from('qna_view_logs')
  .select('qna_id')
  .eq('user_id', user.id)
  .eq('category_id', categoryId)

// 진도율 업데이트
await supabase
  .from('user_category_progress')
  .update({
    qna_opened_count: viewedCount.length,
    qna_total_count: totalQnaCount
  })
  .eq('user_id', user.id)
  .eq('category_id', categoryId)
```

#### 9.2 VideoPage.vue
**기능**:
- Supabase에서 `category_videos` 조회
- YouTube iframe으로 영상 재생
- 5초마다 시청 시간 추적
- 영상 완료 시 40% 반영

**시청 시간 추적**:
```javascript
const trackingInterval = setInterval(async () => {
  watchedTime.value += 5

  await supabase
    .from('user_category_progress')
    .update({
      video_watch_time: watchedTime.value,
      video_duration: videoDuration.value
    })
    .eq('user_id', user.id)
    .eq('category_id', categoryId)
}, 5000)
```

#### 9.3 QuizPage.vue
**기능**:
- Supabase에서 `category_quizzes` 조회 (10문제)
- OX 퀴즈 형태 (한 문제씩)
- 채점 및 정답/오답 표시
- 60% 이상 → `quiz_passed = true`, 30% 반영
- `quiz_attempts` 테이블에 시도 기록
- 재시도 가능

**채점 및 진도 업데이트**:
```javascript
const score = answers.filter(a => a.correct).length
const passed = (score / totalQuestions) >= 0.6

// 퀴즈 시도 기록
await supabase.from('quiz_attempts').insert({
  user_id: user.id,
  category_id: categoryId,
  score,
  total: totalQuestions,
  passed
})

// 진도율 업데이트 (60% 이상만)
if (passed) {
  await supabase
    .from('user_category_progress')
    .update({
      quiz_attempted: true,
      quiz_score: score,
      quiz_total: totalQuestions,
      quiz_passed: true
    })
    .eq('user_id', user.id)
    .eq('category_id', categoryId)
}
```

#### 9.4 ProfilePage.vue
**기능**:
- 사용자 프로필 정보 표시
- 전체 이수율 (6개 카테고리 평균)
- 카테고리별 진도율 및 세부 진도 표시
- 로그아웃 기능

**전체 이수율 계산**:
```javascript
const overallProgress = computed(() => {
  if (categoryProgress.value.length === 0) return 0
  const total = categoryProgress.value.reduce((sum, cat) => sum + cat.progress, 0)
  return Math.round(total / categoryProgress.value.length)
})
```

---

## 데이터베이스 설계

### ERD 주요 테이블

#### 1. user_profiles
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  age INTEGER,
  role TEXT DEFAULT 'user',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### 2. education_categories (6개 고정)
```sql
CREATE TABLE education_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,  -- '청년 주거 지원' 등
  description TEXT,
  icon TEXT,  -- Material Icons 이름
  order_num INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

#### 3. user_category_progress (진도율)
```sql
CREATE TABLE user_category_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES education_categories(id) ON DELETE CASCADE,

  -- 상세페이지 방문 (10%)
  page_visited BOOLEAN DEFAULT false,
  page_visited_at TIMESTAMP WITH TIME ZONE,

  -- QnA 학습 (0~20%)
  qna_opened_count INTEGER DEFAULT 0,
  qna_total_count INTEGER DEFAULT 0,
  qna_progress INTEGER DEFAULT 0,
  qna_completed_at TIMESTAMP WITH TIME ZONE,

  -- 영상 학습 (0~40%)
  video_watch_time INTEGER DEFAULT 0,
  video_duration INTEGER DEFAULT 0,
  video_progress INTEGER DEFAULT 0,
  video_completed BOOLEAN DEFAULT false,
  video_completed_at TIMESTAMP WITH TIME ZONE,

  -- 퀴즈 (0~30%)
  quiz_attempted BOOLEAN DEFAULT false,
  quiz_score INTEGER DEFAULT 0,
  quiz_total INTEGER DEFAULT 0,
  quiz_progress INTEGER DEFAULT 0,
  quiz_passed BOOLEAN DEFAULT false,
  quiz_completed_at TIMESTAMP WITH TIME ZONE,

  -- 전체 진도
  total_progress INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMP WITH TIME ZONE,

  UNIQUE(user_id, category_id)
);
```

### RLS 정책

```sql
-- 사용자는 자신의 데이터만 조회/수정
CREATE POLICY "Users can view own progress"
  ON user_category_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
  ON user_category_progress FOR UPDATE
  USING (auth.uid() = user_id);
```

---

## 구현된 기능

### 1. 인증 시스템
- ✅ 회원가입 (이메일 인증 없음)
- ✅ 로그인
- ✅ 로그아웃
- ✅ 세션 관리
- ✅ 인증 가드 (requireAuth, guestOnly)

### 2. 카테고리 시스템
- ✅ 6개 고정 카테고리
- ✅ 카테고리별 아이콘 및 색상
- ✅ 반응형 그리드 (3x2 ↔ 2x3)

### 3. 학습 기능
- ✅ 상세페이지 방문 체크 (10%)
- ✅ QnA 아코디언 학습 (20%)
- ✅ YouTube 영상 학습 (40%)
- ✅ OX 퀴즈 (30%, 60% 합격)

### 4. 진도율 시스템
- ✅ 실시간 진도율 계산
- ✅ 카테고리별 세부 진도 추적
- ✅ 전체 이수율 표시
- ✅ 자동 트리거 (PostgreSQL)

### 5. 프로필 페이지
- ✅ 사용자 정보 표시
- ✅ 전체 이수율
- ✅ 6개 카테고리 진도 현황
- ✅ 로그아웃

---

## 진도율 계산 시스템

### 계산 방식

| 항목 | 배점 | 조건 |
|------|------|------|
| 상세페이지 방문 | 10% | `page_visited = true` |
| QnA 학습 | 0~20% | `(qna_opened_count / qna_total_count) * 20` |
| 영상 학습 | 0~40% | `(video_watch_time / video_duration) * 40` |
| 퀴즈 통과 | 30% | `quiz_passed = true` (60% 이상) |
| **합계** | **100%** | |

### 자동 계산 트리거

`user_category_progress` 테이블 INSERT/UPDATE 시 자동 실행:

```sql
CREATE TRIGGER calculate_user_progress
  BEFORE INSERT OR UPDATE ON user_category_progress
  FOR EACH ROW
  EXECUTE FUNCTION calculate_progress();
```

### 예시

**사용자가 "청년 주거 지원" 카테고리 학습:**

1. 상세페이지 진입 → `page_visited = true` → **10%**
2. 5개 QnA 중 3개 열람 → `(3/5) * 20 = 12%` → **10% + 12% = 22%**
3. 7분 영상 중 3분30초 시청 → `(210/420) * 40 = 20%` → **22% + 20% = 42%**
4. 퀴즈 10문제 중 7개 정답 (70%) → `quiz_passed = true` → **42% + 30% = 72%**

최종 진도율: **72%**

---

## 트러블슈팅

### 1. Quasar Config 형식 에러
**문제**: ESM vs CommonJS
**해결**: `quasar.config.js`를 ESM으로 변경

### 2. Production White Screen
**문제**: 비동기 redirect 미작동
**해결**: beforeEnter 가드 사용

### 3. QPage 컴포넌트 에러
**문제**: QLayout 없이 QPage 사용
**해결**: `<div class="fullscreen">` 사용

### 4. User Profile 생성 실패
**문제**: 트리거 권한 오류
**해결**: 코드에서 직접 INSERT

### 5. Email Signup Disabled
**문제**: Supabase 설정
**해결**: Authentication Providers에서 Email 활성화

---

## 배포 및 설정

### Vercel 설정

**Build Settings**:
- Build Command: `quasar build`
- Output Directory: `dist/spa`
- Install Command: `npm install`

**Environment Variables**:
```
VITE_SUPABASE_URL=https://jqppkfmgciysgdydoenq.supabase.co
VITE_SUPABASE_ANON_KEY=[키]
```

### Supabase 설정

1. **SQL 실행**:
   - `001_initial_schema.sql` - 테이블 생성
   - `002_insert_sample_data.sql` - 샘플 데이터

2. **Authentication 설정**:
   - Providers → Email → Enable ✅
   - Providers → Email → Confirm email ❌
   - Settings → Enable email confirmations ❌

3. **테이블 확인**:
   - Table Editor에서 8개 테이블 확인
   - RLS 정책 확인

---

## 파일 구조

```
YouthV2/
├── src/
│   ├── boot/
│   │   └── supabase.js          # Supabase 클라이언트 초기화
│   ├── layouts/
│   │   └── MainLayout.vue       # 메인 레이아웃
│   ├── pages/
│   │   ├── auth/
│   │   │   ├── LandingPage.vue  # 랜딩 페이지
│   │   │   ├── LoginPage.vue    # 로그인
│   │   │   └── RegisterPage.vue # 회원가입
│   │   ├── category/
│   │   │   └── CategoryDetailPage.vue # 카테고리 상세
│   │   ├── learning/
│   │   │   ├── QnAPage.vue      # QnA 학습
│   │   │   ├── VideoPage.vue    # 영상 학습
│   │   │   └── QuizPage.vue     # OX 퀴즈
│   │   ├── IndexPage.vue        # 메인 페이지
│   │   └── ProfilePage.vue      # 프로필 페이지
│   ├── router/
│   │   └── routes.js            # 라우터 설정
│   └── App.vue
├── supabase/
│   └── migrations/
│       ├── 001_initial_schema.sql    # 테이블 생성
│       └── 002_insert_sample_data.sql # 샘플 데이터
├── quasar.config.js
├── vercel.json
├── package.json
└── .env
```

---

## 주요 커밋 히스토리

1. `Initial commit: 프로젝트 기본 구조`
2. `Docs: 프로젝트 최종 정리 및 문서 업데이트`
3. `Fix: User Profile 자동 생성 트리거 추가`
4. `Fix: QPage 레이아웃 에러 수정`
5. `Fix: vercel.json에서 지원하지 않는 framework 필드 제거`
6. `Fix: QPage 컴포넌트 에러 수정 (white screen 해결)`
7. `Fix: user_profiles 직접 생성으로 회원가입 에러 해결`
8. `Feat: IndexPage와 CategoryDetailPage Supabase 연동 완료`
9. `Feat: ProfilePage 구현 완료`

---

## 다음 단계 (향후 개선 사항)

### 단기 (1주일)
- [ ] QnA, Video, Quiz 페이지 최종 완성 및 테스트
- [ ] 모바일 반응형 최적화
- [ ] 로딩 상태 개선 (Skeleton)
- [ ] 에러 처리 강화

### 중기 (1개월)
- [ ] 관리자 페이지 (카테고리/QnA/영상/퀴즈 관리)
- [ ] 학습 통계 및 분석 대시보드
- [ ] 학습 리마인더 알림
- [ ] 이수증 발급 기능

### 장기 (3개월)
- [ ] 실제 정책 데이터 API 연동
- [ ] AI 챗봇 (정책 질의응답)
- [ ] 소셜 로그인 (Google, Kakao)
- [ ] PWA 지원 (오프라인 학습)

---

## 참고 자료

### 공식 문서
- [Quasar Framework](https://quasar.dev)
- [Vue 3](https://vuejs.org)
- [Supabase](https://supabase.com/docs)
- [Vercel](https://vercel.com/docs)

### 정책 출처
- [대전청년내일재단](https://www.daejeon.go.kr/drh/DrhContentsHtmlView.do?menuSeq=6666)
- [2차 청년정책 기본계획](https://www.korea.kr/news/policyNewsView.do?newsId=148957171)
- [2025년 청년 주거·금융 지원](https://angelsitter.co.kr/board.view.php?board=bbs&no=1822)

---

**작성일**: 2026-01-12
**최종 업데이트**: 2026-01-12
**작성자**: Claude Sonnet 4.5 + 사용자 협업
