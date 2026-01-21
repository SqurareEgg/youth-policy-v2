<template>
  <q-page class="category-detail-page">
    <div v-if="loading" class="flex flex-center" style="min-height: 400px">
      <div class="text-center">
        <q-spinner color="primary" size="50px" />
        <div class="text-body1 text-grey-7 q-mt-md">카테고리 정보 불러오는 중...</div>
      </div>
    </div>

    <div v-else class="page-wrapper">
      <!-- Header -->
      <div class="page-header bg-white border-bottom">
        <div class="header-container">
          <q-btn flat dense icon="arrow_back" label="홈으로 돌아가기" @click="$router.push('/main')" class="back-btn text-grey-7" />

          <div>
            <h1 class="text-h4 text-weight-bold">{{ category.title }} 정책</h1>
            <p class="text-grey-7 q-mt-sm">청년을 위한 {{ category.title }} 관련 정책을 학습하고 혜택을 받아보세요</p>
          </div>
        </div>
      </div>

      <!-- Main Content with Sidebar -->
      <div class="main-container">
        <!-- Left Sidebar - Desktop -->
        <aside class="sidebar gt-sm">
          <div class="sidebar-content">
            <h3 class="sidebar-title">세부 정책</h3>
            <nav class="sidebar-nav">
              <button
                v-for="policy in categoryData.policies"
                :key="policy.id"
                @click="selectedPolicy = policy"
                :class="['policy-btn', { 'active': selectedPolicy?.id === policy.id }]"
              >
                <span class="policy-btn-text">{{ policy.title }}</span>
              </button>
            </nav>
          </div>
        </aside>

        <!-- Main Content Area -->
        <main class="main-content">
          <!-- Mobile Policy Icons -->
          <div class="policy-icons-mobile lt-md">
            <div class="policy-icons-scroll">
              <button
                v-for="policy in categoryData.policies"
                :key="policy.id"
                @click="selectedPolicy = policy"
                :class="['policy-icon-btn', { 'active': selectedPolicy?.id === policy.id }]"
              >
                <q-icon :name="policy.icon" size="24px" />
                <span class="policy-icon-label">정책{{ policy.id }}</span>
              </button>
            </div>
          </div>

          <div class="content-area">
            <!-- Initial View: No Policy Selected -->
            <div v-if="!selectedPolicy && !learningType">
              <!-- Category Introduction -->
              <div class="intro-card">
                <h2 class="intro-title">{{ String(categoryIndex).padStart(2, '0') }}. {{ category.title }} 정책: 청년의 내일을 위한 맞춤형 지원</h2>
                <p class="intro-text">{{ categoryData.categoryIntro }}</p>
              </div>

              <!-- Policy Buttons Grid -->
              <div class="policy-grid-card">
                <div class="policy-grid">
                  <button
                    v-for="policy in categoryData.policies"
                    :key="policy.id"
                    @click="selectedPolicy = policy"
                    class="policy-grid-btn"
                  >
                    {{ policy.title }}
                  </button>
                </div>
              </div>

              <!-- Learning Progress -->
              <div class="progress-section-card">
                <div class="progress-header">
                  <h3 class="progress-title">학습 진행 현황</h3>
                  <div class="completion-badge">
                    <p class="completion-label">전체 이수율</p>
                    <p class="completion-value">{{ progress.total_progress || 0 }}%</p>
                  </div>
                </div>

                <div class="progress-bar-section">
                  <div class="progress-bar-header">
                    <span class="text-grey-7">학습 진행률</span>
                    <span class="text-primary text-weight-bold">{{ progress.total_progress || 0 }}% 완료</span>
                  </div>
                  <q-linear-progress :value="(progress.total_progress || 0) / 100" color="primary" size="12px" rounded />
                </div>
              </div>

              <!-- Learning Cards -->
              <div class="learning-cards">
                <!-- Q&A Learning -->
                <div class="learning-card" @click="goToQnA">
                  <div class="learning-card-header">
                    <div class="learning-icon-wrapper">
                      <q-icon name="quiz" size="20px" class="text-grey-8" />
                    </div>
                    <h2 class="learning-card-title">Q&A 학습</h2>
                  </div>
                  <div class="learning-card-body">
                    <h3 class="learning-card-subtitle">{{ category.title }} 정책 Q&A</h3>
                    <p class="learning-card-description">자주 묻는 질문과 답변을 확인하세요</p>
                  </div>
                  <q-btn unelevated color="primary" label="학습하기" class="full-width" size="sm" />
                </div>

                <!-- Video Learning -->
                <div class="learning-card" @click="goToVideo">
                  <div class="learning-card-header">
                    <div class="learning-icon-wrapper">
                      <q-icon name="play_circle" size="20px" class="text-grey-8" />
                    </div>
                    <h2 class="learning-card-title">동영상 학습</h2>
                  </div>
                  <div class="learning-card-body">
                    <h3 class="learning-card-subtitle">{{ category.title }} 정책 영상</h3>
                    <p class="learning-card-description">15:20</p>
                  </div>
                  <q-btn unelevated color="primary" label="시청하기" class="full-width" size="sm" />
                </div>

                <!-- Quiz Learning -->
                <div class="learning-card" @click="goToQuiz">
                  <div class="learning-card-header">
                    <div class="learning-icon-wrapper">
                      <q-icon name="assignment" size="20px" class="text-grey-8" />
                    </div>
                    <h2 class="learning-card-title">QUIZ 학습</h2>
                  </div>
                  <div class="learning-card-body">
                    <div class="quiz-header">
                      <h3 class="learning-card-subtitle">{{ category.title }} 정책 Quiz</h3>
                      <q-icon name="emoji_events" size="20px" color="primary" />
                    </div>
                    <div class="quiz-info">
                      <span class="text-grey-7">문항 수</span>
                      <span class="text-weight-bold">10문제</span>
                    </div>
                  </div>
                  <q-btn unelevated color="primary" label="시작하기" class="full-width" size="sm" />
                </div>
              </div>
            </div>

            <!-- Policy Detail View -->
            <div v-if="selectedPolicy" class="policy-detail">
              <!-- Policy Header Card -->
              <div class="policy-header-card">
                <div class="policy-header-grid">
                  <!-- Left: Text Content -->
                  <div class="policy-header-text">
                    <div class="policy-header-info">
                      <div class="policy-icon-wrapper-large">
                        <q-icon :name="selectedPolicy.icon" size="20px" class="text-grey-7" />
                      </div>
                      <div>
                        <p class="policy-number">정책 {{ selectedPolicy.id }}</p>
                        <h2 class="policy-title-large">{{ selectedPolicy.title }}</h2>
                      </div>
                    </div>
                    <!-- Policy Intro -->
                    <p v-if="selectedPolicy.content" class="policy-intro-text">
                      {{ selectedPolicy.content.intro }}
                    </p>
                  </div>

                  <!-- Right: Image -->
                  <div v-if="selectedPolicy.image" class="policy-header-image">
                    <img
                      :src="selectedPolicy.image"
                      :alt="selectedPolicy.title"
                      class="policy-image"
                    />
                  </div>
                </div>
              </div>

              <!-- Policy Details -->
              <div v-if="selectedPolicy.content && selectedPolicy.content.details" class="policy-items">
                <div
                  v-for="(detail, index) in selectedPolicy.content.details"
                  :key="index"
                  class="policy-item-card"
                >
                  <h3 class="policy-item-title">{{ detail.title }}</h3>
                  <p class="policy-item-description">{{ detail.description }}</p>
                </div>
              </div>

              <!-- Back Button -->
              <div class="back-card">
                <q-btn
                  outline
                  color="primary"
                  label="목록으로 돌아가기"
                  @click="selectedPolicy = null"
                  class="full-width"
                />
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../../boot/supabase'
import { useQuasar } from 'quasar'
import { categoryPoliciesDetailed } from '../../data/categoryPoliciesDetailed'

export default defineComponent({
  name: 'CategoryDetailPage',

  setup() {
    const $q = useQuasar()
    const router = useRouter()
    const route = useRoute()

    const loading = ref(true)
    const category = ref({})
    const progress = ref({})
    const selectedPolicy = ref(null)
    const learningType = ref(null)

    const categoryData = computed(() => {
      return categoryPoliciesDetailed[route.params.id] || { categoryIntro: '', policies: [] }
    })

    const categoryIndex = computed(() => {
      const indexMap = {
        '11111111-1111-1111-1111-111111111111': 1, // 일자리
        '22222222-2222-2222-2222-222222222222': 2, // 주거
        '33333333-3333-3333-3333-333333333333': 3, // 교육
        '44444444-4444-4444-4444-444444444444': 4, // 금융복지문화
        '55555555-5555-5555-5555-555555555555': 5  // 참여
      }
      return indexMap[route.params.id] || 1
    })

    function getCategoryFocus(index) {
      const focuses = [
        '자립과 성장', '안정적인 생활', '역량 개발', '사회 참여',
        '권리 보호', '미래 준비', '경제적 안정', '건강한 삶'
      ]
      return focuses[index % focuses.length]
    }

    async function loadCategoryData() {
      console.log('📄 [CategoryDetail] 카테고리 ID:', route.params.id)

      try {
        if (!supabase) throw new Error('Supabase 미설정')

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('로그인 필요')

        const { data: categoryData, error: categoryError } = await supabase
          .from('education_categories')
          .select('*')
          .eq('id', route.params.id)
          .single()

        if (categoryError) throw categoryError

        category.value = categoryData
        console.log('✅ [CategoryDetail] 카테고리:', categoryData.title)

        let { data: progressData, error: progressError } = await supabase
          .from('user_category_progress')
          .select('*')
          .eq('user_id', user.id)
          .eq('category_id', route.params.id)
          .single()

        if (progressError && progressError.code === 'PGRST116') {
          const { data: newProgress, error: insertError } = await supabase
            .from('user_category_progress')
            .insert({ user_id: user.id, category_id: route.params.id, page_visited: true })
            .select()
            .single()

          if (insertError) throw insertError
          progressData = newProgress
          console.log('✅ [CategoryDetail] 진도율 생성 (상세페이지 방문 10%)')
        } else if (!progressError && !progressData.page_visited) {
          const { data: updatedProgress, error: updateError } = await supabase
            .from('user_category_progress')
            .update({ page_visited: true, page_visited_at: new Date().toISOString() })
            .eq('user_id', user.id)
            .eq('category_id', route.params.id)
            .select()
            .single()

          if (updateError) throw updateError
          progressData = updatedProgress
          console.log('✅ [CategoryDetail] 상세페이지 방문 업데이트 (10%)')
        }

        progress.value = progressData || {}
        console.log('📊 [CategoryDetail] 현재 진도율:', progress.value.total_progress + '%')

      } catch (error) {
        console.error('❌ [CategoryDetail] 데이터 로딩 에러:', error)
        $q.notify({ type: 'negative', message: '카테고리 정보를 불러올 수 없습니다.', position: 'top' })
      } finally {
        loading.value = false
      }
    }

    function goToQnA() {
      router.push({ name: 'qna-learning', params: { id: route.params.id } })
    }

    function goToVideo() {
      router.push({ name: 'video-learning', params: { id: route.params.id } })
    }

    function goToQuiz() {
      router.push({ name: 'quiz', params: { id: route.params.id } })
    }

    onMounted(() => {
      loadCategoryData()
    })

    return {
      loading,
      category,
      progress,
      selectedPolicy,
      learningType,
      categoryData,
      categoryIndex,
      getCategoryFocus,
      goToQnA,
      goToVideo,
      goToQuiz
    }
  }
})
</script>

<style lang="scss" scoped>
.category-detail-page {
  background-color: #f5f5f5;
  min-height: 100vh;
}

.page-wrapper {
  min-height: 100vh;
}

// Header
.page-header {
  border-bottom: 1px solid #e5e7eb;
}

.header-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 1.5rem 1rem;

  @media (min-width: 768px) {
    padding: 1.5rem 2rem;
  }
}

.back-btn {
  margin-bottom: 1rem;
  color: #6b7280;

  &:hover {
    color: $primary;
  }
}

// Main Container with Sidebar
.main-container {
  max-width: 1400px;
  margin: 0 auto;
  display: flex;
  gap: 4rem;

  @media (min-width: 1024px) {
    padding-left: 2rem;
  }
}

// Sidebar
.sidebar {
  width: 288px;
  background: white;
  border-right: 1px solid #e5e7eb;
  min-height: calc(100vh - 140px);
  position: sticky;
  top: 0;
  margin-left: -2rem;
  padding-left: 2rem;
}

.sidebar-content {
  padding: 1rem;
}

.sidebar-title {
  font-size: 1.125rem;
  font-weight: 700;
  color: #111827;
  margin-bottom: 1rem;
  padding: 0 0.75rem;
  white-space: nowrap;
}

.sidebar-nav {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.policy-btn {
  width: 100%;
  display: flex;
  align-items: center;
  padding: 0.75rem;
  border-radius: 0.5rem;
  background: transparent;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: left;

  &:hover {
    background-color: #f3f4f6;
  }

  &.active {
    background-color: $primary;
    color: white;
  }
}

.policy-btn-text {
  font-size: 0.875rem;
  line-height: 1.4;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

// Main Content
.main-content {
  flex: 1;
  padding-right: 1rem;

  @media (min-width: 1024px) {
    padding-right: 2rem;
  }
}

// Mobile Policy Icons
.policy-icons-mobile {
  background: white;
  border-bottom: 1px solid #e5e7eb;
  overflow-x: auto;
  margin: 0 -1rem 2rem -1rem;
  padding: 0 1rem;
}

.policy-icons-scroll {
  display: flex;
  gap: 0.5rem;
  padding: 1rem 0;
  min-width: max-content;
}

.policy-icon-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  background: #f3f4f6;
  color: #374151;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
  min-width: 100px;

  &:hover {
    background: #e5e7eb;
  }

  &.active {
    background: $primary;
    color: white;
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  }
}

.policy-icon-label {
  font-size: 0.75rem;
  text-align: center;
  line-height: 1.4;
}

// Content Area
.content-area {
  padding: 2rem 0;
}

// Introduction Card
.intro-card {
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;
  padding: 2rem;
  margin-bottom: 1.5rem;
}

.intro-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: $primary;
  margin-bottom: 1rem;
}

.intro-text {
  font-size: 1.125rem;
  line-height: 1.75;
  color: #374151;
}

// Policy Grid Card
.policy-grid-card {
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

.policy-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;

  @media (min-width: 768px) {
    grid-template-columns: repeat(3, 1fr);
  }
}

.policy-grid-btn {
  padding: 0.75rem 1rem;
  font-size: 0.875rem;
  border-radius: 0.5rem;
  border: 2px solid #e5e7eb;
  background: white;
  cursor: pointer;
  transition: all 0.2s ease;
  text-align: left;
  color: #111827;

  &:hover {
    border-color: $primary;
    background: #fef3f2;
  }
}

// Progress Section
.progress-section-card {
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

.progress-header {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1rem;

  @media (min-width: 640px) {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
}

.progress-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #111827;
}

.completion-badge {
  background: white;
  padding: 0.75rem 1.25rem;
  border-radius: 0.75rem;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;
}

.completion-label {
  font-size: 0.75rem;
  color: #6b7280;
  margin-bottom: 0.25rem;
}

.completion-value {
  font-size: 1.25rem;
  font-weight: 700;
  color: $primary;
}

.progress-bar-section {
  margin-top: 1rem;
}

.progress-bar-header {
  display: flex;
  justify-content: space-between;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

// Learning Cards
.learning-cards {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;

  @media (min-width: 768px) {
    grid-template-columns: repeat(3, 1fr);
  }
}

.learning-card {
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;
  padding: 1.5rem;
  cursor: pointer;
  transition: box-shadow 0.2s ease;

  &:hover {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  }
}

.learning-card-header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 1rem;
}

.learning-icon-wrapper {
  background: white;
  border: 1px solid #e5e7eb;
  padding: 0.5rem;
  border-radius: 0.5rem;
}

.learning-card-title {
  font-size: 1.125rem;
  font-weight: 700;
}

.learning-card-body {
  margin-bottom: 1rem;
}

.learning-card-subtitle {
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.learning-card-description {
  font-size: 0.875rem;
  color: #6b7280;
}

.quiz-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0.5rem;
}

.quiz-info {
  display: flex;
  justify-content: space-between;
  font-size: 0.875rem;
  color: #6b7280;
}

// Policy Detail
.policy-detail {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.policy-header-card {
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;
  overflow: hidden;
}

.policy-header-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.5rem;

  @media (min-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
    gap: 2rem;
  }
}

.policy-header-text {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  justify-content: center;

  @media (min-width: 768px) {
    padding: 2rem;
  }
}

.policy-header-info {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin-bottom: 0.5rem;
}

.policy-intro-text {
  font-size: 1.125rem;
  line-height: 1.75;
  color: #374151;
  margin-top: 1rem;
}

.policy-header-image {
  position: relative;
  height: 16rem;

  @media (min-width: 768px) {
    height: 20rem;
  }
}

.policy-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 0.5rem;
}

.policy-icon-wrapper-large {
  background: white;
  border: 1px solid #e5e7eb;
  padding: 0.5rem;
  border-radius: 0.5rem;
}

.policy-number {
  font-size: 0.75rem;
  color: #6b7280;
  margin-bottom: 0.25rem;
}

.policy-title-large {
  font-size: 1.25rem;
  font-weight: 700;
  line-height: 1.4;

  @media (min-width: 768px) {
    font-size: 1.5rem;
  }
}

.policy-items {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.policy-item-card {
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 0.5rem;
  padding: 1.25rem;
  transition: box-shadow 0.2s ease;

  &:hover {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  }
}

.policy-item-title {
  font-weight: 700;
  font-size: 1.125rem;
  color: #111827;
  margin-bottom: 0.75rem;
}

.policy-item-description {
  color: #374151;
  line-height: 1.75;
}

.back-card {
  background: white;
  border-radius: 0.75rem;
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1);
  border: 1px solid #f3f4f6;
  padding: 1.5rem;
}

@media (max-width: 600px) {
  .header-container {
    padding: 1rem;
  }

  .content-area {
    padding: 1rem 0;
  }

  .intro-card,
  .policy-grid-card,
  .progress-section-card,
  .learning-card,
  .policy-header-content,
  .policy-item-card,
  .back-card {
    padding: 1rem;
  }
}
</style>
