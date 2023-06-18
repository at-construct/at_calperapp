<template>
  <div>
    <h1>TestParticipantsDetails</h1>
    <div v-for="participant in participants" :key="participant.id">
      <h2>{{ participant.event.name }}</h2>
      <p>start: {{ participant.event.start }}</p>
      <p>end: {{ participant.event.end }}</p>
      <p>description: {{ participant.event.description }}</p>
    </div>

    <button type="submit" @click="fetchParticipants()">fetchParticipants</button>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';

export default {
  name: 'ParticipantDetails',
  computed: {
    ...mapGetters('participants', ['participants'])
  },
  methods: {
    ...mapActions('participants', [
      'fetchParticipants'
    ])
  },
};
</script>
