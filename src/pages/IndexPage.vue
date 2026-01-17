<template>
  <q-page class="index-page">
    <div class="page-container">
      <!-- 헤더 섹션 -->
      <div class="header-section">
        <h4 class="text-h4 text-weight-bold q-mb-md">
          청년 정책 교육
        </h4>
        <p class="text-subtitle1 text-grey-7 q-mb-lg">
          5대 필수 정책 카테고리를 학습하세요
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

      <!-- 카테고리 그리드 (Figma 디자인) -->
      <div v-else class="categories-grid-figma">
        <q-card
          v-for="category in categories"
          :key="category.id"
          :class="['category-card-figma', 'cursor-pointer', category.gradient]"
          @click="goToCategory(category)"
        >
          <q-card-section>
            <!-- 카드 헤더 -->
            <div class="card-header">
              <h3 class="card-title">{{ category.name }}</h3>
              <div class="icon-container">
                <q-icon :name="category.icon" size="32px" class="text-white" />
              </div>
            </div>

            <!-- 카드 설명 -->
            <p class="card-description">
              {{ category.description }}
            </p>

            <!-- 진행률 -->
            <div class="progress-section">
              <div class="progress-label">
                이수율: {{ category.progress }}%
              </div>
              <q-linear-progress
                :value="category.progress / 100"
                color="white"
                size="6px"
                rounded
                class="progress-bar"
              />
            </div>

            <!-- 하단 정보 -->
            <div class="card-footer-info">
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

    // 5대 정책 기본 정보
    const policyCategories = {
      '일자리': {
        icon: 'work',
        gradient: 'gradient-blue',
        description: '취업 지원, 창업 지원,\n직업훈련 등 일자리 정책',
        order: 1
      },
      '주거': {
        icon: 'home',
        gradient: 'gradient-orange',
        description: '청년 주택, 전월세 지원,\n주거비 보조 등 주거 정책',
        order: 2
      },
      '교육': {
        icon: 'school',
        gradient: 'gradient-green',
        description: '학자금 지원, 교육비 지원,\n역량 개발 등 교육 정책',
        order: 3
      },
      '금융･복지･문화': {
        icon: 'favorite',
        gradient: 'gradient-pink',
        description: '금융 지원, 생활비 지원,\n문화활동 지원 등 복지 정책',
        order: 4
      },
      '참여': {
        icon: 'groups',
        gradient: 'gradient-purple',
        description: '청년활동 지원, 정책제안,\n권리보호 등 참여 정책',
        order: 5
      }
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
          console.warn('⚠️ [Index] Supabase 미설정 - 기본 5대 정책 사용')
          // Supabase 없을 때 기본 카테고리
          categories.value = Object.keys(policyCategories).map((name, index) => ({
            id: index + 1,
            name,
            ...policyCategories[name],
            progress: 0,
            videoCount: 0,
            totalMinutes: 0
          }))
          loading.value = false
          return
        }

        // 현재 사용자 정보 가져오기
        const { data: { user } } = await supabase.auth.getUser()

        if (!user) {
          console.error('❌ [Index] 사용자 로그인 필요')
          // 로그인 안 했을 때도 기본 카테고리 표시
          categories.value = Object.keys(policyCategories).map((name, index) => ({
            id: index + 1,
            name,
            ...policyCategories[name],
            progress: 0,
            videoCount: 0,
            totalMinutes: 0
          }))
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
            // 카테고리 이름으로 5대 정책 매핑
            const policyInfo = policyCategories[category.title] || {
              icon: 'category',
              gradient: 'gradient-grey',
              description: category.description,
              order: 999
            }

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
              description: policyInfo.description,
              icon: policyInfo.icon,
              gradient: policyInfo.gradient,
              progress: progressData?.total_progress || 0,
              videoCount,
              totalMinutes,
              order: policyInfo.order
            }
          })
        )

        // 5대 정책만 필터링하고 정렬
        categories.value = categoriesWithProgress
          .filter(cat => policyCategories[cat.name])
          .sort((a, b) => a.order - b.order)

        console.log('✅ [Index] 진도율 포함 카테고리 데이터 로딩 완료')
        console.log('📊 [Index] 전체 이수율:', overallProgress.value + '%')

      } catch (error) {
        console.error('❌ [Index] 데이터 로딩 에러:', error)
        $q.notify({
          type: 'negative',
          message: '카테고리 데이터를 불러오는 중 오류가 발생했습니다.',
          position: 'top'
        })
        // 에러 시에도 기본 카테고리 표시
        categories.value = Object.keys(policyCategories).map((name, index) => ({
          id: index + 1,
          name,
          ...policyCategories[name],
          progress: 0,
          videoCount: 0,
          totalMinutes: 0
        }))
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

// Figma 스타일 카테고리 그리드
.categories-grid-figma {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1.5rem;

  @media (max-width: 1024px) {
    grid-template-columns: repeat(2, 1fr);
  }

  @media (max-width: 600px) {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
}

// Figma 스타일 카드
.category-card-figma {
  border-radius: 24px;
  padding: 2rem;
  color: white;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;

  &:hover {
    transform: translateY(-8px);
    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.15);
  }

  .card-header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: 1.5rem;
  }

  .card-title {
    font-size: 1.5rem;
    font-weight: 700;
    margin: 0;
  }

  .icon-container {
    width: 56px;
    height: 56px;
    background-color: rgba(255, 255, 255, 0.2);
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: transform 0.3s ease;
  }

  &:hover .icon-container {
    transform: scale(1.1);
  }

  .card-description {
    font-size: 0.875rem;
    color: rgba(255, 255, 255, 0.9);
    white-space: pre-line;
    margin-bottom: 1.5rem;
    line-height: 1.5;
  }

  .progress-section {
    margin-bottom: 1rem;
  }

  .progress-label {
    font-size: 0.75rem;
    color: rgba(255, 255, 255, 0.9);
    margin-bottom: 0.5rem;
  }

  .progress-bar {
    background-color: rgba(255, 255, 255, 0.3);
  }

  .card-footer-info {
    font-size: 0.75rem;
    color: rgba(255, 255, 255, 0.8);
    padding-top: 1rem;
    border-top: 1px solid rgba(255, 255, 255, 0.2);
  }
}

// 그라디언트 색상
.gradient-blue {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%);
}

.gradient-orange {
  background: linear-gradient(135deg, #f97316 0%, #ea580c 100%);
}

.gradient-green {
  background: linear-gradient(135deg, #4ade80 0%, #22c55e 100%);
}

.gradient-pink {
  background: linear-gradient(135deg, #f472b6 0%, #ec4899 100%);
}

.gradient-purple {
  background: linear-gradient(135deg, #a855f7 0%, #9333ea 100%);
}

.gradient-teal {
  background: linear-gradient(135deg, #2dd4bf 0%, #14b8a6 100%);
}

.gradient-grey {
  background: linear-gradient(135deg, #6b7280 0%, #4b5563 100%);
}

@media (max-width: 600px) {
  .page-container {
    padding: 1rem 0.5rem;
  }

  .category-card-figma {
    padding: 1.5rem;

    .card-title {
      font-size: 1.25rem;
    }

    .icon-container {
      width: 48px;
      height: 48px;
    }
  }
}
</style>
