# 🚀 빠른 배포 가이드 (3단계)

## Step 1: GitHub 레포지토리 생성 (1분)

**아래 링크를 클릭하여 새 레포지토리 생성:**

👉 **https://github.com/new?name=youth-policy-v2&description=청년+정책+교육+플랫폼+V2+-+Vue+3+%2B+Quasar+%2B+Supabase&visibility=public**

위 링크를 클릭하면:
- Repository name: `youth-policy-v2` (자동 입력됨)
- Description: `청년 정책 교육 플랫폼 V2 - Vue 3 + Quasar + Supabase` (자동 입력됨)
- Public (자동 선택됨)

**중요:** ⚠️ **Add README, .gitignore, license 체크 해제** (이미 로컬에 있음)

"Create repository" 버튼 클릭!

---

## Step 2: 코드 푸시 (자동)

레포지토리 생성 후, 아래 명령어를 **PowerShell**에서 실행:

```powershell
cd C:\WebWork\YouthV2

# GitHub 사용자명을 입력하세요 (예: kjw52)
$username = Read-Host "GitHub username"

git remote add origin "https://github.com/$username/youth-policy-v2.git"
git branch -M main
git push -u origin main
```

Windows에서는 자동으로 **브라우저가 열려서 GitHub 로그인**을 진행합니다!

---

## Step 3: Vercel 배포 (3분)

**아래 버튼 클릭:**

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/YOUR_USERNAME/youth-policy-v2)

**배포 설정:**

1. Framework Preset: **Other** 또는 **Quasar**

2. Build Settings:
   - Build Command: `quasar build`
   - Output Directory: `dist/spa`
   - Install Command: `npm install`

3. **Environment Variables 추가:**

   Name: `VITE_SUPABASE_URL`
   Value: `https://jqppkfmgciysgdydoenq.supabase.co`

   Name: `VITE_SUPABASE_ANON_KEY`
   Value: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxcHBrZm1nY2l5c2dkeWRvZW5xIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxMTQxNTUsImV4cCI6MjA4MzY5MDE1NX0.tCdogDyP2igSaQBj7ojSWFWf0_yPK2ecbjt4bSxKv6A`

4. **"Deploy"** 클릭!

---

## 완료! 🎉

배포 완료 후:
- Vercel URL: `https://youth-policy-v2-xxx.vercel.app`
- GitHub URL: `https://github.com/YOUR_USERNAME/youth-policy-v2`

---

## 다음 단계: Supabase 설정

배포 후 **한 번만** 실행:

1. https://supabase.com/dashboard 접속
2. 프로젝트 선택
3. SQL Editor → New Query
4. `C:\WebWork\YouthV2\supabase\migrations\001_initial_schema.sql` 파일 내용 복사
5. 붙여넣기 후 **"Run"** 클릭
6. Authentication → Settings → "Enable email confirmations" **체크 해제**

끝!
