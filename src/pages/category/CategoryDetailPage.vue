<template>
  <q-page class="category-detail-page">
    <div v-if="loading" class="flex flex-center" style="min-height: 400px">
      <div class="text-center">
        <q-spinner color="primary" size="50px" />
        <div class="text-body1 text-grey-7 q-mt-md">카테고리 정보 불러오는 중...</div>
      </div>
    </div>

    <div v-else class="page-container">
      <div class="header-section">
        <q-btn flat icon="arrow_back" label="돌아가기" @click="$router.push('/main')" class="q-mb-md" />

        <div class="row items-center q-gutter-md q-mb-lg">
          <q-icon :name="category.icon" size="64px" :color="categoryColor" />
          <div class="col">
            <h4 class="text-h4 text-weight-bold q-mb-xs">{{ category.title }}</h4>
            <p class="text-body1 text-grey-7">{{ category.description }}</p>
          </div>
        </div>

        <q-card flat bordered class="progress-card q-mb-lg">
          <q-card-section>
            <div class="row items-center q-gutter-md">
              <div class="col">
                <div class="text-caption text-grey-7 q-mb-xs">이 카테고리 이수율</div>
                <div class="text-h5 text-weight-bold text-primary">{{ progress.total_progress || 0 }}%</div>
              </div>
              <div class="col-auto">
                <q-circular-progress :value="progress.total_progress || 0" size="80px" :thickness="0.15" color="primary" track-color="grey-3" show-value class="text-primary">
                  <template v-slot:default><div class="text-caption">{{ progress.total_progress || 0 }}%</div></template>
                </q-circular-progress>
              </div>
            </div>

            <div class="q-mt-md">
              <div class="progress-item">
                <div class="progress-label"><q-icon name="description" size="20px" /><span>상세페이지 방문</span></div>
                <div class="progress-value">
                  <span :class="progress.page_visited ? 'text-primary text-weight-bold' : 'text-grey-6'">{{ progress.page_visited ? '10%' : '0%' }}</span>
                  <q-icon :name="progress.page_visited ? 'check_circle' : 'radio_button_unchecked'" :color="progress.page_visited ? 'primary' : 'grey-6'" size="20px" />
                </div>
              </div>
              <div class="progress-item">
                <div class="progress-label"><q-icon name="quiz" size="20px" /><span>QnA 학습</span></div>
                <div class="progress-value">
                  <span class="text-weight-bold">{{ progress.qna_progress || 0 }}%</span>
                  <span class="text-caption text-grey-6">({{ progress.qna_opened_count || 0}}/{{ progress.qna_total_count || 0 }})</span>
                </div>
              </div>
              <div class="progress-item">
                <div class="progress-label"><q-icon name="play_circle" size="20px" /><span>영상 학습</span></div>
                <div class="progress-value">
                  <span class="text-weight-bold">{{ progress.video_progress || 0 }}%</span>
                  <q-icon v-if="progress.video_completed" name="check_circle" color="primary" size="20px" />
                </div>
              </div>
              <div class="progress-item">
                <div class="progress-label"><q-icon name="assignment" size="20px" /><span>퀴즈 통과</span></div>
                <div class="progress-value">
                  <span :class="progress.quiz_passed ? 'text-primary text-weight-bold' : 'text-grey-6'">{{ progress.quiz_passed ? '30%' : '0%' }}</span>
                  <q-icon :name="progress.quiz_passed ? 'check_circle' : 'radio_button_unchecked'" :color="progress.quiz_passed ? 'primary' : 'grey-6'" size="20px" />
                </div>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <div class="learning-menu">
        <q-card class="menu-card cursor-pointer" @click="goToQnA">
          <q-card-section class="text-center">
            <q-icon name="quiz" size="48px" color="primary" class="q-mb-md" />
            <div class="text-h6 text-weight-bold q-mb-sm">QnA 학습</div>
            <div class="text-caption text-grey-7">{{ qnaCount }}개의 질문과 답변</div>
            <div class="text-caption text-primary q-mt-sm">20% 반영</div>
          </q-card-section>
        </q-card>

        <q-card class="menu-card cursor-pointer" @click="goToVideo">
          <q-card-section class="text-center">
            <q-icon name="play_circle" size="48px" color="red" class="q-mb-md" />
            <div class="text-h6 text-weight-bold q-mb-sm">영상 학습</div>
            <div class="text-caption text-grey-7">{{ videoCount }}개의 교육 영상</div>
            <div class="text-caption text-red q-mt-sm">40% 반영</div>
          </q-card-section>
        </q-card>

        <q-card class="menu-card cursor-pointer" @click="goToQuiz">
          <q-card-section class="text-center">
            <q-icon name="assignment" size="48px" color="green" class="q-mb-md" />
            <div class="text-h6 text-weight-bold q-mb-sm">OX 퀴즈</div>
            <div class="text-caption text-grey-7">{{ quizCount }}개의 문제 (60% 합격)</div>
            <div class="text-caption text-green q-mt-sm">30% 반영</div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'CategoryDetailPage',

  setup() {
    const $q = useQuasar()
    const router = useRouter()
    const route = useRoute()

    const loading = ref(true)
    const category = ref({})
    const progress = ref({})
    const qnaCount = ref(0)
    const videoCount = ref(0)
    const quizCount = ref(0)
    const categoryColor = ref('primary')

    const colorMap = {
      'location_city': 'deep-purple',
      'home': 'primary',
      'health_and_safety': 'pink',
      'account_balance': 'green',
      'how_to_vote': 'purple',
      'school': 'blue'
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
        categoryColor.value = colorMap[categoryData.icon] || 'primary'
        console.log('✅ [CategoryDetail] 카테고리:', categoryData.title)

        const { data: qnaData } = await supabase.from('qna_items').select('id').eq('category_id', route.params.id)
        qnaCount.value = qnaData?.length || 0

        const { data: videoData } = await supabase.from('category_videos').select('id').eq('category_id', route.params.id)
        videoCount.value = videoData?.length || 0

        const { data: quizData } = await supabase.from('category_quizzes').select('id').eq('category_id', route.params.id)
        quizCount.value = quizData?.length || 0

        let { data: progressData, error: progressError } = await supabase
          .from('user_category_progress')
          .select('*')
          .eq('user_id', user.id)
          .eq('category_id', route.params.id)
          .single()

        if (progressError && progressError.code === 'PGRST116') {
          const { data: newProgress, error: insertError } = await supabase
            .from('user_category_progress')
            .insert({ user_id: user.id, category_id: route.params.id, page_visited: true, qna_total_count: qnaCount.value })
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
      qnaCount,
      videoCount,
      quizCount,
      categoryColor,
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
}

.page-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.header-section {
  margin-bottom: 2rem;
}

.progress-card {
  background: white;
}

.progress-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 0;
  border-bottom: 1px solid #e0e0e0;

  &:last-child {
    border-bottom: none;
  }

  .progress-label {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-weight: 500;
  }

  .progress-value {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }
}

.learning-menu {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.menu-card {
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }
}
</style>
