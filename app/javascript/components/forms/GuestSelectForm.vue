<template>
  <v-container fluid>
    <v-row align="center">
      <v-col cols="12" md="6">
        <v-autocomplete
          v-model="selectedParticipants"
          ref="autocomplete"
          small-chips
          color="grey"
          label="参加者を追加"
          item-text="name"
          item-value="id"
          multiple
          :value="selectedParticipants"
          :items="filteredUsers"
          @input="updateSelectedValue"
          @change="onSelectionChange"
        >
          <template v-slot:selection="{ item, index }">
            <v-chip
              v-if="index < selectedParticipants.length"
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
import { mapGetters, mapMutations } from 'vuex';

export default {
  name: 'GuestSelectForm',
  props: ['value'],
  data() {
    return {
      selectedParticipants: [],
    };
  },
  computed: {
    ...mapGetters('users', ['users']),
    filteredUsers() {
      return this.users.filter(user => user.name !== '会議室A' && user.name !== 'ホールA' && user.name !== 'ハイエース');
    },
  },
  methods: {
    ...mapMutations('participants', ['setSelectedParticipants']),
    updateSelectedValue(value) {
      this.selectedParticipants = value;
      this.setSelectedParticipants(value); // Vuex stateを更新
    },
    onSelectionChange(value) {
      this.$emit('input', value);
      this.$refs.autocomplete.blur();
    },
    removeParticipant(index) {
      const newValue = [...this.selectedParticipants];
      newValue.splice(index, 1);
      this.selectedParticipants = newValue;
      this.setSelectedParticipants(newValue); // Vuex stateを更新
    },
  },
  mounted() {
    if (this.$store.state.participants.selectedParticipants.length > 0) {
      this.selectedParticipants = [...this.$store.state.participants.selectedParticipants];
    }
  },
};
</script>
