<template>
  <q-page class="quiz-page">
    <div v-if="loading" class="flex flex-center" style="min-height: 400px">
      <div class="text-center">
        <q-spinner color="primary" size="50px" />
        <div class="text-body1 text-grey-7 q-mt-md">퀴즈 불러오는 중...</div>
      </div>
    </div>

    <div v-else class="page-container">
      <div class="header-section">
        <q-btn flat icon="arrow_back" label="돌아가기" @click="goBack" class="q-mb-md" />
        <h4 class="text-h4 text-weight-bold q-mb-xs">OX 퀴즈</h4>
        <p class="text-body1 text-grey-7 q-mb-md">{{ category.title }} - 60% 이상 맞으면 합격입니다!</p>
      </div>

      <div v-if="quizzes.length === 0" class="text-center q-pa-lg">
        <q-icon name="assignment" size="64px" color="grey-5" class="q-mb-md" />
        <div class="text-h6 text-grey-6">아직 등록된 퀴즈가 없습니다.</div>
      </div>

      <div v-else-if="!quizStarted" class="start-card">
        <q-card flat bordered>
          <q-card-section class="text-center">
            <q-icon name="assignment" size="64px" color="green" class="q-mb-md" />
            <div class="text-h5 text-weight-bold q-mb-md">퀴즈 시작하기</div>
            <div class="text-body1 text-grey-7 q-mb-lg">
              총 {{ quizzes.length }}문제 | 60% 이상 정답 시 합격 (30% 반영)
            </div>
            <q-btn color="green" size="lg" label="시작하기" @click="startQuiz" />
          </q-card-section>
        </q-card>
      </div>

      <div v-else-if="!quizCompleted">
        <q-card flat bordered class="quiz-card q-mb-lg">
          <q-card-section>
            <div class="text-caption text-grey-7 q-mb-xs">문제 {{ currentIndex + 1 }} / {{ quizzes.length }}</div>
            <q-linear-progress :value="(currentIndex + 1) / quizzes.length" color="green" class="q-mb-md" />

            <div class="text-h6 text-weight-bold q-mb-lg">{{ currentQuiz.question }}</div>

            <div class="answer-buttons row q-gutter-md justify-center">
              <q-btn size="xl" color="primary" label="O (정답)" @click="answerQuiz(true)" style="min-width: 150px" />
              <q-btn size="xl" color="negative" label="X (오답)" @click="answerQuiz(false)" style="min-width: 150px" />
            </div>
          </q-card-section>
        </q-card>
      </div>

      <div v-else>
        <q-card flat bordered class="result-card q-mb-lg">
          <q-card-section class="text-center">
            <q-icon :name="passed ? 'celebration' : 'sentiment_dissatisfied'" size="64px" :color="passed ? 'green' : 'grey-6'" class="q-mb-md" />
            <div class="text-h5 text-weight-bold q-mb-md" :class="passed ? 'text-green' : 'text-grey-7'">
              {{ passed ? '합격!' : '불합격' }}
            </div>
            <div class="text-h4 text-weight-bold q-mb-md">{{ score }} / {{ quizzes.length }}</div>
            <div class="text-body1 text-grey-7 q-mb-lg">정답률: {{ Math.round((score / quizzes.length) * 100) }}%</div>

            <div v-if="passed" class="text-body2 text-green q-mb-md">30% 진도가 반영되었습니다!</div>
            <div v-else class="text-body2 text-grey-7 q-mb-md">60% 이상 정답 시 합격입니다. 다시 도전해보세요!</div>

            <div class="q-gutter-sm">
              <q-btn color="primary" label="오답 확인" @click="showResults = true" v-if="!showResults" />
              <q-btn color="green" label="다시 풀기" @click="retryQuiz" />
              <q-btn color="grey-7" label="상세 페이지로" @click="goBack" outline />
            </div>
          </q-card-section>
        </q-card>

        <div v-if="showResults" class="results-list">
          <div v-for="(quiz, index) in quizzes" :key="quiz.id" class="q-mb-md">
            <q-card flat bordered :class="answers[index].correct ? 'correct-card' : 'incorrect-card'">
              <q-card-section>
                <div class="row items-center q-mb-sm">
                  <q-icon :name="answers[index].correct ? 'check_circle' : 'cancel'" :color="answers[index].correct ? 'green' : 'red'" size="24px" class="q-mr-sm" />
                  <div class="text-weight-bold">문제 {{ index + 1 }}</div>
                </div>
                <div class="text-body1 q-mb-sm">{{ quiz.question }}</div>
                <div class="text-caption text-grey-7">
                  <div>정답: {{ quiz.answer ? 'O' : 'X' }}</div>
                  <div>내 답: {{ answers[index].userAnswer ? 'O' : 'X' }}</div>
                  <div class="q-mt-sm">{{ quiz.explanation }}</div>
                </div>
              </q-card-section>
            </q-card>
          </div>
        </div>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'QuizPage',

  setup() {
    console.log('✅ [Quiz] OX 퀴즈 페이지 로드')

    const $q = useQuasar()
    const router = useRouter()
    const route = useRoute()

    const loading = ref(true)
    const category = ref({})
    const quizzes = ref([])
    const userId = ref(null)
    const quizStarted = ref(false)
    const quizCompleted = ref(false)
    const currentIndex = ref(0)
    const answers = ref([])
    const score = ref(0)
    const passed = ref(false)
    const showResults = ref(false)

    const currentQuiz = computed(() => quizzes.value[currentIndex.value] || {})

    async function loadQuizData() {
      console.log('✅ [Quiz] 카테고리 ID:', route.params.id)

      try {
        if (!supabase) throw new Error('Supabase 미설정')

        const { data: { user }, error: userError } = await supabase.auth.getUser()
        if (userError || !user) throw new Error('로그인 필요')
        userId.value = user.id

        const { data: categoryData, error: categoryError } = await supabase
          .from('education_categories')
          .select('*')
          .eq('id', route.params.id)
          .single()

        if (categoryError) throw categoryError
        category.value = categoryData
        console.log('✅ [Quiz] 카테고리:', categoryData.title)

        const { data: quizData, error: quizError } = await supabase
          .from('category_quizzes')
          .select('*')
          .eq('category_id', route.params.id)
          .order('order_num', { ascending: true })

        if (quizError) throw quizError
        quizzes.value = quizData || []
        console.log('✅ [Quiz] 퀴즈 개수:', quizzes.value.length)

      } catch (error) {
        console.error('❌ [Quiz] 데이터 로딩 에러:', error)
        $q.notify({ type: 'negative', message: '퀴즈 데이터를 불러올 수 없습니다.', position: 'top' })
      } finally {
        loading.value = false
      }
    }

    function startQuiz() {
      console.log('✅ [Quiz] 퀴즈 시작')
      quizStarted.value = true
      currentIndex.value = 0
      answers.value = []
      score.value = 0
      passed.value = false
      showResults.value = false
    }

    function answerQuiz(userAnswer) {
      const correct = userAnswer === currentQuiz.value.answer

      answers.value.push({
        quizId: currentQuiz.value.id,
        userAnswer,
        correct
      })

      if (correct) score.value++

      console.log('✅ [Quiz] 답변:', userAnswer, '정답:', currentQuiz.value.answer, '결과:', correct)

      if (currentIndex.value < quizzes.value.length - 1) {
        currentIndex.value++
      } else {
        finishQuiz()
      }
    }

    async function finishQuiz() {
      console.log('✅ [Quiz] 퀴즈 완료')
      quizCompleted.value = true

      const percentage = score.value / quizzes.value.length
      passed.value = percentage >= 0.6

      console.log('✅ [Quiz] 점수:', score.value, '/', quizzes.value.length, '합격:', passed.value)

      try {
        await supabase.from('quiz_attempts').insert({
          user_id: userId.value,
          category_id: route.params.id,
          score: score.value,
          total: quizzes.value.length,
          passed: passed.value
        })

        if (passed.value) {
          await supabase
            .from('user_category_progress')
            .update({
              quiz_attempted: true,
              quiz_score: score.value,
              quiz_total: quizzes.value.length,
              quiz_passed: true,
              quiz_completed_at: new Date().toISOString()
            })
            .eq('user_id', userId.value)
            .eq('category_id', route.params.id)

          console.log('✅ [Quiz] 진도율 업데이트 완료 (30%)')
          $q.notify({ type: 'positive', message: '합격! 30% 진도가 반영되었습니다.', position: 'top', icon: 'celebration' })
        }

      } catch (error) {
        console.error('❌ [Quiz] 결과 저장 에러:', error)
      }
    }

    function retryQuiz() {
      startQuiz()
    }

    function goBack() {
      router.push({ name: 'category-detail', params: { id: route.params.id } })
    }

    onMounted(() => {
      loadQuizData()
    })

    return {
      loading,
      category,
      quizzes,
      quizStarted,
      quizCompleted,
      currentIndex,
      currentQuiz,
      answers,
      score,
      passed,
      showResults,
      startQuiz,
      answerQuiz,
      retryQuiz,
      goBack
    }
  }
})
</script>

<style lang="scss" scoped>
.quiz-page {
  background-color: #f5f5f5;
}

.page-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.header-section {
  margin-bottom: 2rem;
}

.start-card {
  margin: 3rem 0;
}

.quiz-card {
  background: white;
  min-height: 300px;
  display: flex;
  align-items: center;
}

.answer-buttons {
  margin-top: 2rem;
}

.result-card {
  background: white;
}

.results-list {
  margin-top: 2rem;
}

.correct-card {
  border-left: 4px solid #21ba45;
}

.incorrect-card {
  border-left: 4px solid #c10015;
}
</style>
