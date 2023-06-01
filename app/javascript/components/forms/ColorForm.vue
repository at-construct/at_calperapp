<template>
  <div class="d-flex align-center">
    <v-menu offset-y>
      <template v-slot:activator="{ on }">
        <v-btn text v-on="on">
          <v-icon :color="value" size="20px">mdi-circle</v-icon>
          <v-icon color="rgba(0, 0, 0, 0.6)" size="24px">mdi-menu-down</v-icon>
        </v-btn>
      </template>
      <v-color-picker
        hide-sliders
        hide-canvas
        hide-inputs
        show-swatches
        :value="value"
        @input="$emit('input', $event)"
        :swatches="swatches"
      >
      </v-color-picker>
    </v-menu>
  </div>
</template>

<script>
export default {
  name: 'ColorForm',
  props: ['value'],
  data: () => ({
  swatches: [
    ['#9E9E9E', '#FF9800', '#FFEB3B'],
    ['#CDDC39', '#009688', '#2196F3'],
    ['#3F51B5', '#BA68C8', '#F48FB1'],
    ['#FF5722', '#795548', '#607D8B'],
    ['#E91E63', '#673AB7', '#00BCD4'],
  ],
  }),
};
</script>
