<template>
  <q-page class="flex flex-center bg-gradient">
    <div class="landing-container">
      <div class="text-center q-mb-xl">
        <h3 class="text-h3 text-weight-bold q-mb-md text-primary">
          청년 정책 교육 플랫폼
        </h3>
        <p class="text-h6 text-grey-7">
          청년을 위한 6가지 필수 정책 교육
        </p>
      </div>

      <div class="button-group">
        <q-btn
          unelevated
          color="primary"
          size="lg"
          label="로그인"
          class="full-width q-mb-md"
          @click="goToLogin"
        />
        <q-btn
          outline
          color="primary"
          size="lg"
          label="회원가입"
          class="full-width"
          @click="goToRegister"
        />
      </div>

      <div class="text-center q-mt-lg text-grey-6">
        <p class="text-caption">
          이미 계정이 있으신가요? <a href="#" @click.prevent="goToLogin" class="text-primary">로그인</a>
        </p>
        <p class="text-caption">
          처음이신가요? <a href="#" @click.prevent="goToRegister" class="text-primary">회원가입</a>
        </p>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent } from 'vue'
import { useRouter } from 'vue-router'

export default defineComponent({
  name: 'LandingPage',

  setup() {
    const router = useRouter()

    function goToLogin() {
      console.log('🔐 [Landing] 로그인 페이지로 이동')
      router.push('/auth/login')
    }

    function goToRegister() {
      console.log('📝 [Landing] 회원가입 페이지로 이동')
      router.push('/auth/register')
    }

    console.log('🏠 [Landing] 랜딩 페이지 로드')

    return {
      goToLogin,
      goToRegister
    }
  }
})
</script>

<style lang="scss" scoped>
.bg-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.landing-container {
  max-width: 400px;
  width: 90%;
  padding: 2rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.button-group {
  margin-top: 2rem;
}

a {
  text-decoration: none;
  font-weight: 500;
}
</style>
