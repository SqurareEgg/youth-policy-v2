<template>
  <q-page class="q-pa-md">
    <div class="detail-container">
      <h5 class="text-h5 q-mb-md">카테고리 상세 (ID: {{ categoryId }})</h5>
      <p class="text-body1 q-mb-lg">카테고리 상세 페이지 - 준비 중</p>

      <q-card>
        <q-card-section>
          <div class="text-h6">학습 메뉴</div>
        </q-card-section>
        <q-list>
          <q-item clickable v-ripple @click="goToQnA">
            <q-item-section avatar>
              <q-icon name="quiz" color="primary" />
            </q-item-section>
            <q-item-section>
              <q-item-label>QnA 학습</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-icon name="chevron_right" />
            </q-item-section>
          </q-item>

          <q-item clickable v-ripple @click="goToVideo">
            <q-item-section avatar>
              <q-icon name="play_circle" color="primary" />
            </q-item-section>
            <q-item-section>
              <q-item-label>영상 학습</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-icon name="chevron_right" />
            </q-item-section>
          </q-item>

          <q-item clickable v-ripple @click="goToQuiz">
            <q-item-section avatar>
              <q-icon name="check_circle" color="primary" />
            </q-item-section>
            <q-item-section>
              <q-item-label>OX 퀴즈</q-item-label>
            </q-item-section>
            <q-item-section side>
              <q-icon name="chevron_right" />
            </q-item-section>
          </q-item>
        </q-list>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'

export default defineComponent({
  name: 'CategoryDetailPage',

  setup() {
    console.log('📖 [CategoryDetail] 카테고리 상세 페이지 로드')

    const route = useRoute()
    const router = useRouter()

    const categoryId = computed(() => route.params.id)

    function goToQnA() {
      console.log('📝 [CategoryDetail] QnA 페이지로 이동')
      router.push(`/category/${categoryId.value}/qna`)
    }

    function goToVideo() {
      console.log('🎬 [CategoryDetail] 영상 페이지로 이동')
      router.push(`/category/${categoryId.value}/video`)
    }

    function goToQuiz() {
      console.log('✅ [CategoryDetail] 퀴즈 페이지로 이동')
      router.push(`/category/${categoryId.value}/quiz`)
    }

    onMounted(() => {
      console.log('📖 [CategoryDetail] 마운트 완료 - 카테고리 ID:', categoryId.value)
    })

    return {
      categoryId,
      goToQnA,
      goToVideo,
      goToQuiz
    }
  }
})
</script>

<style lang="scss" scoped>
.detail-container {
  max-width: 800px;
  margin: 0 auto;
}
</style>
