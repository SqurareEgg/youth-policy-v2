<template>
  <q-page class="profile-page">
    <div v-if="loading" class="flex flex-center" style="min-height: 400px">
      <div class="text-center">
        <q-spinner color="primary" size="50px" />
        <div class="text-body1 text-grey-7 q-mt-md">프로필 정보 불러오는 중...</div>
      </div>
    </div>

    <div v-else class="page-container">
      <!-- 프로필 정보 -->
      <q-card flat bordered class="q-mb-lg">
        <q-card-section>
          <div class="row items-center q-gutter-md">
            <q-avatar size="80px" color="primary" text-color="white">
              <div class="text-h4">{{ userInitial }}</div>
            </q-avatar>
            <div class="col">
              <h5 class="text-h5 text-weight-bold q-mb-xs">{{ profile.name }}</h5>
              <div class="text-body2 text-grey-7">{{ profile.email }}</div>
              <div class="text-caption text-grey-6">나이: {{ profile.age }}세</div>
            </div>
            <div class="col-auto">
              <q-btn flat color="negative" label="로그아웃" @click="logout" />
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- 전체 이수율 -->
      <q-card flat bordered class="progress-summary q-mb-lg">
        <q-card-section>
          <div class="text-h6 text-weight-bold q-mb-md">전체 이수율</div>
          <div class="row items-center q-gutter-md">
            <div class="col">
              <div class="text-h3 text-weight-bold text-primary">{{ overallProgress }}%</div>
              <div class="text-caption text-grey-7">6개 카테고리 평균</div>
            </div>
            <div class="col-auto">
              <q-circular-progress
                :value="overallProgress"
                size="100px"
                :thickness="0.15"
                color="primary"
                track-color="grey-3"
                show-value
                class="text-primary"
              >
                <template v-slot:default>
                  <div class="text-h6">{{ overallProgress }}%</div>
                </template>
              </q-circular-progress>
            </div>
          </div>
        </q-card-section>
      </q-card>

      <!-- 카테고리별 진도 -->
      <div class="text-h6 text-weight-bold q-mb-md">카테고리별 학습 현황</div>
      <div class="categories-progress">
        <q-card
          v-for="cat in categoryProgress"
          :key="cat.id"
          flat
          bordered
          class="category-progress-card"
        >
          <q-card-section>
            <div class="row items-center q-gutter-sm q-mb-md">
              <q-icon :name="cat.icon" size="32px" :color="cat.color" />
              <div class="col">
                <div class="text-subtitle1 text-weight-bold">{{ cat.title }}</div>
                <div class="text-caption text-grey-7">{{ cat.description }}</div>
              </div>
            </div>

            <div class="row items-center q-mb-sm">
              <div class="col">
                <div class="text-h5 text-weight-bold text-primary">{{ cat.progress }}%</div>
              </div>
              <div class="col-auto">
                <q-chip
                  v-if="cat.is_completed"
                  color="primary"
                  text-color="white"
                  icon="check_circle"
                  size="sm"
                >
                  완료
                </q-chip>
              </div>
            </div>

            <q-linear-progress
              :value="cat.progress / 100"
              :color="cat.color"
              size="8px"
              rounded
              class="q-mb-sm"
            />

            <div class="progress-details">
              <div class="detail-item">
                <q-icon name="description" size="16px" />
                <span>상세 {{ cat.page_visited ? '10%' : '0%' }}</span>
              </div>
              <div class="detail-item">
                <q-icon name="quiz" size="16px" />
                <span>QnA {{ cat.qna_progress }}%</span>
              </div>
              <div class="detail-item">
                <q-icon name="play_circle" size="16px" />
                <span>영상 {{ cat.video_progress }}%</span>
              </div>
              <div class="detail-item">
                <q-icon name="assignment" size="16px" />
                <span>퀴즈 {{ cat.quiz_passed ? '30%' : '0%' }}</span>
              </div>
            </div>
          </q-card-section>

          <q-card-actions>
            <q-btn
              flat
              color="primary"
              label="학습하기"
              @click="goToCategory(cat.category_id)"
            />
          </q-card-actions>
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
  name: 'ProfilePage',

  setup() {
    const $q = useQuasar()
    const router = useRouter()

    const loading = ref(true)
    const profile = ref({})
    const categoryProgress = ref([])

    const colorMap = {
      'location_city': 'deep-purple',
      'home': 'primary',
      'health_and_safety': 'pink',
      'account_balance': 'green',
      'how_to_vote': 'purple',
      'school': 'blue'
    }

    const userInitial = computed(() => {
      return profile.value.name ? profile.value.name.charAt(0) : '?'
    })

    const overallProgress = computed(() => {
      if (categoryProgress.value.length === 0) return 0
      const total = categoryProgress.value.reduce((sum, cat) => sum + cat.progress, 0)
      return Math.round(total / categoryProgress.value.length)
    })

    async function loadProfileData() {
      console.log('👤 [Profile] 프로필 데이터 로딩 시작')

      try {
        if (!supabase) throw new Error('Supabase 미설정')

        const { data: { user } } = await supabase.auth.getUser()
        if (!user) throw new Error('로그인 필요')

        // 프로필 정보 가져오기
        const { data: profileData, error: profileError } = await supabase
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .single()

        if (profileError) throw profileError

        profile.value = profileData
        console.log('✅ [Profile] 프로필:', profileData.name)

        // 카테고리 목록 가져오기
        const { data: categoriesData, error: categoriesError } = await supabase
          .from('education_categories')
          .select('*')
          .eq('is_active', true)
          .order('order_num', { ascending: true })

        if (categoriesError) throw categoriesError

        // 각 카테고리별 진도율 가져오기
        const progressList = await Promise.all(
          categoriesData.map(async (category) => {
            const { data: progressData } = await supabase
              .from('user_category_progress')
              .select('*')
              .eq('user_id', user.id)
              .eq('category_id', category.id)
              .single()

            return {
              category_id: category.id,
              title: category.title,
              description: category.description,
              icon: category.icon,
              color: colorMap[category.icon] || 'grey',
              progress: progressData?.total_progress || 0,
              page_visited: progressData?.page_visited || false,
              qna_progress: progressData?.qna_progress || 0,
              video_progress: progressData?.video_progress || 0,
              quiz_passed: progressData?.quiz_passed || false,
              is_completed: progressData?.is_completed || false
            }
          })
        )

        categoryProgress.value = progressList
        console.log('✅ [Profile] 카테고리별 진도율 로딩 완료')
        console.log('📊 [Profile] 전체 이수율:', overallProgress.value + '%')

      } catch (error) {
        console.error('❌ [Profile] 데이터 로딩 에러:', error)
        $q.notify({
          type: 'negative',
          message: '프로필 정보를 불러올 수 없습니다.',
          position: 'top'
        })
      } finally {
        loading.value = false
      }
    }

    async function logout() {
      console.log('🚪 [Profile] 로그아웃 시작')

      try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error

        console.log('✅ [Profile] 로그아웃 성공')
        $q.notify({
          type: 'positive',
          message: '로그아웃되었습니다.',
          position: 'top'
        })

        router.push('/')
      } catch (error) {
        console.error('❌ [Profile] 로그아웃 에러:', error)
        $q.notify({
          type: 'negative',
          message: '로그아웃 중 오류가 발생했습니다.',
          position: 'top'
        })
      }
    }

    function goToCategory(categoryId) {
      router.push({
        name: 'category-detail',
        params: { id: categoryId }
      })
    }

    onMounted(() => {
      loadProfileData()
    })

    return {
      loading,
      profile,
      categoryProgress,
      userInitial,
      overallProgress,
      logout,
      goToCategory
    }
  }
})
</script>

<style lang="scss" scoped>
.profile-page {
  background-color: #f5f5f5;
}

.page-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.progress-summary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;

  .text-grey-7 {
    color: rgba(255, 255, 255, 0.8) !important;
  }

  .text-primary {
    color: white !important;
  }
}

.categories-progress {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1.5rem;

  @media (max-width: 768px) {
    grid-template-columns: 1fr;
  }
}

.category-progress-card {
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  }
}

.progress-details {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;

  .detail-item {
    display: flex;
    align-items: center;
    gap: 0.25rem;
    font-size: 0.75rem;
    color: #666;
  }
}
</style>
