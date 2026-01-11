<template>
  <q-page class="index-page">
    <div class="page-container">
      <!-- 헤더 섹션 -->
      <div class="header-section">
        <h4 class="text-h4 text-weight-bold q-mb-md">
          청년 정책 교육
        </h4>
        <p class="text-subtitle1 text-grey-7 q-mb-lg">
          6가지 필수 정책 카테고리를 학습하세요
        </p>

        <!-- 전체 이수율 -->
        <q-card flat bordered class="progress-card q-mb-lg">
          <q-card-section>
            <div class="row items-center q-gutter-md">
              <div class="col">
                <div class="text-caption text-grey-7 q-mb-xs">전체 이수율</div>
                <div class="text-h5 text-weight-bold text-primary">
                  {{ overallProgress }}%
                </div>
              </div>
              <div class="col-auto">
                <q-circular-progress
                  :value="overallProgress"
                  size="80px"
                  :thickness="0.15"
                  color="primary"
                  track-color="grey-3"
                  show-value
                  class="text-primary"
                >
                  <template v-slot:default>
                    <div class="text-caption">{{ overallProgress }}%</div>
                  </template>
                </q-circular-progress>
              </div>
            </div>

            <q-linear-progress
              :value="overallProgress / 100"
              color="primary"
              class="q-mt-md"
              size="8px"
              rounded
            />
          </q-card-section>
        </q-card>
      </div>

      <!-- 로딩 상태 -->
      <div v-if="loading" class="text-center q-py-xl">
        <q-spinner color="primary" size="50px" />
        <div class="text-body1 text-grey-7 q-mt-md">카테고리 불러오는 중...</div>
      </div>

      <!-- 카테고리 그리드 -->
      <div v-else class="categories-grid">
        <q-card
          v-for="category in categories"
          :key="category.id"
          class="category-card cursor-pointer"
          @click="goToCategory(category)"
        >
          <q-card-section class="text-center">
            <q-icon
              :name="category.icon"
              size="64px"
              :color="category.color"
              class="q-mb-md"
            />
            <div class="text-h6 text-weight-bold q-mb-sm">
              {{ category.name }}
            </div>
            <div class="text-caption text-grey-7 q-mb-md">
              {{ category.description }}
            </div>

            <!-- 카테고리별 진행률 -->
            <div class="progress-section">
              <div class="text-caption text-grey-6 q-mb-xs">
                이수율: {{ category.progress }}%
              </div>
              <q-linear-progress
                :value="category.progress / 100"
                :color="category.color"
                size="6px"
                rounded
              />
            </div>
          </q-card-section>

          <q-card-section class="card-footer">
            <div class="text-caption text-grey-7">
              {{ category.videoCount }}개 영상 • {{ category.totalMinutes }}분
            </div>
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'IndexPage',

  setup() {
    console.log('🏠 [Index] 메인 페이지 로드')

    const $q = useQuasar()
    const router = useRouter()
    const categories = ref([])
    const loading = ref(true)

    // 카테고리 색상 매핑
    const colorMap = {
      'location_city': 'deep-purple',
      'home': 'primary',
      'health_and_safety': 'pink',
      'account_balance': 'green',
      'how_to_vote': 'purple',
      'school': 'blue'
    }

    // 전체 이수율 계산
    const overallProgress = computed(() => {
      if (categories.value.length === 0) return 0
      const total = categories.value.reduce((sum, cat) => sum + (cat.progress || 0), 0)
      const average = Math.round(total / categories.value.length)
      return average
    })

    // Supabase에서 카테고리 및 진도율 불러오기
    async function loadCategories() {
      console.log('📚 [Index] 카테고리 데이터 로딩 시작')

      try {
        if (!supabase) {
          console.warn('⚠️ [Index] Supabase 미설정 - 더미 데이터 사용')
          loading.value = false
          return
        }

        // 현재 사용자 정보 가져오기
        const { data: { user } } = await supabase.auth.getUser()

        if (!user) {
          console.error('❌ [Index] 사용자 로그인 필요')
          loading.value = false
          return
        }

        console.log('👤 [Index] 현재 사용자:', user.id)

        // 카테고리 데이터 가져오기
        const { data: categoriesData, error: categoriesError } = await supabase
          .from('education_categories')
          .select('*')
          .eq('is_active', true)
          .order('order_num', { ascending: true })

        if (categoriesError) {
          console.error('❌ [Index] 카테고리 조회 실패:', categoriesError)
          throw categoriesError
        }

        console.log('✅ [Index] 카테고리 조회 성공:', categoriesData.length + '개')

        // 각 카테고리별 진도율 가져오기
        const categoriesWithProgress = await Promise.all(
          categoriesData.map(async (category) => {
            // 사용자의 해당 카테고리 진도율 조회
            const { data: progressData } = await supabase
              .from('user_category_progress')
              .select('total_progress')
              .eq('user_id', user.id)
              .eq('category_id', category.id)
              .single()

            // 영상 정보 가져오기
            const { data: videoData } = await supabase
              .from('category_videos')
              .select('duration')
              .eq('category_id', category.id)

            const videoCount = videoData?.length || 0
            const totalMinutes = videoData
              ? Math.round(videoData.reduce((sum, v) => sum + v.duration, 0) / 60)
              : 0

            return {
              id: category.id,
              name: category.title,
              description: category.description,
              icon: category.icon || 'category',
              color: colorMap[category.icon] || 'grey',
              progress: progressData?.total_progress || 0,
              videoCount,
              totalMinutes
            }
          })
        )

        categories.value = categoriesWithProgress
        console.log('✅ [Index] 진도율 포함 카테고리 데이터 로딩 완료')
        console.log('📊 [Index] 전체 이수율:', overallProgress.value + '%')

      } catch (error) {
        console.error('❌ [Index] 데이터 로딩 에러:', error)
        $q.notify({
          type: 'negative',
          message: '카테고리 데이터를 불러오는 중 오류가 발생했습니다.',
          position: 'top'
        })
      } finally {
        loading.value = false
      }
    }

    function goToCategory(category) {
      console.log('🔗 [Index] 카테고리 클릭:', category.name)
      console.log('🔗 [Index] 카테고리 ID:', category.id)

      router.push({
        name: 'category-detail',
        params: { id: category.id }
      })
    }

    onMounted(() => {
      console.log('✅ [Index] 메인 페이지 마운트 완료')
      loadCategories()
    })

    return {
      categories,
      overallProgress,
      goToCategory,
      loading
    }
  }
})
</script>

<style lang="scss" scoped>
.index-page {
  background-color: #f5f5f5;
}

.page-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.header-section {
  margin-bottom: 2rem;

  h4 {
    color: $primary;
  }
}

.progress-card {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;

  .text-grey-7 {
    color: rgba(255, 255, 255, 0.8) !important;
  }

  .text-primary {
    color: white !important;
  }

  .q-linear-progress {
    background-color: rgba(255, 255, 255, 0.3);
  }
}

.categories-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;

  @media (max-width: 1024px) {
    grid-template-columns: repeat(2, 1fr);
  }

  @media (max-width: 600px) {
    grid-template-columns: repeat(2, 1fr);
    gap: 1rem;
  }
}

.category-card {
  transition: all 0.3s ease;
  border-radius: 12px;

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
  }

  .progress-section {
    margin-top: 1rem;
  }

  .card-footer {
    padding-top: 0;
    border-top: 1px solid #e0e0e0;
  }
}

@media (max-width: 600px) {
  .page-container {
    padding: 1rem 0.5rem;
  }

  .category-card {
    .q-icon {
      font-size: 48px !important;
    }

    .text-h6 {
      font-size: 1rem;
    }
  }
}
</style>
