<template>
  <q-layout view="lHh Lpr lFf">
    <!-- Figma Style Header -->
    <q-header class="bg-white text-grey-9" elevated>
      <q-toolbar class="header-toolbar">
        <!-- 뒤로가기 버튼 (메인이 아닐 때만) -->
        <q-btn
          v-if="showBackButton"
          flat
          dense
          round
          icon="arrow_back"
          color="grey-7"
          @click="$router.go(-1)"
          class="q-mr-sm"
        />

        <!-- 로고 -->
        <div class="logo-section cursor-pointer" @click="goToMain">
          <span class="logo-text">청년있슈</span>
        </div>

        <q-space />

        <!-- 중앙 카테고리 - Desktop -->
        <nav class="desktop-nav gt-sm">
          <q-btn
            v-for="category in categories"
            :key="category.id"
            flat
            dense
            :label="category.name"
            class="category-btn"
            color="grey-7"
            @click="goToCategory(category)"
          />
        </nav>

        <q-space />

        <!-- 우측 프로필/로그아웃 - Desktop -->
        <div class="desktop-actions gt-sm">
          <q-btn
            flat
            dense
            icon="person"
            label="프로필"
            color="grey-7"
            @click="goToProfile"
            class="q-mr-sm"
          />
          <q-btn
            flat
            dense
            icon="logout"
            label="로그아웃"
            color="primary"
            @click="logout"
          />
        </div>

        <!-- Mobile Menu Button -->
        <q-btn
          flat
          dense
          round
          icon="menu"
          color="grey-7"
          class="lt-md"
          @click="mobileMenuOpen = !mobileMenuOpen"
        />
      </q-toolbar>

      <!-- Mobile Navigation -->
      <div v-if="mobileMenuOpen" class="mobile-nav lt-md bg-white q-pa-md border-top">
        <div class="q-gutter-sm">
          <div class="text-caption text-grey-6 q-mb-sm">카테고리</div>
          <q-btn
            v-for="category in categories"
            :key="category.id"
            flat
            :label="category.name"
            class="full-width text-left"
            color="grey-7"
            align="left"
            @click="goToCategory(category)"
          />
          <q-separator class="q-my-md" />
          <q-btn
            flat
            icon="person"
            label="프로필"
            class="full-width text-left"
            color="grey-7"
            align="left"
            @click="goToProfile"
          />
          <q-btn
            flat
            icon="logout"
            label="로그아웃"
            class="full-width text-left"
            color="primary"
            align="left"
            @click="logout"
          />
        </div>
      </div>
    </q-header>

    <!-- Page Content -->
    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import { defineComponent, ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'MainLayout',

  setup() {
    const $q = useQuasar()
    const router = useRouter()
    const route = useRoute()

    const mobileMenuOpen = ref(false)

    // 5대 정책 카테고리 (ID는 Supabase 샘플 데이터와 일치)
    const categories = [
      { name: '일자리', id: '11111111-1111-1111-1111-111111111111' },
      { name: '주거', id: '22222222-2222-2222-2222-222222222222' },
      { name: '교육', id: '33333333-3333-3333-3333-333333333333' },
      { name: '금융･복지･문화', id: '44444444-4444-4444-4444-444444444444' },
      { name: '참여', id: '55555555-5555-5555-5555-555555555555' }
    ]

    const showBackButton = computed(() => {
      return route.name !== 'main'
    })

    const pageTitle = computed(() => {
      return route.meta.title || '청년 정책 교육'
    })

    function goToMain() {
      console.log('🏠 [MainLayout] 메인 페이지로 이동')
      router.push('/main')
      mobileMenuOpen.value = false
    }

    function goToCategory(category) {
      console.log('📚 [MainLayout] 카테고리 이동:', category.name)
      router.push({
        name: 'category-detail',
        params: { id: category.id }
      })
      mobileMenuOpen.value = false
    }

    function goToProfile() {
      console.log('👤 [MainLayout] 프로필 페이지로 이동')
      router.push('/profile')
      mobileMenuOpen.value = false
    }

    async function logout() {
      console.log('🔓 [MainLayout] 로그아웃 시작')
      try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error

        console.log('✅ [MainLayout] 로그아웃 성공')
        $q.notify({
          type: 'positive',
          message: '로그아웃되었습니다.'
        })
        router.push('/')
      } catch (error) {
        console.error('❌ [MainLayout] 로그아웃 실패:', error)
        $q.notify({
          type: 'negative',
          message: '로그아웃 중 오류가 발생했습니다.'
        })
      }
    }

    onMounted(() => {
      console.log('🔧 [MainLayout] 레이아웃 마운트 완료')
    })

    return {
      showBackButton,
      pageTitle,
      categories,
      mobileMenuOpen,
      goToMain,
      goToCategory,
      goToProfile,
      logout
    }
  }
})
</script>

<style lang="scss" scoped>
.header-toolbar {
  min-height: 64px;
  padding: 0 1.5rem;

  @media (max-width: 600px) {
    padding: 0 1rem;
  }
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.logo-text {
  font-size: 1.25rem;
  font-weight: 700;
  color: #f97316;
  letter-spacing: -0.02em;
}

.desktop-nav {
  display: flex;
  gap: 0.5rem;
}

.category-btn {
  font-size: 0.9rem;
  font-weight: 500;
  text-transform: none;
  letter-spacing: -0.01em;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  transition: all 0.2s ease;

  &:hover {
    background-color: rgba(0, 0, 0, 0.05);
  }
}

.desktop-actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.mobile-nav {
  border-top: 1px solid #e5e7eb;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.border-top {
  border-top: 1px solid #e5e7eb;
}
</style>
