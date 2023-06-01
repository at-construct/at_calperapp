<template>
  <button type="submit" @click="fetchparticipants()">fetchParticipants</button>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';

export default {
  name: 'TestParticipantForm',
  computed: {
    ...mapGetters('participants', ['participants', 'participant'])
  },
  created() {
    this.fetchParticipants();
  },
  methods: {
    ...mapActions('participants', [
      'fetchparticipants',
      'updateParticipant',
      'deleteParticipant',
      'setParticipant'
    ])
  }
};
</script>
