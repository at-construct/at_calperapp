<template>
  <v-card class="pb-8">
    <v-card-actions class="d-flex justify-end">
      <v-btn icon @click="closeDialog">
        <v-icon>mdi-close</v-icon>
      </v-btn>
    </v-card-actions>
    <v-card-title class="d-flex justify-center">
      {{ formatDateToJa(otherClickedDate) }}
    </v-card-title>
    <v-card-text>
      <v-list>
        <v-list-item v-for="event in otherDayEvents" :key="event.id">
          <v-list-item-content class="pa-0">
            <v-btn
              depressed
              :color="event.color"
              class="white--text justify-start"
            >
              <span class="event-date">{{ event.startDate.slice(5) }}{{ event.timed ? ' ' + event.startTime : ''}} ~
              {{ event.endDate.slice(5) }} 
              {{ event.timed ? event.endTime : ' 終日' }}</span>
              <span class="event-name">{{ event.name }}</span>
            </v-btn>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-card-text>
  </v-card>
</template>

<script>
import { format } from 'date-fns';
import { mapGetters, mapActions } from 'vuex';
import { formatDateToJa } from '../../functions/datetime';


export default {
  name: 'OtherDayEventList',
  data: () => ({
    value: format(new Date(), 'yyyy/MM/dd'),
    drawer: false,
    group: null,
    dialog: null,
  }),
  computed: {
    ...mapGetters('events', ['otherDayEvents', 'otherClickedDate']),
    ...mapGetters('groups', ['selectedGroup']), 
  },
  methods: {
    ...mapActions('events', ['otherSetClickedDate']),
    formatDateToJa,
    closeDialog() {
      this.otherSetClickedDate(null);
    }
  }
};
</script>

<style scoped lang="scss">
  @import "../../../assets/stylesheets/other_day_event_list.scss";
</style>