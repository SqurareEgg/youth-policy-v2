/**
 * Supabase 부트 파일
 * Supabase 데이터베이스 연결 설정
 * 디버깅을 위한 로그 포함
 */

import { boot } from 'quasar/wrappers'
import { createClient } from '@supabase/supabase-js'

// 환경 변수에서 Supabase 설정 가져오기
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

console.log('🔧 [Supabase Boot] 초기화 시작...')
console.log('🔧 [Supabase Boot] URL:', supabaseUrl ? '✅ 설정됨' : '❌ 없음')
console.log('🔧 [Supabase Boot] Anon Key:', supabaseAnonKey ? '✅ 설정됨' : '❌ 없음')

// Supabase 클라이언트 생성
let supabase = null

if (supabaseUrl && supabaseAnonKey && supabaseUrl !== 'YOUR_SUPABASE_URL') {
  try {
    supabase = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: true
      }
    })
    console.log('✅ [Supabase Boot] Supabase 클라이언트 생성 성공')

    // 연결 테스트
    supabase.auth.getSession().then(({ data, error }) => {
      if (error) {
        console.error('❌ [Supabase Boot] 세션 확인 실패:', error.message)
      } else {
        console.log('✅ [Supabase Boot] 세션 확인 성공', data.session ? '(로그인됨)' : '(비로그인)')
      }
    })
  } catch (error) {
    console.error('❌ [Supabase Boot] Supabase 클라이언트 생성 실패:', error.message)
  }
} else {
  console.warn('⚠️ [Supabase Boot] Supabase 자격증명이 설정되지 않았습니다.')
  console.warn('⚠️ [Supabase Boot] .env 파일에 VITE_SUPABASE_URL과 VITE_SUPABASE_ANON_KEY를 설정하세요.')
}

export default boot(({ app }) => {
  // Vue 앱 전역에서 사용할 수 있도록 설정
  app.config.globalProperties.$supabase = supabase
  console.log('🔧 [Supabase Boot] Vue 앱에 Supabase 주입 완료')
})

export { supabase }
