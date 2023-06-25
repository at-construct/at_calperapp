<template>
  <v-container fluid>
    <v-row align="center">
      <v-col cols="12" md="6">
        <v-autocomplete
          ref="autocomplete"
          small-chips
          color="grey"
          label="設備を選択"
          item-text="name"
          item-value="id"
          v-model="selectedParticipants"
          :items="filteredUsers"
          @input="updateSelectedValue"
          :filter="(item, queryText, itemText) => filterUsers(item, queryText, itemText)"
          multiple
          @change="onSelectionChange"
        >
          <template v-slot:selection="{ item, index }">
            <v-chip
              v-if="index < selectedParticipants.length"
              :key="item.id"
              close
              @click:close="removeFacilities(index)"
            >
              {{ item.name }}
              <v-icon small>mdi-close</v-icon>
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
  name: 'FacilitiesForm',
  props: ['value'],
  data() {
    return {
      selectedParticipants: [],
    };
  },
  computed: {
    ...mapGetters('users', ['users']),
    filteredUsers() {
      const allowedUserNames = ['会議室A', 'ホールA', 'ハイエース'];
      return this.users.filter(user => allowedUserNames.includes(user.name));
    },
  },
  methods: {
    ...mapMutations('participants', ['setSelectedParticipants']),
    filterUsers(item, queryText, itemText) {
      const allowedUserNames = ['会議室A', 'ホールA', 'ハイエース'];
      return itemText.toLowerCase().indexOf(queryText.toLowerCase()) > -1 && allowedUserNames.includes(itemText);
    },
    updateSelectedValue(value) {
      this.selectedParticipants = value;
      this.setSelectedParticipants(value); // Vuex stateを更新
    },
    onSelectionChange(value) {
      this.$emit('input', value);
      this.$refs.autocomplete.blur();
    },
    removeFacilities(index) {
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
