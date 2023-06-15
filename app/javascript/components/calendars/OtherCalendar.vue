<template>
  <v-card style="width: 90%; height: 100%;">
    <v-card-text style="height: calc(100% - 80px);">
      <v-sheet max-height="10vh">
        <v-toolbar flat style="height: 40px;">
          <div style="display: flex; justify-content: center; align-items: center; width: 100%; font-size: 16px">
            {{ group.user.name }}の予定
          </div>
        </v-toolbar>
      </v-sheet>  
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
        :events="userEvents.concat(participantAllUserEvents)"
        @change="handleCalendarChange"
        style="height: 100%;"
        locale="ja-jp"
        :day-format="timestamp => new Date(timestamp.date).getDate()"
        :month-format="timestamp => new Date(timestamp.date).getMonth() + 1 + ' /'"
        @click:day="initEvent"
        @click:date="showDayEvents"
        @click:more="showDayEvents"
      ></v-calendar>

      <!-- 日付クリック時のイベント一覧ダイアログ -->
      <v-dialog
        :value="clickedDate !== null"
        persistent
        max-width="800"
        max-height="800"
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
  props: ['group'] ,
  data() {
    return {
      selectedCalendar: null,
      value: format(new Date(), 'yyyy/MM/dd'),
    }
  },
  computed: {
    ...mapGetters('calendars', ['calendars']),
    ...mapGetters('events', ['events', 'event', 'clickedDate']),
    ...mapGetters('participants', ['participantEvents','participantAllEvents']),
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
    userEvents() {
      // events の中から group.user.id と一致する user_id をもつイベントをフィルタリング
      return this.events.filter(event => event.user_id === this.group.user.id);
    },
    participantAllUserEvents() {
      return this.participantAllEvents.filter(event => event.participant_id === this.group.user.id);
    },

  },
  created() {
    this.fetchCalendars();
  },
  methods: {
    handleCalendarChange(newValue) {
      this.fetchAllEvents(); // 全てのイベントを取得
      this.fetchParticipantAllEvents(); // すべての参加者を取得
    },

    ...mapActions('calendars', ['fetchCalendars']),
    ...mapActions('events', ['fetchEvents', 'setEvent', 'setClickedDate', 'fetchAllEvents']),
    ...mapActions('participants', ['fetchParticipantEvents', 'fetchParticipantAllEvents']),
    setToday() {
      this.value = format(new Date(), 'yyyy/MM/dd');
    },
    closeDialog() {
      this.$emit('close'); // 親コンポーネントにイベントを送信
      this.setClickedDate(null); // クリックした日付を初期化
      this.fetchEvents(); // イベントを初期化
    },
    initEvent({ date }) {
      if (this.clickedDate !== null || !date) { // dateがnullの場合にもチェックする
        return;
      }
      date = date.replace(/-/g, '/');
      const [start, end] = getDefaultStartAndEnd(date);
      this.setEvent({ name: '', start, end, timed: true });
      this.setEditMode(true);
    },
    showDayEvents({ date }) {
      date = date.replace(/-/g, '/');
      this.setClickedDate(date);
    },
  }
};
</script>
