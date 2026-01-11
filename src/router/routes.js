/**
 * 라우트 정의
 * 앱의 모든 페이지 경로를 정의합니다.
 */

import { supabase } from '../boot/supabase'

/**
 * 인증 필요 체크 가드
 * 로그인하지 않은 사용자는 로그인 페이지로 리다이렉트
 */
async function requireAuth(to, from, next) {
  console.log('🔒 [Auth Guard] requireAuth 체크:', to.path)

  if (!supabase) {
    console.warn('⚠️ [Auth Guard] Supabase 미설정 - 통과')
    next()
    return
  }

  try {
    const { data: { session }, error } = await supabase.auth.getSession()

    if (error) {
      console.error('❌ [Auth Guard] 세션 확인 에러:', error.message)
      next('/auth/login')
      return
    }

    if (session) {
      console.log('✅ [Auth Guard] 인증됨 - 통과')
      next()
    } else {
      console.log('❌ [Auth Guard] 미인증 - 로그인 페이지로 리다이렉트')
      next('/auth/login')
    }
  } catch (error) {
    console.error('❌ [Auth Guard] 예외 발생:', error)
    next('/auth/login')
  }
}

/**
 * 게스트 전용 가드 (로그인한 사용자는 접근 불가)
 */
async function guestOnly(to, from, next) {
  console.log('🔓 [Guest Guard] guestOnly 체크:', to.path)

  if (!supabase) {
    console.warn('⚠️ [Guest Guard] Supabase 미설정 - 통과')
    next()
    return
  }

  try {
    const { data: { session }, error } = await supabase.auth.getSession()

    if (error) {
      console.error('❌ [Guest Guard] 세션 확인 에러:', error.message)
      next()
      return
    }

    if (session) {
      console.log('❌ [Guest Guard] 이미 로그인됨 - 홈으로 리다이렉트')
      next('/')
    } else {
      console.log('✅ [Guest Guard] 비로그인 - 통과')
      next()
    }
  } catch (error) {
    console.error('❌ [Guest Guard] 예외 발생:', error)
    next()
  }
}

const routes = [
  // ============================================
  // 랜딩 페이지 (루트) - 직접 렌더링으로 변경
  // ============================================
  {
    path: '/',
    name: 'landing',
    component: () => import('../pages/auth/LandingPage.vue'),
    beforeEnter: async (to, from, next) => {
      console.log('🔀 [Route] 루트 접근 - 로그인 체크')
      if (supabase) {
        const { data: { session } } = await supabase.auth.getSession()
        if (session) {
          console.log('🔀 [Route] 로그인 상태 - /main으로 이동')
          next('/main')
          return
        }
      }
      console.log('🔀 [Route] 비로그인 상태 - 랜딩 페이지 표시')
      next()
    },
    meta: {
      title: '청년 정책 교육'
    }
  },

  // ============================================
  // 인증 페이지 (로그인하지 않은 사용자만 접근)
  // ============================================
  {
    path: '/auth',
    children: [
      {
        path: 'register',
        name: 'register',
        component: () => import('../pages/auth/RegisterPage.vue'),
        beforeEnter: guestOnly,
        meta: {
          title: '회원가입'
        }
      },
      {
        path: 'login',
        name: 'login',
        component: () => import('../pages/auth/LoginPage.vue'),
        beforeEnter: guestOnly,
        meta: {
          title: '로그인'
        }
      }
    ]
  },

  // ============================================
  // 메인 레이아웃 (로그인 필요)
  // ============================================
  {
    path: '/main',
    component: () => import('../layouts/MainLayout.vue'),
    beforeEnter: requireAuth,
    children: [
      {
        // 메인 페이지 (교육 선택)
        path: '',
        name: 'main',
        component: () => import('../pages/IndexPage.vue'),
        meta: {
          title: '교육 선택'
        }
      },
      {
        // 카테고리 상세페이지
        path: '/category/:id',
        name: 'category-detail',
        component: () => import('../pages/category/CategoryDetailPage.vue'),
        meta: {
          title: '카테고리 상세'
        }
      },
      {
        // QnA 학습 페이지
        path: '/category/:id/qna',
        name: 'qna-learning',
        component: () => import('../pages/learning/QnAPage.vue'),
        meta: {
          title: 'QnA 학습'
        }
      },
      {
        // 영상 학습 페이지
        path: '/category/:id/video',
        name: 'video-learning',
        component: () => import('../pages/learning/VideoPage.vue'),
        meta: {
          title: '영상 학습'
        }
      },
      {
        // OX 퀴즈 페이지
        path: '/category/:id/quiz',
        name: 'quiz',
        component: () => import('../pages/learning/QuizPage.vue'),
        meta: {
          title: 'OX 퀴즈'
        }
      },
      {
        // 프로필 페이지 (마이페이지)
        path: '/profile',
        name: 'profile',
        component: () => import('../pages/ProfilePage.vue'),
        meta: {
          title: '마이페이지'
        }
      }
    ]
  },

  // ============================================
  // 404 페이지 (존재하지 않는 경로)
  // ============================================
  {
    path: '/:catchAll(.*)*',
    name: 'not-found',
    component: () => import('../pages/ErrorNotFound.vue')
  }
]

export default routes
