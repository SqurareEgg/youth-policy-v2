<template>
  <q-page class="q-pa-md">
    <div class="quiz-container">
      <h5 class="text-h5 q-mb-md">OX 퀴즈 (카테고리 {{ categoryId }})</h5>
      <p class="text-body1 q-mb-lg">OX 퀴즈 페이지 - 준비 중</p>

      <q-card>
        <q-card-section>
          <div class="text-body1">
            여기에 OX 퀴즈 컴포넌트가 표시됩니다.
          </div>
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'

export default defineComponent({
  name: 'QuizPage',

  setup() {
    console.log('✅ [Quiz] 퀴즈 페이지 로드')

    const route = useRoute()
    const categoryId = computed(() => route.params.id)

    onMounted(() => {
      console.log('✅ [Quiz] 마운트 완료 - 카테고리 ID:', categoryId.value)
    })

    return {
      categoryId
    }
  }
})
</script>
