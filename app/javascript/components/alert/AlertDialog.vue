<template>
  <v-alert type="success" :value="alert" dense class="alert">
    登録しました。
  </v-alert>
</template>
<script>
export default {
  data() {
    return {
      alert: true
    };
  },
  created() {
    setTimeout(() => {
      this.alert = false;
    }, 4000);
  }
};
</script>
