<template>
  <router-view />
</template>

<script>
import { defineComponent } from 'vue'

export default defineComponent({
  name: 'App',

  mounted() {
    console.log('🚀 [App] 애플리케이션 마운트 완료')
  }
})
</script>
