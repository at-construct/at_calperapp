<template>
  <div style="display: flex; align-items: center;">
    <div style="margin-right: 10px;"></div>
    <v-checkbox v-model="isChecked" :label="label" />
  </div>
</template>

<script>
export default {
  name: 'AlldayCheck',
  props: ['value', 'label'],
  computed: {
    isChecked: {
      get() {
        return this.value;
      },
      set(value) {
        this.$emit('input', value);
      },
    },
  },
};
</script>