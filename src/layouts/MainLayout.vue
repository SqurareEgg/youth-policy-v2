<template>
  <q-layout view="lHh Lpr lFf">
    <!-- Header -->
    <q-header elevated class="bg-primary text-white">
      <q-toolbar>
        <q-btn
          flat
          dense
          round
          icon="arrow_back"
          v-if="showBackButton"
          @click="$router.go(-1)"
        />
        <q-toolbar-title>
          {{ pageTitle }}
        </q-toolbar-title>
        <q-btn flat round dense icon="person" @click="goToProfile" />
        <q-btn flat round dense icon="logout" @click="logout" />
      </q-toolbar>
    </q-header>

    <!-- Page Content -->
    <q-page-container>
      <router-view />
    </q-page-container>
  </q-layout>
</template>

<script>
import { defineComponent, ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'MainLayout',

  setup() {
    const $q = useQuasar()
    const router = useRouter()
    const route = useRoute()

    const showBackButton = computed(() => {
      return route.name !== 'main'
    })

    const pageTitle = computed(() => {
      return route.meta.title || '청년 정책 교육'
    })

    function goToProfile() {
      console.log('👤 [MainLayout] 프로필 페이지로 이동')
      router.push('/profile')
    }

    async function logout() {
      console.log('🔓 [MainLayout] 로그아웃 시작')
      try {
        const { error } = await supabase.auth.signOut()
        if (error) throw error

        console.log('✅ [MainLayout] 로그아웃 성공')
        $q.notify({
          type: 'positive',
          message: '로그아웃되었습니다.'
        })
        router.push('/landing')
      } catch (error) {
        console.error('❌ [MainLayout] 로그아웃 실패:', error)
        $q.notify({
          type: 'negative',
          message: '로그아웃 중 오류가 발생했습니다.'
        })
      }
    }

    onMounted(() => {
      console.log('🔧 [MainLayout] 레이아웃 마운트 완료')
    })

    return {
      showBackButton,
      pageTitle,
      goToProfile,
      logout
    }
  }
})
</script>

<style lang="scss" scoped>
.q-toolbar {
  min-height: 56px;
}
</style>
