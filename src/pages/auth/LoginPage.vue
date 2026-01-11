<template>
  <q-page class="flex flex-center bg-gradient">
    <div class="login-container">
      <div class="text-center q-mb-xl">
        <h4 class="text-h4 text-weight-bold q-mb-md text-primary">
          로그인
        </h4>
        <p class="text-body1 text-grey-7">
          청년 정책 교육 플랫폼에 오신 것을 환영합니다
        </p>
      </div>

      <q-form @submit="onSubmit" class="q-gutter-md">
        <q-input
          v-model="email"
          type="email"
          label="이메일"
          outlined
          :rules="[
            val => !!val || '이메일을 입력해주세요',
            val => /.+@.+\..+/.test(val) || '올바른 이메일 형식이 아닙니다'
          ]"
          lazy-rules
        >
          <template v-slot:prepend>
            <q-icon name="mail" />
          </template>
        </q-input>

        <q-input
          v-model="password"
          :type="isPwd ? 'password' : 'text'"
          label="비밀번호"
          outlined
          :rules="[
            val => !!val || '비밀번호를 입력해주세요',
            val => val.length >= 6 || '비밀번호는 최소 6자 이상이어야 합니다'
          ]"
          lazy-rules
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
          <template v-slot:append>
            <q-icon
              :name="isPwd ? 'visibility_off' : 'visibility'"
              class="cursor-pointer"
              @click="isPwd = !isPwd"
            />
          </template>
        </q-input>

        <div>
          <q-btn
            unelevated
            type="submit"
            color="primary"
            size="lg"
            label="로그인"
            class="full-width"
            :loading="loading"
          />
        </div>
      </q-form>

      <div class="text-center q-mt-lg">
        <p class="text-body2 text-grey-6">
          계정이 없으신가요?
          <a href="#" @click.prevent="goToRegister" class="text-primary">회원가입</a>
        </p>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'LoginPage',

  setup() {
    console.log('🔐 [Login] 로그인 페이지 로드')

    const $q = useQuasar()
    const router = useRouter()

    const email = ref('')
    const password = ref('')
    const isPwd = ref(true)
    const loading = ref(false)

    async function onSubmit() {
      console.log('🔐 [Login] 로그인 시도 시작')
      console.log('🔐 [Login] 이메일:', email.value)

      loading.value = true

      try {
        if (!supabase) {
          throw new Error('Supabase 클라이언트가 초기화되지 않았습니다.')
        }

        const { data, error } = await supabase.auth.signInWithPassword({
          email: email.value,
          password: password.value
        })

        if (error) {
          console.error('❌ [Login] 로그인 실패:', error.message)
          throw error
        }

        console.log('✅ [Login] 로그인 성공')
        console.log('✅ [Login] 사용자 정보:', data.user)
        console.log('✅ [Login] 세션 정보:', data.session)

        $q.notify({
          type: 'positive',
          message: '로그인에 성공했습니다!',
          position: 'top'
        })

        console.log('🔐 [Login] /main 페이지로 이동')
        router.push('/main')

      } catch (error) {
        console.error('❌ [Login] 로그인 에러:', error)

        let errorMessage = '로그인 중 오류가 발생했습니다.'

        if (error.message.includes('Invalid login credentials')) {
          errorMessage = '이메일 또는 비밀번호가 올바르지 않습니다.'
        } else if (error.message.includes('Email not confirmed')) {
          errorMessage = '이메일 인증이 필요합니다.'
        } else if (error.message.includes('Supabase')) {
          errorMessage = 'Supabase 연결 오류가 발생했습니다. 설정을 확인해주세요.'
        }

        $q.notify({
          type: 'negative',
          message: errorMessage,
          position: 'top',
          timeout: 3000
        })
      } finally {
        loading.value = false
        console.log('🔐 [Login] 로그인 프로세스 종료')
      }
    }

    function goToRegister() {
      console.log('📝 [Login] 회원가입 페이지로 이동')
      router.push('/auth/register')
    }

    return {
      email,
      password,
      isPwd,
      loading,
      onSubmit,
      goToRegister
    }
  }
})
</script>

<style lang="scss" scoped>
.bg-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.login-container {
  max-width: 450px;
  width: 90%;
  padding: 2.5rem;
  background: white;
  border-radius: 16px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

a {
  text-decoration: none;
  font-weight: 500;
  &:hover {
    text-decoration: underline;
  }
}
</style>
