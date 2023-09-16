<template>
  <v-container fluid>
    <v-row align="center">
      <v-col cols="12" md="6">
        <v-autocomplete
          v-model="selectedParticipants"
          ref="autocomplete"
          small-chips
          color="grey"
          label="設備を追加"
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
  name: 'FacillitiesForm',
  props: ['value'],
  data() {
    return {
      selectedParticipants: [],
    };
  },
  computed: {
    ...mapGetters('users', ['users']),
    filteredUsers() {
      return this.users.filter(user => user.name === '6F会議室(ソファー)' || user.name === '7Fテーブル' || user.name === 'ハイエース'|| user.name === '9Fスタジオ');
    },
  },
  methods: {
    ...mapMutations('participants', ['setSelectedParticipants']),
    updateSelectedValue(value) {
      this.selectedParticipants = value;
      this.setSelectedParticipants(value);
      this.$emit('input', value); // 参加者情報を親コンポーネントに送信
    },
    onSelectionChange(value) {
      this.setSelectedParticipants(value);
      this.$emit('input', value); // 参加者情報を親コンポーネントに送信
      this.$refs.autocomplete.blur();
    },
    removeParticipant(item) {
      console.log("Removing participant: ", item);  // アイテムが正確に渡されているか確認
    
      const index = this.selectedParticipants.findIndex(participant => participant.id === item.id);
      console.log("Found index: ", index);  // 正確なインデックスが見つかったか確認
    
      if (index !== -1) {
        const newValue = [...this.selectedParticipants];
        newValue.splice(index, 1);
        this.selectedParticipants = newValue;
        this.setSelectedParticipants(newValue);
        this.$emit('input', newValue);
        console.log("New value of selectedParticipants: ", this.selectedParticipants);  // 新しい値が正確か確認
      }
    },
  },
  mounted() {
    if (this.$store.state.participants.selectedParticipants.length > 0) {
      this.selectedParticipants = [...this.$store.state.participants.selectedParticipants];
      console.log("Mounted with initial selectedParticipants: ", this.selectedParticipants);  // 初期状態が正しいか確認
    }
  }
};
</script>
