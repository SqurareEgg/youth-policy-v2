-- 청년 정책 교육 플랫폼 V2 데이터베이스 스키마
-- Supabase Auth를 확장하여 사용
-- 진도율: 상세 10% + QnA 20% + 영상 40% + 퀴즈 30% = 100%

-- ============================================
-- 1. 사용자 프로필 테이블 (Supabase Auth 확장)
-- ============================================
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  age INTEGER,
  role TEXT DEFAULT 'user', -- user | admin
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- user_profiles 인덱스
CREATE INDEX IF NOT EXISTS idx_user_profiles_role ON user_profiles(role);
CREATE INDEX IF NOT EXISTS idx_user_profiles_email ON user_profiles(email);

-- ============================================
-- 2. 교육 카테고리 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS education_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  icon TEXT, -- Material Icons 이름
  order_num INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- education_categories 인덱스
CREATE INDEX IF NOT EXISTS idx_categories_order ON education_categories(order_num);
CREATE INDEX IF NOT EXISTS idx_categories_active ON education_categories(is_active);

-- ============================================
-- 3. QnA 학습 항목 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS qna_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES education_categories(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  order_num INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- qna_items 인덱스
CREATE INDEX IF NOT EXISTS idx_qna_category ON qna_items(category_id, order_num);

-- ============================================
-- 4. 카테고리 영상 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS category_videos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES education_categories(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  video_url TEXT NOT NULL,
  duration INTEGER NOT NULL, -- 영상 길이(초)
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- category_videos 인덱스
CREATE INDEX IF NOT EXISTS idx_videos_category ON category_videos(category_id);

-- ============================================
-- 5. 카테고리 퀴즈 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS category_quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID NOT NULL REFERENCES education_categories(id) ON DELETE CASCADE,
  question TEXT NOT NULL,
  answer BOOLEAN NOT NULL, -- true: O, false: X
  explanation TEXT,
  order_num INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- category_quizzes 인덱스
CREATE INDEX IF NOT EXISTS idx_quizzes_category ON category_quizzes(category_id, order_num);

-- ============================================
-- 6. 사용자 학습 진도 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS user_category_progress (
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

  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

  UNIQUE(user_id, category_id)
);

-- user_category_progress 인덱스
CREATE INDEX IF NOT EXISTS idx_progress_user ON user_category_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_category ON user_category_progress(category_id);
CREATE INDEX IF NOT EXISTS idx_progress_user_category ON user_category_progress(user_id, category_id);
CREATE INDEX IF NOT EXISTS idx_progress_completed ON user_category_progress(is_completed);

-- ============================================
-- 7. QnA 열람 로그 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS qna_view_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  qna_id UUID NOT NULL REFERENCES qna_items(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES education_categories(id) ON DELETE CASCADE,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, qna_id)
);

-- qna_view_logs 인덱스
CREATE INDEX IF NOT EXISTS idx_qna_logs_user ON qna_view_logs(user_id, category_id);

-- ============================================
-- 8. 퀴즈 시도 기록 테이블
-- ============================================
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES education_categories(id) ON DELETE CASCADE,
  score INTEGER NOT NULL,
  total INTEGER NOT NULL,
  passed BOOLEAN NOT NULL,
  attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- quiz_attempts 인덱스
CREATE INDEX IF NOT EXISTS idx_attempts_user_category ON quiz_attempts(user_id, category_id, attempted_at);

-- ============================================
-- Row Level Security (RLS) 정책
-- ============================================

-- user_profiles RLS 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- education_categories RLS 활성화
ALTER TABLE education_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active categories"
  ON education_categories FOR SELECT
  USING (is_active = true);

-- qna_items RLS 활성화
ALTER TABLE qna_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view qna"
  ON qna_items FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- category_videos RLS 활성화
ALTER TABLE category_videos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view videos"
  ON category_videos FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- category_quizzes RLS 활성화
ALTER TABLE category_quizzes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view quizzes"
  ON category_quizzes FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- user_category_progress RLS 활성화
ALTER TABLE user_category_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own progress"
  ON user_category_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress"
  ON user_category_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
  ON user_category_progress FOR UPDATE
  USING (auth.uid() = user_id);

-- qna_view_logs RLS 활성화
ALTER TABLE qna_view_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own logs"
  ON qna_view_logs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own logs"
  ON qna_view_logs FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- quiz_attempts RLS 활성화
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own attempts"
  ON quiz_attempts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own attempts"
  ON quiz_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 트리거 함수: updated_at 자동 업데이트
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- user_profiles 트리거
CREATE TRIGGER update_user_profiles_updated_at
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- user_category_progress 트리거
CREATE TRIGGER update_user_progress_updated_at
  BEFORE UPDATE ON user_category_progress
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ============================================
-- 트리거 함수: 진도율 자동 계산
-- 상세 10% + QnA 20% + 영상 40% + 퀴즈 30% = 100%
-- ============================================
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

CREATE TRIGGER calculate_user_progress
  BEFORE INSERT OR UPDATE ON user_category_progress
  FOR EACH ROW
  EXECUTE FUNCTION calculate_progress();

-- ============================================
-- 트리거 함수: User Profile 자동 생성
-- ============================================
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_profiles (id, name, email, age)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', '청년'),
    NEW.email,
    COALESCE((NEW.raw_user_meta_data->>'age')::INTEGER, NULL)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_profile();

-- ============================================
-- 완료 메시지
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '✅ 데이터베이스 스키마 생성 완료';
  RAISE NOTICE '✅ RLS 정책 설정 완료';
  RAISE NOTICE '✅ 트리거 설정 완료';
  RAISE NOTICE '📊 진도율: 상세 10%% + QnA 20%% + 영상 40%% + 퀴즈 30%% = 100%%';
END $$;
