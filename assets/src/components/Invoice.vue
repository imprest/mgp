<template>
  <div>
    {{ invoice }}
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  name: 'Invoice',
  computed: {
    ...mapState([
      'invoice'
    ])
  }
}
</script>

<style scoped lang="scss">
</style>
