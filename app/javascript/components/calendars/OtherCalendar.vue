<template>
  <v-card style="width: 90%; height: 90%;">
    <v-card-text style="height: calc(100% - 64px);">
      <v-sheet max-height="10vh">
        <v-toolbar flat>
          <v-btn icon @click="closeDialog">
            <v-icon>mdi-close</v-icon>
          </v-btn>
  
          <v-btn icon class="ml-auto" @click="$refs.calendar.prev()">
            <v-icon>mdi-chevron-left</v-icon>
          </v-btn>
  
          <v-toolbar-title>
            <v-toolbar-title style="font-size: 1.5em">{{ title }} </v-toolbar-title>
          </v-toolbar-title>
  
          <v-btn icon class="mr-auto" @click="$refs.calendar.next()">
            <v-icon>mdi-chevron-right</v-icon>
          </v-btn>
  
          <v-btn outlined x-small class="mr-auto" @click="setToday" style="font-size: 10px;">
            今日
          </v-btn>
        </v-toolbar>
      </v-sheet>
  
      <v-calendar
        ref="calendar"
        v-model="value"
        :events="events"
        @change="fetchEvents"
        style="height: 100%;"
        locale="ja-jp"
        :day-format="timestamp => new Date(timestamp.date).getDate()"
        :month-format="timestamp => new Date(timestamp.date).getMonth() + 1 + ' /'"
        @click:date="otherShowDayEvents"
        @click:more="otherShowDayEvents"
      ></v-calendar>

      <!-- 日付クリック時のイベント一覧ダイアログ -->
      <v-dialog
        :value="otherClickedDate !== null"
        persistent
        max-width="800"
        max-high="800"
      >
        <OtherDayEventList />
      </v-dialog>
      
    </v-card-text>
  </v-card>
</template>

<script>
import { format } from 'date-fns';
import { mapActions, mapGetters } from 'vuex';
import OtherDayEventList from '../events/OtherDayEventList';

export default {
  name: 'OtherCalendar',
  components: { OtherDayEventList },
  data() {
    return {
      selectedCalendar: null,
      value: format(new Date(), 'yyyy/MM/dd'),
    }
  },
  computed: {
    ...mapGetters('calendars', ['calendars']),
    ...mapGetters('events', ['events', 'otherClickedDate']),
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
  },
  created() {
    this.fetchCalendars();
  },
  methods: {
    ...mapActions('calendars', ['fetchCalendars']),
    ...mapActions('events', ['fetchEvents','otherSetClickedDate', 'otherShowDayEvents']),

    setToday() {
      this.value = format(new Date(), 'yyyy/MM/dd');
    },
    closeDialog() {
      this.$emit('close'); // クローズイベントを親コンポーネントに通知
      this.otherSetClickedDate(null);
    },
    otherShowDayEvents({ date }) {
      date = date.replace(/-/g, '/');
      this.otherSetClickedDate(date);
    },
  }
};
</script>

<style>
.saturday {
  background: rgba(200, 200, 250, 0.2);
}
.sunday {
  background: rgba(250, 200, 200, 0.2);
}
</style>