<template>
  <q-page class="q-pa-md">
    <div class="profile-container">
      <h5 class="text-h5 q-mb-md">마이페이지</h5>
      <p class="text-body1 q-mb-lg">프로필 및 학습 진도 페이지 - 준비 중</p>

      <q-card>
        <q-card-section>
          <div class="text-body1">
            여기에 프로필 정보와 이수율이 표시됩니다.
          </div>
        </q-card-section>
      </q-card>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, onMounted } from 'vue'

export default defineComponent({
  name: 'ProfilePage',

  setup() {
    console.log('👤 [Profile] 프로필 페이지 로드')

    onMounted(() => {
      console.log('👤 [Profile] 마운트 완료')
    })

    return {}
  }
})
</script>
