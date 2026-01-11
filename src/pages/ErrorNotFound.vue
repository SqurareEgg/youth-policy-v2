<template>
  <q-page class="flex flex-center bg-gradient">
    <div class="error-container text-center">
      <q-icon name="error_outline" size="120px" color="white" class="q-mb-lg" />

      <h1 class="text-h1 text-weight-bold text-white q-mb-md">
        404
      </h1>

      <h5 class="text-h5 text-white q-mb-md">
        페이지를 찾을 수 없습니다
      </h5>

      <p class="text-body1 text-white q-mb-xl">
        요청하신 페이지가 존재하지 않거나 이동되었습니다.
      </p>

      <div class="button-group">
        <q-btn
          unelevated
          color="white"
          text-color="primary"
          size="lg"
          label="메인으로 돌아가기"
          class="q-mr-md"
          @click="goToMain"
        />
        <q-btn
          outline
          color="white"
          size="lg"
          label="이전 페이지"
          @click="goBack"
        />
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, onMounted } from 'vue'
import { useRouter } from 'vue-router'

export default defineComponent({
  name: 'ErrorNotFound',

  setup() {
    console.log('❌ [404] 404 에러 페이지 로드')

    const router = useRouter()

    function goToMain() {
      console.log('🏠 [404] 메인 페이지로 이동')
      router.push('/main')
    }

    function goBack() {
      console.log('⬅️ [404] 이전 페이지로 이동')
      router.go(-1)
    }

    onMounted(() => {
      console.log('❌ [404] 현재 경로:', window.location.pathname)
      console.log('❌ [404] 참조 URL:', document.referrer || '직접 접근')
    })

    return {
      goToMain,
      goBack
    }
  }
})
</script>

<style lang="scss" scoped>
.bg-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.error-container {
  max-width: 600px;
  width: 90%;
  padding: 3rem 2rem;
}

.button-group {
  display: flex;
  justify-content: center;
  flex-wrap: wrap;
  gap: 1rem;
}

@media (max-width: 600px) {
  .error-container {
    padding: 2rem 1rem;
  }

  h1 {
    font-size: 5rem;
  }

  .button-group {
    flex-direction: column;
    width: 100%;

    .q-btn {
      width: 100%;
      margin: 0 !important;
    }
  }
}
</style>
