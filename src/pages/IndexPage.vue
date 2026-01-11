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

      <!-- 카테고리 그리드 -->
      <div class="categories-grid">
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

export default defineComponent({
  name: 'IndexPage',

  setup() {
    console.log('🏠 [Index] 메인 페이지 로드')

    const router = useRouter()

    // 임시 카테고리 데이터 (하드코딩 - DB 연결 전)
    const categories = ref([
      {
        id: 1,
        name: '주거',
        description: '청년 주거 지원 정책',
        icon: 'home',
        color: 'primary',
        progress: 25,
        videoCount: 8,
        totalMinutes: 45
      },
      {
        id: 2,
        name: '금융',
        description: '청년 금융 지원 정책',
        icon: 'account_balance',
        color: 'green',
        progress: 50,
        videoCount: 10,
        totalMinutes: 60
      },
      {
        id: 3,
        name: '고용',
        description: '청년 고용 지원 정책',
        icon: 'work',
        color: 'orange',
        progress: 75,
        videoCount: 12,
        totalMinutes: 70
      },
      {
        id: 4,
        name: '교육',
        description: '청년 교육 지원 정책',
        icon: 'school',
        color: 'blue',
        progress: 0,
        videoCount: 9,
        totalMinutes: 50
      },
      {
        id: 5,
        name: '복지문화',
        description: '청년 복지 및 문화 정책',
        icon: 'favorite',
        color: 'pink',
        progress: 40,
        videoCount: 11,
        totalMinutes: 65
      },
      {
        id: 6,
        name: '참여권리',
        description: '청년 참여 및 권리 정책',
        icon: 'how_to_vote',
        color: 'purple',
        progress: 10,
        videoCount: 7,
        totalMinutes: 40
      }
    ])

    console.log('🏠 [Index] 카테고리 목록:', categories.value.map(c => c.name))

    // 전체 이수율 계산 (임시 데이터 기반)
    const overallProgress = computed(() => {
      const total = categories.value.reduce((sum, cat) => sum + cat.progress, 0)
      const average = Math.round(total / categories.value.length)
      console.log('📊 [Index] 전체 이수율 계산:', average)
      return average
    })

    function goToCategory(category) {
      console.log('🔗 [Index] 카테고리 클릭:', category.name)
      console.log('🔗 [Index] 카테고리 ID:', category.id)
      console.log('🔗 [Index] 카테고리 상세 페이지로 이동: /category/' + category.id)

      router.push({
        name: 'category-detail',
        params: { id: category.id }
      })
    }

    onMounted(() => {
      console.log('✅ [Index] 메인 페이지 마운트 완료')
      console.log('📊 [Index] 전체 이수율:', overallProgress.value + '%')
    })

    return {
      categories,
      overallProgress,
      goToCategory
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
