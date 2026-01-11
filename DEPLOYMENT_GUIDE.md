# 배포 가이드

## 1. GitHub 레포지토리 생성

### 방법 1: GitHub 웹사이트에서 생성

1. https://github.com/new 접속
2. Repository name: `youth-policy-v2`
3. Description: `청년 정책 교육 플랫폼 V2 - Vue 3 + Quasar + Supabase`
4. Public 선택
5. **Add README, .gitignore, license 체크 해제** (이미 로컬에 있음)
6. "Create repository" 클릭

7. 터미널에서 다음 명령어 실행:
```bash
cd C:\WebWork\YouthV2
git remote add origin https://github.com/YOUR_USERNAME/youth-policy-v2.git
git branch -M main
git push -u origin main
```

## 2. Vercel 배포

### 단계 1: Vercel 프로젝트 생성

1. https://vercel.com 접속 및 로그인
2. "Add New" → "Project" 클릭
3. GitHub 계정 연결 (처음이면)
4. `youth-policy-v2` 레포지토리 import

### 단계 2: 빌드 설정

**Framework Preset**: Quasar

**Build Settings:**
- Build Command: `quasar build`
- Output Directory: `dist/spa`
- Install Command: `npm install`

### 단계 3: 환경 변수 설정

Environment Variables 섹션에서 추가:

```
VITE_SUPABASE_URL=https://jqppkfmgciysgdydoenq.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxcHBrZm1nY2l5c2dkeWRvZW5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMTQxNTUsImV4cCI6MjA4MzY5MDE1NX0.tCdogDyP2igSaQBj7ojSWFWf0_yPK2ecbjt4bSxKv6A
```

### 단계 4: 배포

"Deploy" 버튼 클릭!

배포가 완료되면 Vercel이 자동으로 URL을 생성합니다:
- `https://youth-policy-v2.vercel.app` (또는 유사한 URL)

---

## 3. Supabase 데이터베이스 설정

배포 후 Supabase 설정 필요:

### 3.1 이메일 인증 비활성화 (개발용)

1. Supabase Dashboard: https://supabase.com/dashboard
2. 프로젝트 선택 (jqppkfmgciysgdydoenq)
3. Authentication → Settings
4. "Enable email confirmations" **체크 해제**
5. Save

### 3.2 데이터베이스 스키마 실행

1. Supabase Dashboard → SQL Editor
2. "New Query" 클릭
3. `supabase/migrations/001_initial_schema.sql` 파일 내용 복사
4. 붙여넣기 후 "Run" 클릭

**결과:**
- ✅ 8개 테이블 생성
- ✅ RLS 정책 설정
- ✅ 진도율 자동 계산 트리거 설정
- ✅ User Profile 자동 생성 트리거 설정

### 3.3 샘플 데이터 추가 (선택)

6개 교육 카테고리 데이터를 수동으로 추가하거나, 별도의 seed 파일 작성

---

## 4. 배포 후 테스트

### 체크리스트:

- [ ] Vercel URL 접속 확인
- [ ] 랜딩 페이지 로드 확인
- [ ] 회원가입 → 즉시 로그인 가능 확인
- [ ] 메인 페이지에서 6개 카테고리 표시 확인
- [ ] 카테고리 클릭 → 상세페이지 이동 확인
- [ ] 로그아웃 → 랜딩페이지 이동 확인
- [ ] 브라우저 콘솔에서 Supabase 연결 로그 확인:
  ```
  ✅ [Supabase Boot] Supabase 클라이언트 생성 성공
  ✅ [Supabase Boot] 세션 확인 성공
  ```

### 문제 해결

**Supabase 연결 실패:**
- Vercel 환경 변수가 올바르게 설정되었는지 확인
- Vercel → Settings → Environment Variables 확인
- 환경 변수 변경 후 재배포 필요 (Deployments → Redeploy)

**회원가입 후 로그인 안 됨:**
- Supabase 이메일 인증 설정 확인
- 또는 `003_auto_create_user_profile.sql` 트리거 실행 확인

---

## 5. 도메인 연결 (선택)

Vercel에서 커스텀 도메인 연결 가능:

1. Vercel 프로젝트 → Settings → Domains
2. 도메인 입력 후 지시사항 따라 DNS 설정

---

## 빠른 명령어 참조

```bash
# 로컬 개발
npm run dev

# 로컬 빌드 테스트
npm run build

# Git 푸시 (코드 변경 후)
git add .
git commit -m "Update: 메시지"
git push

# Vercel은 자동으로 재배포됨
```

---

## 배포 URL

- **GitHub**: https://github.com/YOUR_USERNAME/youth-policy-v2
- **Vercel**: https://youth-policy-v2.vercel.app (배포 후 확인)
- **Supabase**: https://jqppkfmgciysgdydoenq.supabase.co

---

## 주의사항

1. `.env` 파일은 Git에 커밋되지 않습니다 (.gitignore에 포함)
2. 환경 변수는 Vercel 대시보드에서 별도로 설정해야 합니다
3. Supabase URL과 anon key는 공개해도 안전합니다 (anon key는 공개 키)
4. 단, Supabase service_role key는 절대 공개하지 마세요!

---

**문서 작성일**: 2026-01-11
**버전**: 2.0.0
