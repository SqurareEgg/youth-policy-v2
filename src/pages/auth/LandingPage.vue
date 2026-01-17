<template>
  <div class="landing-page min-h-screen bg-white">
    <!-- Header -->
    <header class="bg-white border-b border-gray-200 sticky top-0 z-50">
      <div class="container mx-auto px-4 sm:px-6 h-16 flex items-center justify-between">
        <!-- 로고 -->
        <div class="flex items-center gap-2">
          <span class="text-xl sm:text-2xl font-bold text-[#1e3a8a]">
            청년있슈
          </span>
        </div>

        <!-- 중앙 카테고리 - Desktop -->
        <nav class="hidden lg:flex items-center gap-4 xl:gap-6">
          <button
            v-for="category in categories"
            :key="category.name"
            class="text-sm text-gray-700 hover:text-[#F97316] transition-colors px-2 py-1 rounded-lg hover:bg-gray-50"
          >
            {{ category.name }}
          </button>
        </nav>

        <!-- 우측 로그인/회원가입 - Desktop -->
        <div class="hidden md:flex items-center gap-3">
          <button
            @click="goToLogin"
            class="text-sm text-gray-700 hover:text-[#F97316] transition-colors"
          >
            로그인
          </button>
          <button
            @click="goToRegister"
            class="text-sm bg-[#F97316] text-white px-4 py-2 rounded-lg hover:bg-orange-600 transition-colors"
          >
            회원가입
          </button>
        </div>

        <!-- Mobile Menu Button -->
        <button
          class="md:hidden p-2 hover:bg-gray-100 rounded-lg transition-colors"
          @click="toggleMobileMenu"
        >
          <q-icon :name="mobileMenuOpen ? 'close' : 'menu'" size="24px" />
        </button>
      </div>

      <!-- Mobile Navigation -->
      <div v-if="mobileMenuOpen" class="md:hidden bg-white border-t border-gray-200">
        <nav class="container mx-auto px-4 py-4 flex flex-col gap-3">
          <!-- 카테고리 -->
          <div class="pb-3 border-b border-gray-200">
            <p class="text-xs text-gray-500 mb-2">카테고리</p>
            <button
              v-for="category in categories"
              :key="category.name"
              class="text-sm text-gray-700 hover:text-[#F97316] transition-colors py-2 block w-full text-left"
            >
              {{ category.name }}
            </button>
          </div>
          <!-- 로그인/회원가입 -->
          <button
            @click="goToLogin"
            class="text-sm text-gray-700 hover:text-[#F97316] transition-colors py-2 text-left"
          >
            로그인
          </button>
          <button
            @click="goToRegister"
            class="text-sm bg-[#F97316] text-white px-4 py-2 rounded-lg hover:bg-orange-600 transition-colors text-center"
          >
            회원가입
          </button>
        </nav>
      </div>
    </header>

    <!-- Hero Section -->
    <section class="bg-white py-8 sm:py-12">
      <div class="container mx-auto px-4 sm:px-6">
        <div class="grid md:grid-cols-2 gap-4 md:gap-8 lg:gap-12 items-center">
          <!-- Left Content -->
          <div class="order-first">
            <h1 class="text-3xl sm:text-4xl md:text-5xl mb-6 sm:mb-8 leading-tight">
              대전 청년에게 꼭 필요한<br />
              모든 혜택, 청년있슈
            </h1>

            <div class="hidden md:flex md:flex-wrap md:gap-4">
              <div class="flex items-center gap-2 bg-white border border-gray-200 px-4 py-2 rounded-full shadow-sm">
                <q-icon name="auto_awesome" size="20px" color="orange" class="flex-shrink-0" />
                <span class="text-sm font-medium text-gray-700">19~39세 청년 맞춤 정보</span>
              </div>

              <div class="flex items-center gap-2 bg-white border border-gray-200 px-4 py-2 rounded-full shadow-sm">
                <q-icon name="military_tech" size="20px" color="green" class="flex-shrink-0" />
                <span class="text-sm font-medium text-gray-700">중앙·지자체 정책 통합 검색</span>
              </div>

              <div class="flex items-center gap-2 bg-white border border-gray-200 px-4 py-2 rounded-full shadow-sm">
                <q-icon name="military_tech" size="20px" color="blue" class="flex-shrink-0" />
                <span class="text-sm font-medium text-gray-700">실시간 혜택 알림 서비스</span>
              </div>
            </div>
          </div>

          <!-- Right Image Card -->
          <div class="relative bg-white rounded-2xl sm:rounded-3xl p-4 sm:p-6 shadow-lg order-last">
            <div class="flex justify-center items-center">
              <img
                :src="cardNewsImage"
                alt="2026 꼭 알아야 할 청년정책"
                class="w-full h-auto rounded-xl"
              />
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Service Cards -->
    <section class="py-8 sm:py-12 bg-gray-50">
      <div class="container mx-auto px-4 sm:px-6">
        <div class="text-center mb-8 sm:mb-12">
          <h2 class="text-2xl sm:text-3xl font-bold mb-2 sm:mb-4">청년정책 카테고리</h2>
          <p class="text-sm sm:text-base text-gray-600">필요한 정책을 빠르게 찾아보세요</p>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 sm:gap-6">
          <div
            v-for="service in services"
            :key="service.title"
            :class="[
              'bg-gradient-to-br rounded-2xl sm:rounded-3xl p-6 sm:p-8 shadow-md hover:shadow-xl transition-all cursor-pointer group border border-gray-100 relative overflow-hidden text-white',
              service.gradient
            ]"
          >
            <div class="flex items-start justify-between mb-4 sm:mb-6">
              <h3 class="text-xl sm:text-2xl font-bold">{{ service.title }}</h3>
              <div :class="['w-12 h-12 sm:w-14 sm:h-14 bg-white/20 rounded-xl flex items-center justify-center group-hover:scale-110 transition-transform flex-shrink-0']">
                <q-icon :name="service.icon" size="28px" class="text-white" />
              </div>
            </div>

            <p class="text-sm text-white/90 whitespace-pre-line mb-4">
              {{ service.description }}
            </p>

            <div class="mt-auto">
              <a href="#" class="text-sm font-medium text-white hover:underline">
                자세히 보기 →
              </a>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- Footer -->
    <footer class="bg-gray-100 border-t border-gray-200 py-6 sm:py-8">
      <div class="container mx-auto px-4 sm:px-6">
        <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 sm:gap-4">
          <div class="flex flex-wrap gap-3 sm:gap-4 text-xs text-gray-600">
            <a href="#" class="hover:text-gray-900">이용약관</a>
            <a href="#" class="hover:text-gray-900">개인정보처리방침</a>
            <a href="#" class="hover:text-gray-900">저작권보호정책</a>
            <a href="#" class="hover:text-gray-900">정책제안</a>
          </div>
          <div class="flex flex-col sm:flex-row items-start sm:items-center gap-3 sm:gap-4">
            <select class="w-full sm:w-auto text-xs border border-gray-300 rounded px-3 py-1.5 bg-white">
              <option>관련 사이트</option>
              <option>청년포털</option>
              <option>온통청년</option>
              <option>고용노동부</option>
            </select>
            <button class="w-full sm:w-auto text-xs border border-gray-300 rounded px-3 py-1.5 bg-white hover:bg-gray-50">
              문의하기
            </button>
          </div>
        </div>
        <div class="mt-4 sm:mt-6 text-xs text-gray-500">
          © 청년ON - 청년정책 통합 포털. All Rights Reserved
        </div>
      </div>
    </footer>
  </div>
</template>

<script>
import { defineComponent, ref } from 'vue'
import { useRouter } from 'vue-router'

export default defineComponent({
  name: 'LandingPage',

  setup() {
    const router = useRouter()
    const mobileMenuOpen = ref(false)
    const cardNewsImage = new URL('@/assets/images/card-news.png', import.meta.url).href

    const categories = [
      { name: '일자리' },
      { name: '주거' },
      { name: '교육' },
      { name: '금융･복지･문화' },
      { name: '참여' }
    ]

    const services = [
      {
        title: '일자리',
        icon: 'work',
        description: '취업 지원, 창업 지원,\n직업훈련 등 일자리 정책',
        gradient: 'from-blue-500 to-blue-600'
      },
      {
        title: '주거',
        icon: 'home',
        description: '청년 주택, 전월세 지원,\n주거비 보조 등 주거 정책',
        gradient: 'from-orange-500 to-orange-600'
      },
      {
        title: '교육',
        icon: 'school',
        description: '학자금 지원, 교육비 지원,\n역량 개발 등 교육 정책',
        gradient: 'from-green-400 to-green-500'
      },
      {
        title: '금융･복지･문화',
        icon: 'favorite',
        description: '금융 지원, 생활비 지원,\n문화활동 지원 등 복지 정책',
        gradient: 'from-pink-400 to-pink-500'
      },
      {
        title: '참여',
        icon: 'groups',
        description: '청년활동 지원, 정책제안,\n권리보호 등 참여 정책',
        gradient: 'from-purple-500 to-purple-600'
      },
      {
        title: '청년정책 카페',
        icon: 'local_cafe',
        description: '청년들의 소통 공간,\n정책 의견 공유 및 토론',
        gradient: 'from-teal-400 to-teal-500'
      }
    ]

    function toggleMobileMenu() {
      mobileMenuOpen.value = !mobileMenuOpen.value
    }

    function goToLogin() {
      console.log('🔐 [Landing] 로그인 페이지로 이동')
      router.push('/auth/login')
    }

    function goToRegister() {
      console.log('📝 [Landing] 회원가입 페이지로 이동')
      router.push('/auth/register')
    }

    console.log('🏠 [Landing] 랜딩 페이지 로드')

    return {
      mobileMenuOpen,
      cardNewsImage,
      categories,
      services,
      toggleMobileMenu,
      goToLogin,
      goToRegister
    }
  }
})
</script>

<style lang="scss" scoped>
.landing-page {
  font-family: 'Paperlogy', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
}

.container {
  max-width: 1200px;
}

/* Tailwind-like utilities */
.min-h-screen {
  min-height: 100vh;
}

.bg-white {
  background-color: #ffffff;
}

.bg-gray-50 {
  background-color: #f9fafb;
}

.bg-gray-100 {
  background-color: #f3f4f6;
}

.border-b {
  border-bottom-width: 1px;
}

.border-t {
  border-top-width: 1px;
}

.border-gray-200 {
  border-color: #e5e7eb;
}

.sticky {
  position: sticky;
}

.top-0 {
  top: 0;
}

.z-50 {
  z-index: 50;
}

.h-16 {
  height: 4rem;
}

.grid {
  display: grid;
}

.gap-4 {
  gap: 1rem;
}

.gap-3 {
  gap: 0.75rem;
}

.items-center {
  align-items: center;
}

.justify-between {
  justify-content: space-between;
}

.flex {
  display: flex;
}

.flex-col {
  flex-direction: column;
}

.hidden {
  display: none;
}

.text-xl {
  font-size: 1.25rem;
}

.text-2xl {
  font-size: 1.5rem;
}

.text-3xl {
  font-size: 1.875rem;
}

.text-sm {
  font-size: 0.875rem;
}

.text-xs {
  font-size: 0.75rem;
}

.font-bold {
  font-weight: 700;
}

.font-medium {
  font-weight: 500;
}

.text-gray-700 {
  color: #374151;
}

.text-gray-600 {
  color: #4b5563;
}

.text-gray-500 {
  color: #6b7280;
}

.text-white {
  color: #ffffff;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.rounded-xl {
  border-radius: 0.75rem;
}

.rounded-2xl {
  border-radius: 1rem;
}

.rounded-3xl {
  border-radius: 1.5rem;
}

.rounded-full {
  border-radius: 9999px;
}

.px-4 {
  padding-left: 1rem;
  padding-right: 1rem;
}

.py-2 {
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
}

.py-4 {
  padding-top: 1rem;
  padding-bottom: 1rem;
}

.py-6 {
  padding-top: 1.5rem;
  padding-bottom: 1.5rem;
}

.py-8 {
  padding-top: 2rem;
  padding-bottom: 2rem;
}

.p-2 {
  padding: 0.5rem;
}

.p-4 {
  padding: 1rem;
}

.p-6 {
  padding: 1.5rem;
}

.mb-2 {
  margin-bottom: 0.5rem;
}

.mb-4 {
  margin-bottom: 1rem;
}

.mb-6 {
  margin-bottom: 1.5rem;
}

.mb-8 {
  margin-bottom: 2rem;
}

.mt-4 {
  margin-top: 1rem;
}

.mt-auto {
  margin-top: auto;
}

.shadow-sm {
  box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
}

.shadow-md {
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
}

.shadow-lg {
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

.shadow-xl {
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.hover\:shadow-xl:hover {
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
}

.transition-colors {
  transition-property: color, background-color, border-color;
  transition-duration: 0.15s;
}

.transition-all {
  transition-property: all;
  transition-duration: 0.15s;
}

.cursor-pointer {
  cursor: pointer;
}

.relative {
  position: relative;
}

.overflow-hidden {
  overflow: hidden;
}

.leading-tight {
  line-height: 1.25;
}

.whitespace-pre-line {
  white-space: pre-line;
}

.text-center {
  text-align: center;
}

.text-left {
  text-align: left;
}

.w-full {
  width: 100%;
}

.block {
  display: block;
}

.border {
  border-width: 1px;
}

.border-gray-100 {
  border-color: #f3f4f6;
}

.border-gray-300 {
  border-color: #d1d5db;
}

.hover\:bg-gray-50:hover {
  background-color: #f9fafb;
}

.hover\:bg-gray-100:hover {
  background-color: #f3f4f6;
}

.hover\:bg-orange-600:hover {
  background-color: #ea580c;
}

.hover\:text-gray-900:hover {
  color: #111827;
}

.hover\:underline:hover {
  text-decoration: underline;
}

.flex-shrink-0 {
  flex-shrink: 0;
}

.flex-wrap {
  flex-wrap: wrap;
}

.order-first {
  order: -1;
}

.order-last {
  order: 9999;
}

.group:hover .group-hover\:scale-110 {
  transform: scale(1.1);
}

.transition-transform {
  transition-property: transform;
  transition-duration: 0.15s;
}

/* Gradient backgrounds */
.bg-gradient-to-br {
  background-image: linear-gradient(to bottom right, var(--tw-gradient-stops));
}

.from-blue-500 {
  --tw-gradient-from: #3b82f6;
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(59, 130, 246, 0));
}

.to-blue-600 {
  --tw-gradient-to: #2563eb;
}

.from-orange-500 {
  --tw-gradient-from: #f97316;
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(249, 115, 22, 0));
}

.to-orange-600 {
  --tw-gradient-to: #ea580c;
}

.from-green-400 {
  --tw-gradient-from: #4ade80;
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(74, 222, 128, 0));
}

.to-green-500 {
  --tw-gradient-to: #22c55e;
}

.from-pink-400 {
  --tw-gradient-from: #f472b6;
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(244, 114, 182, 0));
}

.to-pink-500 {
  --tw-gradient-to: #ec4899;
}

.from-purple-500 {
  --tw-gradient-from: #a855f7;
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(168, 85, 247, 0));
}

.to-purple-600 {
  --tw-gradient-to: #9333ea;
}

.from-teal-400 {
  --tw-gradient-from: #2dd4bf;
  --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to, rgba(45, 212, 191, 0));
}

.to-teal-500 {
  --tw-gradient-to: #14b8a6;
}

/* Responsive utilities */
@media (min-width: 640px) {
  .sm\:text-2xl {
    font-size: 1.5rem;
  }

  .sm\:text-3xl {
    font-size: 1.875rem;
  }

  .sm\:text-4xl {
    font-size: 2.25rem;
  }

  .sm\:text-base {
    font-size: 1rem;
  }

  .sm\:px-6 {
    padding-left: 1.5rem;
    padding-right: 1.5rem;
  }

  .sm\:py-8 {
    padding-top: 2rem;
    padding-bottom: 2rem;
  }

  .sm\:py-12 {
    padding-top: 3rem;
    padding-bottom: 3rem;
  }

  .sm\:p-6 {
    padding: 1.5rem;
  }

  .sm\:p-8 {
    padding: 2rem;
  }

  .sm\:mb-4 {
    margin-bottom: 1rem;
  }

  .sm\:mb-8 {
    margin-bottom: 2rem;
  }

  .sm\:mb-12 {
    margin-bottom: 3rem;
  }

  .sm\:mt-6 {
    margin-top: 1.5rem;
  }

  .sm\:gap-4 {
    gap: 1rem;
  }

  .sm\:gap-6 {
    gap: 1.5rem;
  }

  .sm\:grid-cols-2 {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .sm\:flex-row {
    flex-direction: row;
  }

  .sm\:items-center {
    align-items: center;
  }

  .sm\:justify-between {
    justify-content: space-between;
  }

  .sm\:rounded-3xl {
    border-radius: 1.5rem;
  }

  .sm\:w-auto {
    width: auto;
  }

  .sm\:w-14 {
    width: 3.5rem;
  }

  .sm\:h-14 {
    height: 3.5rem;
  }
}

@media (min-width: 768px) {
  .md\:hidden {
    display: none;
  }

  .md\:flex {
    display: flex;
  }

  .md\:grid-cols-2 {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .md\:gap-8 {
    gap: 2rem;
  }

  .md\:text-5xl {
    font-size: 3rem;
  }

  .md\:flex-wrap {
    flex-wrap: wrap;
  }
}

@media (min-width: 1024px) {
  .lg\:hidden {
    display: none;
  }

  .lg\:flex {
    display: flex;
  }

  .lg\:grid-cols-3 {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }

  .lg\:gap-12 {
    gap: 3rem;
  }
}

@media (min-width: 1280px) {
  .xl\:gap-6 {
    gap: 1.5rem;
  }
}

/* Additional custom styles */
.text-white\/90 {
  color: rgba(255, 255, 255, 0.9);
}

.bg-white\/20 {
  background-color: rgba(255, 255, 255, 0.2);
}

.w-12 {
  width: 3rem;
}

.h-12 {
  height: 3rem;
}
</style>
