<template>
  <v-card class="v-card-custom">
    <v-card-text class="v-card-text-custom">
      <v-sheet max-height="6vh">
        <v-toolbar flat class="v-toolbar-custom">
          <div class="center-content">
            {{ selectedGroup.user.name }}の予定
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
            <v-toolbar-title class="title-text">{{ title }} </v-toolbar-title>
          </v-toolbar-title>
  
          <v-btn icon class="mr-auto" @click="$refs.calendar.next()">
            <v-icon>mdi-chevron-right</v-icon>
          </v-btn>
  
          <v-btn outlined x-small class="mr-auto small-button" @click="setToday">
            今日
          </v-btn>
        </v-toolbar>
      </v-sheet>
      <v-calendar
        ref="calendar"
        v-model="value"
        :events="userEvents.concat(participantAllUserEvents)"
        @change="handleCalendarChange"
        class="v-calendar-custom"
        locale="ja-jp"
        :day-format="timestamp => new Date(timestamp.date).getDate()"
        :month-format="timestamp => new Date(timestamp.date).getMonth() + 1 + ' /'"
        @click:date="showDayEvents"
        @click:more="showDayEvents"
      ></v-calendar>

      <!-- 日付クリック時のイベント一覧ダイアログ -->
      <v-dialog
        :value="otherClickedDate !== null"
        persistent
        max-width="800"
        max-height="800"
      >
        <OtherDayEventList :userEvents="userEvents" :selectedGroup="selectedGroup" />

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
    ...mapGetters('events', ['events', 'event', 'otherClickedDate']),
    ...mapGetters('participants', ['participantAllEvents']),
    ...mapGetters('groups', ['selectedGroup']),
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
    userEvents() {
      // events の中から selectedGroup.user.id と一致する user_id をもつイベントをフィルタリング
      return this.events.filter(event => event.user_id === this.selectedGroup.user.id);
    },
    participantAllUserEvents() {
      return this.participantAllEvents.filter(event => event.participant_id === this.selectedGroup.user.id);
    },

  },
  async created() {
    await this.fetchCalendars();  // await を使って非同期処理が終了するのを待つ
    if (!this.selectedGroup) {
      // 何らかのエラーハンドリング
      console.error('selectedGroup is not defined'); 
    }
  },
  methods: {
    handleCalendarChange(newValue) {
      this.fetchAllEvents(); // 全てのイベントを取得
      this.fetchParticipantAllEvents(); // 全ての参加者を取得
    },
    ...mapActions('calendars', ['fetchCalendars']),
    ...mapActions('events', ['fetchUserSpecificEvents', 'setEvent', 'otherSetClickedDate', 'fetchAllEvents', 'resetOtherStates']),
    ...mapActions('participants', ['fetchParticipantEvents', 'fetchParticipantAllEvents', 'fetchParticipantUsers']),
    setToday() {
      this.value = format(new Date(), 'yyyy/MM/dd');
    },
    async closeDialog() {
      this.otherSetClickedDate(null);
      await this.resetOtherStates();
      this.clearDisplayedEventsInCalendar(); // 予定の表示をクリア
      this.$emit('close');
    },
    clearDisplayedEventsInCalendar() {
      this.$store.commit('events/setEvents', []); // events データを空の配列に設定
    },
    initEvent({ date }) {
      if (this.otherClickedDate !== null || !date) { // dateがnullの場合にもチェックする
        return;
      }
      date = date.replace(/-/g, '/');
      const [start, end] = getDefaultStartAndEnd(date);
      this.setOtherUserEvents({ name: '', start, end, timed: true });
    },
    showDayEvents({ date }) {
      date = date.replace(/-/g, '/');
      this.otherSetClickedDate(date);
    
      // ユーザーIDを引数としてイベントを取得
      this.fetchUserSpecificEvents(this.selectedGroup.user.id, date);
    },
  }
};
</script>

<style scoped lang="scss">
  @import "../../../assets/stylesheets/other_calendar.scss";
</style>