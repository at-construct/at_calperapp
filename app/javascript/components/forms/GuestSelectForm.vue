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
          :items="filteredUsers"
          @input="updateSelectedValue"
          @change="onSelectionChange"
        >
          <template v-slot:selection="{ item, index }">
            <v-chip
              v-if="index < selectedParticipants.length"
              :key="item.id"
              close
              @click:close="removeParticipant(item)"
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
  mounted() {
  this.selectedParticipants = [...this.vuexSelectedParticipants];
  this.$emit('input', this.selectedParticipants);  // ここで親に通知
  },
  computed: {
    ...mapGetters('users', ['users']),
    filteredUsers() {
      return this.users.filter(user => user.name !== 'A会議室' && user.name !== 'Aスタジオ' && user.name !== 'ハイエース');
    },
    vuexSelectedParticipants() {
      return this.$store.getters['participants/selectedParticipants'];
    },
  },
  methods: {
    ...mapMutations('participants', ['setSelectedParticipants']),
    updateSelectedValue(value) {
      this.selectedParticipants = value;
      this.setSelectedParticipants(value); // ここでVuexの状態も更新
      this.$emit('input', value); // 参加者情報を親コンポーネントに送信
    },
    removeParticipant(item) {
      const index = this.selectedParticipants.findIndex(participant => participant.id === item.id);
      if (index !== -1) {
        const newValue = [...this.selectedParticipants];
        newValue.splice(index, 1);
        this.selectedParticipants = newValue;
        this.setSelectedParticipants(newValue); // ここでVuexの状態も更新
        this.$emit('input', newValue);
      }
    },
    onSelectionChange(value) {
      this.setSelectedParticipants(value);
      this.$emit('input', value); // 参加者情報を親コンポーネントに送信
      this.$refs.autocomplete.blur();  // ここでフォーカスを外す
    },
  },
};
</script>
