<template>
  <v-row>
    <v-col cols="12" md="6">
      <v-textarea
        filled
        rounded
        auto-grow
        :value="value"
        @input="$emit('input', $event)"
        label="詳細"
        rows="4"
      >
      </v-textarea>
    </v-col>
  </v-row>
</template>

<script>
export default {
  name: 'TextForm',
  props: ['value']
};
</script>
