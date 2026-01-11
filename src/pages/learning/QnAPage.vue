<template>
  <q-page class="qna-page">
    <!-- 로딩 상태 -->
    <div v-if="loading" class="flex flex-center" style="min-height: 400px">
      <div class="text-center">
        <q-spinner color="primary" size="50px" />
        <div class="text-body1 text-grey-7 q-mt-md">QnA 데이터 불러오는 중...</div>
      </div>
    </div>

    <!-- QnA 컨텐츠 -->
    <div v-else class="page-container">
      <div class="header-section">
        <q-btn flat icon="arrow_back" label="돌아가기" @click="goBack" class="q-mb-md" />
        <h4 class="text-h4 text-weight-bold q-mb-xs">QnA 학습</h4>
        <p class="text-body1 text-grey-7 q-mb-md">{{ category.title }}에 대한 자주 묻는 질문과 답변입니다.</p>

        <!-- 진도 표시 -->
        <q-card flat bordered class="progress-card q-mb-lg">
          <q-card-section>
            <div class="row items-center">
              <div class="col">
                <div class="text-caption text-grey-7">QnA 학습 진도</div>
                <div class="text-h6 text-weight-bold text-primary">
                  {{ openedCount }} / {{ qnaItems.length }} 완료
                </div>
              </div>
              <div class="col-auto">
                <q-circular-progress
                  :value="progressPercentage"
                  size="60px"
                  :thickness="0.15"
                  color="primary"
                  track-color="grey-3"
                  show-value
                  class="text-primary"
                >
                  <template v-slot:default>
                    <div class="text-caption">{{ progressPercentage }}%</div>
                  </template>
                </q-circular-progress>
              </div>
            </div>
          </q-card-section>
        </q-card>
      </div>

      <!-- QnA가 없는 경우 -->
      <div v-if="qnaItems.length === 0" class="text-center q-pa-lg">
        <q-icon name="quiz" size="64px" color="grey-5" class="q-mb-md" />
        <div class="text-h6 text-grey-6">아직 등록된 QnA가 없습니다.</div>
      </div>

      <!-- QnA 아코디언 리스트 -->
      <div v-else class="qna-list">
        <q-expansion-item
          v-for="(item, index) in qnaItems"
          :key="item.id"
          :model-value="openedItems[item.id] || false"
          @update:model-value="(val) => toggleItem(item, val)"
          :icon="openedItems[item.id] ? 'check_circle' : 'radio_button_unchecked'"
          :icon-color="openedItems[item.id] ? 'primary' : 'grey-5'"
          expand-separator
          class="qna-item"
        >
          <template v-slot:header>
            <q-item-section avatar>
              <q-avatar :color="openedItems[item.id] ? 'primary' : 'grey-4'" text-color="white" size="40px">
                Q{{ index + 1 }}
              </q-avatar>
            </q-item-section>
            <q-item-section>
              <q-item-label class="text-weight-medium">{{ item.question }}</q-item-label>
            </q-item-section>
          </template>

          <q-card flat bordered class="answer-card">
            <q-card-section>
              <div class="text-caption text-grey-7 q-mb-sm">답변</div>
              <div class="text-body1" style="white-space: pre-line">{{ item.answer }}</div>
            </q-card-section>
          </q-card>
        </q-expansion-item>
      </div>

      <!-- 완료 안내 -->
      <q-card v-if="allCompleted" flat bordered class="completion-card q-mt-lg">
        <q-card-section class="text-center">
          <q-icon name="celebration" size="48px" color="primary" class="q-mb-md" />
          <div class="text-h6 text-weight-bold text-primary q-mb-sm">QnA 학습 완료!</div>
          <div class="text-body2 text-grey-7 q-mb-md">모든 질문과 답변을 확인했습니다. (20% 달성)</div>
          <q-btn color="primary" label="다음 학습으로" @click="goToVideo" />
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'QnAPage',

  setup() {
    console.log('📝 [QnA] QnA 학습 페이지 로드')

    const $q = useQuasar()
    const router = useRouter()
    const route = useRoute()

    const loading = ref(true)
    const category = ref({})
    const qnaItems = ref([])
    const openedItems = ref({}) // { qna_id: true/false }
    const openedCount = ref(0)
    const userId = ref(null)

    // 진도율 계산
    const progressPercentage = computed(() => {
      if (qnaItems.value.length === 0) return 0
      return Math.round((openedCount.value / qnaItems.value.length) * 100)
    })

    // 모두 완료 여부
    const allCompleted = computed(() => {
      return qnaItems.value.length > 0 && openedCount.value === qnaItems.value.length
    })

    // 데이터 로드
    async function loadQnAData() {
      console.log('📝 [QnA] 카테고리 ID:', route.params.id)

      try {
        if (!supabase) {
          throw new Error('Supabase 미설정')
        }

        // 사용자 정보 가져오기
        const { data: { user }, error: userError } = await supabase.auth.getUser()
        if (userError || !user) {
          throw new Error('로그인 필요')
        }
        userId.value = user.id
        console.log('📝 [QnA] 사용자 ID:', userId.value)

        // 카테고리 정보 가져오기
        const { data: categoryData, error: categoryError } = await supabase
          .from('education_categories')
          .select('*')
          .eq('id', route.params.id)
          .single()

        if (categoryError) throw categoryError
        category.value = categoryData
        console.log('📝 [QnA] 카테고리:', categoryData.title)

        // QnA 항목 가져오기
        const { data: qnaData, error: qnaError } = await supabase
          .from('qna_items')
          .select('*')
          .eq('category_id', route.params.id)
          .order('order_num', { ascending: true })

        if (qnaError) throw qnaError
        qnaItems.value = qnaData || []
        console.log('📝 [QnA] QnA 항목 개수:', qnaItems.value.length)

        // 기존 열람 로그 가져오기
        const { data: viewLogs, error: logsError } = await supabase
          .from('qna_view_logs')
          .select('qna_id')
          .eq('user_id', userId.value)
          .eq('category_id', route.params.id)

        if (logsError) {
          console.warn('⚠️ [QnA] 열람 로그 조회 실패:', logsError.message)
        } else {
          // 열람한 항목 표시
          const viewedIds = new Set(viewLogs.map(log => log.qna_id))
          openedItems.value = {}
          qnaItems.value.forEach(item => {
            if (viewedIds.has(item.id)) {
              openedItems.value[item.id] = true
            }
          })
          openedCount.value = viewLogs.length
          console.log('📝 [QnA] 기존 열람 개수:', openedCount.value)
        }

      } catch (error) {
        console.error('❌ [QnA] 데이터 로딩 에러:', error)
        $q.notify({
          type: 'negative',
          message: 'QnA 데이터를 불러올 수 없습니다.',
          position: 'top'
        })
      } finally {
        loading.value = false
      }
    }

    // QnA 항목 토글 (열기/닫기)
    async function toggleItem(item, isOpen) {
      console.log('📝 [QnA] 항목 토글:', item.question, '열림:', isOpen)

      // 열림 상태 업데이트
      openedItems.value[item.id] = isOpen

      // 처음 열었을 때만 로그 기록
      if (isOpen && !openedItems.value[item.id + '_logged']) {
        openedItems.value[item.id + '_logged'] = true
        await logQnAView(item)
      }
    }

    // QnA 열람 로그 기록
    async function logQnAView(item) {
      console.log('📝 [QnA] 열람 로그 기록:', item.question)

      try {
        // qna_view_logs에 기록 (UNIQUE 제약 있으므로 중복 방지됨)
        const { error: logError } = await supabase
          .from('qna_view_logs')
          .insert({
            user_id: userId.value,
            qna_id: item.id,
            category_id: route.params.id
          })

        if (logError) {
          // 중복 에러는 무시
          if (logError.code === '23505') {
            console.log('📝 [QnA] 이미 열람한 항목 (중복 무시)')
          } else {
            throw logError
          }
        } else {
          openedCount.value++
          console.log('✅ [QnA] 열람 로그 저장 성공')
        }

        // 모든 QnA를 열었는지 확인하고 진도 업데이트
        if (openedCount.value === qnaItems.value.length) {
          await updateProgress()
        }

      } catch (error) {
        console.error('❌ [QnA] 열람 로그 저장 에러:', error)
      }
    }

    // 진도율 업데이트
    async function updateProgress() {
      console.log('📝 [QnA] 진도율 업데이트 시작')

      try {
        // user_category_progress 업데이트
        const { error: updateError } = await supabase
          .from('user_category_progress')
          .update({
            qna_opened_count: qnaItems.value.length,
            qna_total_count: qnaItems.value.length,
            qna_completed_at: new Date().toISOString()
          })
          .eq('user_id', userId.value)
          .eq('category_id', route.params.id)

        if (updateError) throw updateError

        console.log('✅ [QnA] 진도율 업데이트 완료 (20% 달성)')

        $q.notify({
          type: 'positive',
          message: 'QnA 학습 완료! 20% 진도가 반영되었습니다.',
          position: 'top',
          icon: 'celebration'
        })

      } catch (error) {
        console.error('❌ [QnA] 진도율 업데이트 에러:', error)
      }
    }

    // 뒤로 가기
    function goBack() {
      router.push({ name: 'category-detail', params: { id: route.params.id } })
    }

    // 영상 학습으로 이동
    function goToVideo() {
      router.push({ name: 'video-learning', params: { id: route.params.id } })
    }

    onMounted(() => {
      loadQnAData()
    })

    return {
      loading,
      category,
      qnaItems,
      openedItems,
      openedCount,
      progressPercentage,
      allCompleted,
      toggleItem,
      goBack,
      goToVideo
    }
  }
})
</script>

<style lang="scss" scoped>
.qna-page {
  background-color: #f5f5f5;
}

.page-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.header-section {
  margin-bottom: 2rem;
}

.progress-card {
  background: white;
}

.qna-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.qna-item {
  background: white;
  border-radius: 8px;
  border: 1px solid #e0e0e0;
  transition: all 0.3s ease;

  &:hover {
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  }
}

.answer-card {
  margin: 0.5rem 1rem 1rem 1rem;
  background: #f8f9fa;
}

.completion-card {
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}
</style>
