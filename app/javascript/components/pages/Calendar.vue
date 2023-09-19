<template>
  <div>
    <!-- ヘッダー -->
    <v-sheet max-height="10vh">
      <v-toolbar flat>
        <v-app-bar-nav-icon @click.stop="drawer = !drawer" class="ml-auto">
        </v-app-bar-nav-icon>

        <v-btn icon class="ml-auto" @click="$refs.calendar.prev()">
          <v-icon>mdi-chevron-left</v-icon>
        </v-btn>

        <v-toolbar-title>
          <v-toolbar-title class="v-toolbar-title">{{ title }}</v-toolbar-title>
        </v-toolbar-title>

        <v-btn icon class="mr-auto" @click="$refs.calendar.next()">
          <v-icon>mdi-chevron-right</v-icon>
        </v-btn>

        <v-btn outlined x-small class="mr-auto btn-small" @click="setToday">
          今日
        </v-btn>

        <!-- ヘッダーの中のベルマークのボタン -->
        <v-btn icon class="mr-auto" @click="showNotificationDialog">
          <v-icon>mdi-bell-outline</v-icon>
          <v-badge
            v-if="hasUnreadNotifications"
            color="red"
            content-class="notification-badge"
            dot
          ></v-badge>
        </v-btn>
      
        <v-dialog v-model="dialog" :key="dialogKey">
          <NotificationDialog @close="dialog = false" />
        </v-dialog>

      </v-toolbar>
    </v-sheet>

    <v-sheet height="100vh" class="d-flex">
      <!-- 左側ドロワー -->
      <v-navigation-drawer v-model="drawer" absolute left temporary>
      <div style="height: 100vh; overflow-y: auto;">
        <v-list-item-group v-model="group">
          <v-list-item @click="type = 'day'">
            <v-icon>mdi-view-day-outline</v-icon>
            <v-list-item-title class="list-item-title">　1日</v-list-item-title>
          </v-list-item>
          <v-list-item @click="type = 'week'">
            <v-icon>mdi-view-week-outline</v-icon>
            <v-list-item-title class="list-item-title">　週</v-list-item-title>
          </v-list-item>
          <v-list-item @click="type = 'month'">
            <v-icon>mdi-grid</v-icon>
            <v-list-item-title class="list-item-title">　月</v-list-item-title>
          </v-list-item>
        </v-list-item-group>
        <CalendarList />
      </div>
      </v-navigation-drawer>

      <!-- ホームカレンダー -->
      <!-- :events="events.concat(participantEvents)" 削除した-->
      <v-sheet height="100vh" class="flex">
        <v-calendar
          ref="calendar"
          v-model="value"
          :events="events"
          :type="type"
          @change="handleChange"
          color="primary"
          locale="ja-jp"
          :day-format="timestamp => new Date(timestamp.date).getDate()"
          :month-format="timestamp => new Date(timestamp.date).getMonth() + 1 + ' /'"
          @click:event="showEvent"
          @click:day="initEvent"
          @click:date="showDayEvents"
          @click:more="showDayEvents"
        ></v-calendar>
      </v-sheet>
    </v-sheet>

    <!-- カレンダー直下にプラスボタン-->
    <v-sheet max-height="8vh">
      <v-toolbar flat>
        <v-row justify="center">
          <v-dialog
            :value="event !== null"
            fullscreen
            hide-overlay
            transition="dialog-bottom-transition"
          >
            <template v-slot:activator="{ on, ...attrs }">
              <v-btn
                fab
                v-bind="attrs"
                v-on="on"
                small
                @click="initNewEvent"
              >
                <v-icon>
                  mdi-plus
                </v-icon>
              </v-btn>
            </template>
          </v-dialog>
        </v-row>
      </v-toolbar>
    </v-sheet>

    <!-- イベント作成ダイアログ -->
    <v-row justify="center">
      <v-dialog
        :value="event !== null"
        fullscreen
        hide-overlay
        transition="dialog-bottom-transition"
      >
        <EventDetailDialog v-if="event !== null && !isEditMode" />
        <EventFormDialog v-if="event !== null && isEditMode" />
      </v-dialog>
      
    <!-- 日付クリック時のイベント一覧ダイアログ -->
      <v-dialog
        :value="clickedDate !== null"
        persistent
        max-width="800"
        max-high="800"
      >
        <DayEventList />
      </v-dialog>
    </v-row>
  </div>
</template>

<script>
import { format } from 'date-fns';
import { mapGetters, mapActions } from 'vuex';
import EventDetailDialog from '../events/EventDetailDialog';
import EventFormDialog from '../events/EventFormDialog';
import DayEventList from '../events/DayEventList';
import CalendarList from '../calendars/CalendarList';
import { getDefaultStartAndEnd } from '../../functions/datetime';
import NotificationDialog from '../notifications/NotificationDialog';

export default {
  name: 'Calendar',
  components: {
    EventDetailDialog,
    EventFormDialog,
    DayEventList,
    CalendarList,
    NotificationDialog,
  },
  data: () => ({
    value: format(new Date(), 'yyyy/MM/dd'),
    today: format(new Date(), 'yyyy/MM/dd'),
    drawer: false,
    group: null,
    type: 'month',
    dialog: false,
    dialogKey: 0,
  }),
  watch: {
    group() {
      this.drawer = false;
    },
    dialog(newVal) {
        console.log('Dialog value changed to:', newVal);
    },
  },
  computed: {
    ...mapGetters('events', ['events', 'event', 'isEditMode', 'clickedDate']),
    ...mapGetters('participants', ['participantEvents', 'participantUsers']),
    ...mapGetters('notifications', ['hasUnreadNotifications']),
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
  },
  created() {
    console.log("Calling fetchUnreadNotificationsCount...");  // この行を追加
    this.fetchUnreadNotificationsCount();
  },
  methods: {
    handleChange() {
      this.fetchEvents();
      this.fetchParticipantEvents();
      this.changeColor();
    },
    ...mapActions('events', [
      'fetchEvents',
      'setEvent',
      'setEditMode',
      'setClickedDate'
    ]),
    ...mapActions('participants', [
      'fetchParticipantEvents',
      'fetchParticipantUsers',
    ]),
    ...mapActions('notifications', [
      'fetchUnreadNotificationsCount',
    ]),
    showNotificationDialog() {
      this.dialogKey++;
      this.dialog = true;
      console.log('dialog value:', this.dialog);
    },

    setToday() {
      this.value = format(new Date(), 'yyyy/MM/dd');
    },
    showEvent({ nativeEvent, event }) {
      this.setEvent(event);
      nativeEvent.stopPropagation();
    },
    closeDialog() {
      this.setEvent(null);
      this.setEditMode(false);
      this.setClickedDate(null);
    },

    initEvent({ date }) {
      if (this.clickedDate !== null || !date) {
        return;
      }
      date = date.replace(/-/g, '/');
      const [start, end] = getDefaultStartAndEnd(date);
      this.setEvent({ name: '', start, end, timed: true });
      this.setEditMode(true);
    },

    initNewEvent() {
      const [start, end] = getDefaultStartAndEnd(this.today);
      const newEvent = {
        name: '',
        start,
        end,
        timed: true,
        color: '#1976d2',
        description: '',
        calendarId: null,
        user: [],
      };
      this.setEvent(newEvent);
      this.setEditMode(true);
    },

    showDayEvents({ date }) {
      date = date.replace(/-/g, '/');
      this.setClickedDate(date);
    },
    // カレンダーの土日を指定する calendar.scssに色の記述
    changeColor: function() {
      setTimeout(() => {
        const dayList = Array.from(
          this.$refs.calendar.$vnode.elm.getElementsByClassName(
            'v-calendar-weekly__week'
          )
        );
        dayList.map(el => {
          el.children[0].classList.add('sunday');
          el.children[6].classList.add('saturday');
        });
      });
    },
  }
};
</script>

<style scoped lang="scss">
  @import "../../../assets/stylesheets/calendar.scss";
</style>