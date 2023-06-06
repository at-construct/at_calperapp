<template>
  <v-container fluid>
    <v-row align="center">
      <v-col cols="12" md="6">
        <v-autocomplete
          small-chips
          clearable
          color="grey"
          label="参加者を追加"
          item-text="name"
          item-value="id"
          multiple
          :value="value"
          :items="filteredUsers"
          @input="$emit('input', $event)"
          @change="onSelectionChange"
        >
          <template v-slot:selection="{ item, index }">
            <v-chip
              v-if="index < value.length"
              :key="item.id"
              close
              @click:close="removeParticipant(index)"
            >
              {{ item.name }}
            </v-chip>
          </template>
          <template v-slot:item="{ item }">
            <div class="my-2 font-weight-medium headline" :class="{ 'text-lg': $vuetify.breakpoint.smAndDown, 'text-xl': $vuetify.breakpoint.mdAndUp }">{{ item.name }}</div>
          </template>
        </v-autocomplete>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import { mapActions, mapGetters } from 'vuex';

export default {
  name: 'GuestSelectForm',
  props: ['value'],
  data() {
    return {
      selectedUser: null,
    };
  },
  computed: {
    ...mapGetters('users', ['users']),
    filteredUsers() {
      return this.users.filter(user => user.name !== '会議室A' && user.name !== 'ホールA' && user.name !== 'ハイエース');
    },
  },
  created() {
    console.log(this.value);
  },
  methods: {
    onSelectionChange(value) {
      this.$emit('input', value);
    },
    removeParticipant(index) {
      const newValue = [...this.value];
      newValue.splice(index, 1);
      this.$emit('input', newValue);
    },
  },
};
</script>