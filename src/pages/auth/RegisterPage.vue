<template>
  <q-page class="flex flex-center bg-gradient">
    <div class="register-container">
      <div class="text-center q-mb-xl">
        <h4 class="text-h4 text-weight-bold q-mb-md text-primary">
          회원가입
        </h4>
        <p class="text-body1 text-grey-7">
          청년 정책 교육 플랫폼에 가입하세요
        </p>
      </div>

      <q-form @submit="onSubmit" class="q-gutter-md">
        <q-input
          v-model="formData.name"
          type="text"
          label="이름"
          outlined
          :rules="[
            val => !!val || '이름을 입력해주세요',
            val => val.length >= 2 || '이름은 최소 2자 이상이어야 합니다'
          ]"
          lazy-rules
        >
          <template v-slot:prepend>
            <q-icon name="person" />
          </template>
        </q-input>

        <q-input
          v-model="formData.email"
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
          v-model="formData.age"
          type="number"
          label="나이"
          outlined
          :rules="[
            val => !!val || '나이를 입력해주세요',
            val => val >= 15 && val <= 100 || '올바른 나이를 입력해주세요 (15-100)'
          ]"
          lazy-rules
        >
          <template v-slot:prepend>
            <q-icon name="cake" />
          </template>
        </q-input>

        <q-input
          v-model="formData.password"
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

        <q-input
          v-model="formData.confirmPassword"
          :type="isPwdConfirm ? 'password' : 'text'"
          label="비밀번호 확인"
          outlined
          :rules="[
            val => !!val || '비밀번호 확인을 입력해주세요',
            val => val === formData.password || '비밀번호가 일치하지 않습니다'
          ]"
          lazy-rules
        >
          <template v-slot:prepend>
            <q-icon name="lock" />
          </template>
          <template v-slot:append>
            <q-icon
              :name="isPwdConfirm ? 'visibility_off' : 'visibility'"
              class="cursor-pointer"
              @click="isPwdConfirm = !isPwdConfirm"
            />
          </template>
        </q-input>

        <div>
          <q-btn
            unelevated
            type="submit"
            color="primary"
            size="lg"
            label="가입하기"
            class="full-width"
            :loading="loading"
          />
        </div>
      </q-form>

      <div class="text-center q-mt-lg">
        <p class="text-body2 text-grey-6">
          이미 계정이 있으신가요?
          <a href="#" @click.prevent="goToLogin" class="text-primary">로그인</a>
        </p>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { supabase } from '../../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'RegisterPage',

  setup() {
    console.log('📝 [Register] 회원가입 페이지 로드')

    const $q = useQuasar()
    const router = useRouter()

    const formData = reactive({
      name: '',
      email: '',
      age: null,
      password: '',
      confirmPassword: ''
    })

    const isPwd = ref(true)
    const isPwdConfirm = ref(true)
    const loading = ref(false)

    async function onSubmit() {
      console.log('📝 [Register] 회원가입 시도 시작')
      console.log('📝 [Register] 입력 데이터:', {
        name: formData.name,
        email: formData.email,
        age: formData.age
      })

      // 유효성 검사
      if (formData.password !== formData.confirmPassword) {
        console.error('❌ [Register] 비밀번호 불일치')
        $q.notify({
          type: 'negative',
          message: '비밀번호가 일치하지 않습니다.',
          position: 'top'
        })
        return
      }

      loading.value = true

      try {
        if (!supabase) {
          throw new Error('Supabase 클라이언트가 초기화되지 않았습니다.')
        }

        console.log('📝 [Register] Supabase signUp 호출 시작')

        // 이메일 인증 없이 바로 가입 가능하도록 설정
        const { data, error } = await supabase.auth.signUp({
          email: formData.email,
          password: formData.password,
          options: {
            data: {
              name: formData.name,
              age: formData.age
            },
            emailRedirectTo: undefined // 이메일 인증 URL 없음
          }
        })

        if (error) {
          console.error('❌ [Register] 회원가입 실패:', error.message)
          throw error
        }

        console.log('✅ [Register] 회원가입 성공')
        console.log('✅ [Register] 사용자 정보:', data.user)
        console.log('✅ [Register] 세션 정보:', data.session)
        console.log('✅ [Register] user_metadata:', data.user?.user_metadata)

        // 이메일 인증 확인 메시지
        if (data.session) {
          // 세션이 바로 생성된 경우 (이메일 인증 불필요)
          console.log('✅ [Register] 즉시 로그인 가능 (세션 생성됨)')
          $q.notify({
            type: 'positive',
            message: '회원가입이 완료되었습니다! 환영합니다!',
            position: 'top'
          })

          console.log('📝 [Register] /main 페이지로 이동')
          router.push('/main')
        } else {
          // 세션이 없는 경우 (이메일 인증 필요)
          console.log('⚠️ [Register] 이메일 인증 필요')
          $q.notify({
            type: 'warning',
            message: '가입 완료! 이메일을 확인하여 인증을 완료해주세요.',
            position: 'top',
            timeout: 5000
          })

          console.log('📝 [Register] 로그인 페이지로 이동')
          router.push('/auth/login')
        }

      } catch (error) {
        console.error('❌ [Register] 회원가입 에러:', error)

        let errorMessage = '회원가입 중 오류가 발생했습니다.'

        if (error.message.includes('User already registered')) {
          errorMessage = '이미 가입된 이메일입니다.'
        } else if (error.message.includes('Password should be')) {
          errorMessage = '비밀번호는 최소 6자 이상이어야 합니다.'
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
        console.log('📝 [Register] 회원가입 프로세스 종료')
      }
    }

    function goToLogin() {
      console.log('🔐 [Register] 로그인 페이지로 이동')
      router.push('/auth/login')
    }

    return {
      formData,
      isPwd,
      isPwdConfirm,
      loading,
      onSubmit,
      goToLogin
    }
  }
})
</script>

<style lang="scss" scoped>
.bg-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.register-container {
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
