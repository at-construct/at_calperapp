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
          <v-toolbar-title style="font-size: 1.5em">{{ title }} </v-toolbar-title>
        </v-toolbar-title>

        <v-btn icon class="mr-auto" @click="$refs.calendar.next()">
          <v-icon>mdi-chevron-right</v-icon>
        </v-btn>

        <v-btn outlined x-small class="mr-auto" @click="setToday" style="font-size: 10px;">
          今日
        </v-btn>

        <v-btn icon class="mr-auto" @click="showNotificationDialog">
          <v-icon>mdi-bell-outline</v-icon>
        </v-btn>

      </v-toolbar>
    </v-sheet>

    <!-- 左側ドロワー -->
    <v-sheet height="80vh" class="d-flex">
      <v-navigation-drawer v-model="drawer" absolute left temporary>
        <v-list-item-group v-model="group">
          <v-list-item @click="type = 'day'">
            <v-icon>mdi-view-day-outline</v-icon>
            <v-list-item-title style="font-size: 14px;">　1日</v-list-item-title>
          </v-list-item>
          <v-list-item @click="type = 'week'">
            <v-icon>mdi-view-week-outline</v-icon>
            <v-list-item-title style="font-size: 14px;">　週</v-list-item-title>
          </v-list-item>
          <v-list-item @click="type = 'month'">
            <v-icon>mdi-grid</v-icon>
            <v-list-item-title style="font-size: 14px;">　月</v-list-item-title>
          </v-list-item>
        </v-list-item-group>
        <CalendarList />
      </v-navigation-drawer>

      <!-- ホームカレンダー -->
      <!-- :events="events.concat(participantEvents)" 削除した-->
      <v-sheet height="80vh" class="flex">
        <v-calendar
          ref="calendar"
          v-model="value"
          :events="events"
          :type="type"
          @change="handleChange"
          color="gray"
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

    <!-- 通知ダイアログ -->
    <v-dialog
      v-model="dialog"
      max-width="400"
    >
      <template v-slot:activator="{ on }">
        <v-btn
          icon
          v-on="on"
          @click="showNotificationDialog"
        >
        </v-btn>
      </template>
      <v-card>
        <v-card-text>
          <span>Aさんの予定に参加者として招待されました</span>
        </v-card-text>
      </v-card>
    </v-dialog>
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

export default {
  name: 'Calendar',
  components: {
    EventDetailDialog,
    EventFormDialog,
    DayEventList,
    CalendarList,
  },
  data: () => ({
    value: format(new Date(), 'yyyy/MM/dd'),
    today: format(new Date(), 'yyyy/MM/dd'),
    drawer: false,
    group: null,
    type: 'month',
    dialog: false,
  }),
  watch: {
    group() {
      this.drawer = false;
    }
  },
  computed: {
    ...mapGetters('events', ['events', 'event', 'isEditMode', 'clickedDate']),
    ...mapGetters('participants', ['participantEvents', 'participantUsers']),
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
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

    showNotificationDialog() {
      this.dialog = true;
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
        user_visibility: [],
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

<style>
.saturday {
  background: rgba(200, 200, 250, 0.2);
}
.sunday {
  background: rgba(250, 200, 200, 0.2);
}
</style>
