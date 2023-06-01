<template>
  <v-list-group>
    <template v-slot:activator>
      <v-list-item-title>メンバー追加</v-list-item-title>
    </template>
    <v-list-item-group :value="selectedItem">
      <v-list-item v-for="user in users" :key="user.id">
        <v-list-item-content class="pa-1">
          <v-checkbox
            dense
            :label="user.name"
            class="pb-2"
            hide-details="true"
          ></v-checkbox>
        </v-list-item-content>
      </v-list-item>
    </v-list-item-group>
  </v-list-group>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import GroupCheckBox from './GroupCheckBox';

export default {
  name: 'GroupCheckBox',
  props: ['value', 'label'],
  components: { GroupCheckBox },
  data: () => ({
    selectedItem: null
  }),
  computed: {
    ...mapGetters('users', ['users', 'user'])
  },
  created() {
    this.fetchUsers();
  },
  methods: {
    ...mapActions('users', [
      'fetchUsers',
      'updateUser',
      'deleteUser',
      'setUser'
    ]),
    initUser() {
      this.setUser({
        name: '',
        visibility: true
      });
    },
    closeDialog() {
      this.setUser(null);
    },
    edit(user) {
      this.setUser(user);
    },
    del(user) {
      this.deleteUser(user.id);
    },
    toggleVisibility(user) {
      this.updateUser(user);
    }
  }
};
</script>
