<template>
  <v-container fluid>
    <v-row align="center">
      <v-col cols="12" md="6">
        <v-autocomplete
          small-chips
          clearable
          color="grey"
          label="設備を選択"
          item-text="name"
          item-value="id"
          :value="value"
          :items="filteredUsers"
          @input="$emit('input', $event)"
          :filter="(item, queryText, itemText) => filterUsers(item, queryText, itemText)"
          multiple
        >
          <template v-slot:item="{ item }">
            <div class="my-2" :class="{ 'text-lg': $vuetify.breakpoint.smAndDown, 'text-xl': $vuetify.breakpoint.mdAndUp }">{{ item.name }}</div>
          </template>
        </v-autocomplete>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import { mapActions, mapGetters } from 'vuex';

export default {
  name: 'facillitiesForm',
  props: ['value'],
  data() {
    return {
      selectedUser: null,
    };
  },
  computed: {
    ...mapGetters('users', ['users']),
    filteredUsers() {
      const allowedUserNames = ['会議室A', 'ホールA', 'ハイエース']; // 選択可能なユーザーの名前
      return this.users.filter(user => allowedUserNames.includes(user.name));
    },
  },
  methods: {
    filterUsers(item, queryText, itemText) {
      const allowedUserNames = ['会議室A', 'ホールA', 'ハイエース'];
      return itemText.toLowerCase().indexOf(queryText.toLowerCase()) > -1 && allowedUserNames.includes(itemText);
    },
  },
};
</script>