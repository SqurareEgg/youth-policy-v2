<template>
  <q-page class="video-page">
    <!-- 로딩 상태 -->
    <div v-if="loading" class="flex flex-center" style="min-height: 400px">
      <div class="text-center">
        <q-spinner color="primary" size="50px" />
        <div class="text-body1 text-grey-7 q-mt-md">영상 데이터 불러오는 중...</div>
      </div>
    </div>

    <!-- 영상 컨텐츠 -->
    <div v-else class="page-container">
      <div class="header-section">
        <q-btn flat icon="arrow_back" label="돌아가기" @click="goBack" class="q-mb-md" />
        <h4 class="text-h4 text-weight-bold q-mb-xs">영상 학습</h4>
        <p class="text-body1 text-grey-7 q-mb-md">{{ category.title }}에 대한 교육 영상입니다.</p>

        <!-- 진도 표시 -->
        <q-card flat bordered class="progress-card q-mb-lg">
          <q-card-section>
            <div class="row items-center">
              <div class="col">
                <div class="text-caption text-grey-7">영상 시청 시간</div>
                <div class="text-h6 text-weight-bold text-primary">
                  {{ formatTime(watchTime) }} / {{ formatTime(video.duration || 0) }}
                </div>
              </div>
              <div class="col-auto">
                <q-circular-progress
                  :value="progressPercentage"
                  size="60px"
                  :thickness="0.15"
                  color="red"
                  track-color="grey-3"
                  show-value
                  class="text-red"
                >
                  <template v-slot:default>
                    <div class="text-caption">{{ progressPercentage }}%</div>
                  </template>
                </q-circular-progress>
              </div>
            </div>
            <q-linear-progress :value="progressPercentage / 100" color="red" class="q-mt-md" />
          </q-card-section>
        </q-card>
      </div>

      <!-- 영상이 없는 경우 -->
      <div v-if="!video.id" class="text-center q-pa-lg">
        <q-icon name="play_circle" size="64px" color="grey-5" class="q-mb-md" />
        <div class="text-h6 text-grey-6">아직 등록된 영상이 없습니다.</div>
      </div>

      <!-- 영상 플레이어 -->
      <div v-else>
        <q-card flat bordered class="video-card q-mb-lg">
          <q-card-section>
            <div class="text-h6 text-weight-bold q-mb-md">{{ video.title }}</div>
            <div v-if="video.description" class="text-body2 text-grey-7 q-mb-md">{{ video.description }}</div>

            <!-- YouTube iframe -->
            <div class="video-container">
              <iframe
                ref="videoIframe"
                :src="`https://www.youtube.com/embed/${youtubeId}?enablejsapi=1&origin=${origin}`"
                frameborder="0"
                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                allowfullscreen
              ></iframe>
            </div>

            <!-- 시청 시간 추적 안내 -->
            <div class="q-mt-md text-center">
              <q-chip v-if="isTracking" color="red" text-color="white" icon="play_arrow">
                시청 시간 추적 중...
              </q-chip>
              <q-chip v-else color="grey" text-color="white" icon="pause">
                일시정지됨
              </q-chip>
            </div>
          </q-card-section>
        </q-card>

        <!-- 수동 추적 버튼 (YouTube API 없이 사용) -->
        <q-card flat bordered class="control-card q-mb-lg">
          <q-card-section>
            <div class="text-subtitle2 q-mb-md">수동 제어</div>
            <div class="row q-gutter-sm">
              <q-btn
                v-if="!isTracking"
                color="red"
                icon="play_arrow"
                label="시청 시작"
                @click="startTracking"
                :disabled="completed"
              />
              <q-btn
                v-else
                color="grey"
                icon="pause"
                label="일시정지"
                @click="stopTracking"
              />
              <q-btn
                color="primary"
                icon="restart_alt"
                label="처음부터"
                @click="resetTracking"
                outline
              />
            </div>
            <div class="text-caption text-grey-7 q-mt-sm">
              영상을 시청하는 동안 '시청 시작' 버튼을 누르세요. 매 5초마다 자동으로 진도가 저장됩니다.
            </div>
          </q-card-section>
        </q-card>

        <!-- 완료 안내 -->
        <q-card v-if="completed" flat bordered class="completion-card">
          <q-card-section class="text-center">
            <q-icon name="celebration" size="48px" color="red" class="q-mb-md" />
            <div class="text-h6 text-weight-bold text-red q-mb-sm">영상 학습 완료!</div>
            <div class="text-body2 text-grey-7 q-mb-md">영상을 모두 시청했습니다. (40% 달성)</div>
            <q-btn color="primary" label="퀴즈로 이동" @click="goToQuiz" />
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<script>
import { defineComponent, ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { supabase } from '../../boot/supabase'
import { useQuasar } from 'quasar'

export default defineComponent({
  name: 'VideoPage',

  setup() {
    console.log('🎬 [Video] 영상 학습 페이지 로드')

    const $q = useQuasar()
    const router = useRouter()
    const route = useRoute()

    const loading = ref(true)
    const category = ref({})
    const video = ref({})
    const userId = ref(null)
    const watchTime = ref(0)
    const isTracking = ref(false)
    const completed = ref(false)
    const trackingInterval = ref(null)
    const videoIframe = ref(null)
    const origin = ref(window.location.origin)

    // YouTube ID 추출
    const youtubeId = computed(() => {
      if (!video.value.video_url) return ''

      // YouTube URL에서 ID 추출
      const url = video.value.video_url
      let id = ''

      // youtu.be/ID 형식
      if (url.includes('youtu.be/')) {
        id = url.split('youtu.be/')[1].split('?')[0]
      }
      // youtube.com/watch?v=ID 형식
      else if (url.includes('watch?v=')) {
        id = url.split('watch?v=')[1].split('&')[0]
      }
      // youtube.com/embed/ID 형식
      else if (url.includes('embed/')) {
        id = url.split('embed/')[1].split('?')[0]
      }

      console.log('🎬 [Video] YouTube ID:', id)
      return id
    })

    // 진도율 계산
    const progressPercentage = computed(() => {
      if (!video.value.duration || video.value.duration === 0) return 0
      const percentage = Math.min(100, Math.round((watchTime.value / video.value.duration) * 100))
      return percentage
    })

    // 시간 포맷 (초 -> MM:SS)
    function formatTime(seconds) {
      const mins = Math.floor(seconds / 60)
      const secs = seconds % 60
      return `${mins}:${secs.toString().padStart(2, '0')}`
    }

    // 데이터 로드
    async function loadVideoData() {
      console.log('🎬 [Video] 카테고리 ID:', route.params.id)

      try {
        if (!supabase) {
          throw new Error('Supabase 미설정')
        }

        // 사용자 정보 가져오기
        const { data: { user }, error: userError } = await supabase.auth.getUser()
        if (userError || !user) {
          throw new Error('로그인 필요')
        }
        userId.value = user.id
        console.log('🎬 [Video] 사용자 ID:', userId.value)

        // 카테고리 정보 가져오기
        const { data: categoryData, error: categoryError } = await supabase
          .from('education_categories')
          .select('*')
          .eq('id', route.params.id)
          .single()

        if (categoryError) throw categoryError
        category.value = categoryData
        console.log('🎬 [Video] 카테고리:', categoryData.title)

        // 영상 정보 가져오기 (첫 번째 영상만)
        const { data: videoData, error: videoError } = await supabase
          .from('category_videos')
          .select('*')
          .eq('category_id', route.params.id)
          .limit(1)
          .single()

        if (videoError && videoError.code !== 'PGRST116') {
          throw videoError
        }

        if (videoData) {
          video.value = videoData
          console.log('🎬 [Video] 영상:', videoData.title)
          console.log('🎬 [Video] 영상 길이:', videoData.duration, '초')

          // 기존 진도 가져오기
          await loadProgress()
        } else {
          console.log('🎬 [Video] 영상 없음')
        }

      } catch (error) {
        console.error('❌ [Video] 데이터 로딩 에러:', error)
        $q.notify({
          type: 'negative',
          message: '영상 데이터를 불러올 수 없습니다.',
          position: 'top'
        })
      } finally {
        loading.value = false
      }
    }

    // 진도 로드
    async function loadProgress() {
      try {
        const { data: progressData, error: progressError } = await supabase
          .from('user_category_progress')
          .select('video_watch_time, video_completed, video_duration')
          .eq('user_id', userId.value)
          .eq('category_id', route.params.id)
          .single()

        if (progressError && progressError.code !== 'PGRST116') {
          throw progressError
        }

        if (progressData) {
          watchTime.value = progressData.video_watch_time || 0
          completed.value = progressData.video_completed || false
          console.log('🎬 [Video] 기존 시청 시간:', watchTime.value, '초')
          console.log('🎬 [Video] 완료 여부:', completed.value)

          // video_duration이 설정되지 않았으면 업데이트
          if (!progressData.video_duration || progressData.video_duration === 0) {
            await updateVideoDuration()
          }
        } else {
          // 진도 데이터가 없으면 생성
          await updateVideoDuration()
        }

      } catch (error) {
        console.error('❌ [Video] 진도 로드 에러:', error)
      }
    }

    // 영상 길이 업데이트
    async function updateVideoDuration() {
      try {
        const { error: updateError } = await supabase
          .from('user_category_progress')
          .update({
            video_duration: video.value.duration
          })
          .eq('user_id', userId.value)
          .eq('category_id', route.params.id)

        if (updateError) throw updateError
        console.log('✅ [Video] 영상 길이 업데이트:', video.value.duration, '초')

      } catch (error) {
        console.error('❌ [Video] 영상 길이 업데이트 에러:', error)
      }
    }

    // 시청 시작
    function startTracking() {
      if (completed.value) {
        console.log('🎬 [Video] 이미 완료된 영상')
        return
      }

      console.log('🎬 [Video] 시청 시작')
      isTracking.value = true

      // 5초마다 시청 시간 증가 및 저장
      trackingInterval.value = setInterval(async () => {
        watchTime.value += 5

        console.log('🎬 [Video] 시청 시간:', watchTime.value, '/', video.value.duration)

        // 진도 저장
        await saveProgress()

        // 영상 완료 체크
        if (watchTime.value >= video.value.duration) {
          await completeVideo()
        }
      }, 5000)
    }

    // 시청 일시정지
    function stopTracking() {
      console.log('🎬 [Video] 시청 일시정지')
      isTracking.value = false

      if (trackingInterval.value) {
        clearInterval(trackingInterval.value)
        trackingInterval.value = null
      }
    }

    // 처음부터 다시 시작
    function resetTracking() {
      console.log('🎬 [Video] 처음부터 다시 시작')
      stopTracking()
      watchTime.value = 0
      completed.value = false
      saveProgress()
    }

    // 진도 저장
    async function saveProgress() {
      try {
        const { error: updateError } = await supabase
          .from('user_category_progress')
          .update({
            video_watch_time: watchTime.value
          })
          .eq('user_id', userId.value)
          .eq('category_id', route.params.id)

        if (updateError) throw updateError
        console.log('✅ [Video] 진도 저장:', watchTime.value, '초')

      } catch (error) {
        console.error('❌ [Video] 진도 저장 에러:', error)
      }
    }

    // 영상 완료 처리
    async function completeVideo() {
      console.log('🎬 [Video] 영상 완료 처리')
      stopTracking()
      completed.value = true

      try {
        const { error: updateError } = await supabase
          .from('user_category_progress')
          .update({
            video_watch_time: video.value.duration,
            video_completed: true,
            video_completed_at: new Date().toISOString()
          })
          .eq('user_id', userId.value)
          .eq('category_id', route.params.id)

        if (updateError) throw updateError

        console.log('✅ [Video] 영상 완료 업데이트 (40% 달성)')

        $q.notify({
          type: 'positive',
          message: '영상 학습 완료! 40% 진도가 반영되었습니다.',
          position: 'top',
          icon: 'celebration'
        })

      } catch (error) {
        console.error('❌ [Video] 완료 처리 에러:', error)
      }
    }

    // 뒤로 가기
    function goBack() {
      stopTracking()
      router.push({ name: 'category-detail', params: { id: route.params.id } })
    }

    // 퀴즈로 이동
    function goToQuiz() {
      stopTracking()
      router.push({ name: 'quiz', params: { id: route.params.id } })
    }

    onMounted(() => {
      loadVideoData()
    })

    onBeforeUnmount(() => {
      // 페이지 떠날 때 추적 중지
      stopTracking()
    })

    return {
      loading,
      category,
      video,
      watchTime,
      isTracking,
      completed,
      youtubeId,
      progressPercentage,
      videoIframe,
      origin,
      formatTime,
      startTracking,
      stopTracking,
      resetTracking,
      goBack,
      goToQuiz
    }
  }
})
</script>

<style lang="scss" scoped>
.video-page {
  background-color: #f5f5f5;
}

.page-container {
  max-width: 1000px;
  margin: 0 auto;
  padding: 2rem 1rem;
}

.header-section {
  margin-bottom: 2rem;
}

.progress-card {
  background: white;
}

.video-card {
  background: white;
}

.video-container {
  position: relative;
  width: 100%;
  padding-bottom: 56.25%; /* 16:9 비율 */
  height: 0;
  overflow: hidden;
  background: #000;
  border-radius: 8px;

  iframe {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
  }
}

.control-card {
  background: white;
}

.completion-card {
  background: linear-gradient(135deg, #fff5f5 0%, #ffe0e0 100%);
}
</style>
