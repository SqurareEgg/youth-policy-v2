-- ============================================
-- 트리거 삭제 후 재생성 (권한 수정)
-- ============================================

-- 기존 트리거 삭제
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS create_user_profile();

-- 트리거 함수 재생성 (SECURITY DEFINER 권한 추가)
CREATE OR REPLACE FUNCTION public.create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_profiles (id, name, email, age)
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

-- 트리거 재생성
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.create_user_profile();

-- 완료 메시지
DO $$
BEGIN
  RAISE NOTICE '✅ 트리거 함수 수정 완료';
END $$;
