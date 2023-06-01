<template>
  <v-list dense>
    <hr>
    <!-- 設備以外のカレンダーリストを表示する -->
    <v-list-item-group :value="selectedItem">
      <v-list-group v-for="calendar in filteredCalendars" :key="calendar.id" class="mb-3">
        <template v-slot:activator>
          <v-list-item-title style="overflow: visible;">
            <v-icon :color="calendar.color" class="mr-2" small>mdi-square</v-icon>
              <span style="font-size: 16px;">{{ calendar.name }}</span>
            <!-- <v-btn icon @click="edit(calendar)">
              <v-menu transition="scale-transition" offset-y min-width="100px">
                <template v-slot:activator="{ on }">
                  <v-btn icon v-on="on">
                    <v-icon size="12px">mdi-pencil</v-icon>
                  </v-btn>
                </template>
                <v-list>
                  <v-list-item @click="edit(calendar)">編集</v-list-item>
                  <v-list-item @click="del(calendar)">削除</v-list-item>
                </v-list>
              </v-menu>
            </v-btn> -->
          </v-list-item-title>
        </template>

        <v-list-item-group>
          <v-list-item v-for="group in groups.filter(group => group.calendar.id === calendar.id)" :key="group.id">
            <v-list-item-content class="py-0">
              <div class="d-flex align-center justify-space-between">
                <span :color="calendar.color" class="pb-2">
                  {{ group.user.name }}
                </span>
                <v-icon 
                  small 
                  @click="openCalendarDialog(group)" 
                >
                  mdi-calendar
                </v-icon>
              </div>
            </v-list-item-content>
          </v-list-item>
        </v-list-item-group>

      </v-list-group>
    </v-list-item-group>

    <hr>
    <!-- 設備カレンダーを表示する -->
    <v-list-group :value="false" v-for="calendar in facilityCalendar" :key="calendar.id">
      <template v-slot:activator>
        <v-list-item-title style="overflow: visible;">
          <v-icon :color="calendar.color" class="mr-2" small>mdi-square</v-icon>
          <span style="font-size: 16px;">{{ calendar.name }}</span>
          <!-- <v-btn icon @click="edit(calendar)">
            <v-menu transition="scale-transition" offset-y min-width="100px">
              <template v-slot:activator="{ on }">
                <v-btn icon v-on="on">
                  <v-icon size="12px">mdi-pencil</v-icon>
                </v-btn>
              </template>
              <v-list>
                <v-list-item @click="edit(calendar)">編集</v-list-item>
                <v-list-item @click="del(calendar)">削除</v-list-item>
              </v-list>
            </v-menu>
          </v-btn> -->
        </v-list-item-title>
      </template>

      <v-list-item-group>
        <v-list-item v-for="group in groups.filter(group => group.calendar.id === calendar.id)" :key="group.id">
          <v-list-item-content class="py-0">
            <div class="d-flex align-center justify-space-between">
              <span :color="calendar.color" class="pb-2">
                {{ group.user.name }}
              </span>
              <v-icon 
                small 
                @click="openCalendarDialog(group)" 
              >
                mdi-calendar
              </v-icon>
            </div>
          </v-list-item-content>
        </v-list-item>
      </v-list-item-group>
    </v-list-group>

    <!-- リストを追加処理 -->
    <v-list-item>
      <v-list-item-content>
        <v-subheader style="font-size: 14px;">リストを追加</v-subheader>
      </v-list-item-content>
      <v-list-item-action>
        <v-btn icon @click="initCalendar">
          <v-icon size="16px">mdi-plus</v-icon>
        </v-btn>
      </v-list-item-action>
    </v-list-item>

    <template>
      <v-dialog
        :value="calendar !== null"
        @click:outside="closeDialog"
        width="600"
      >
        <CalendarFormDialog v-if="calendar !== null" />
      </v-dialog>
    </template>

    <!-- OtherCalendarコンポーネントを呼び出す -->
    <v-dialog
      v-model="isCalendarDialogOpen"
      fullscreen
      hide-overlay
    >
      <OtherCalendar @close="isCalendarDialogOpen = false" />
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
  </v-list>
</template>


<script>
import { format } from 'date-fns';
import { mapActions, mapGetters } from 'vuex';
import CalendarFormDialog from '../calendars/CalendarFormDialog';
import OtherCalendar from '../calendars/OtherCalendar';
import DayEventList from '../events/DayEventList';


export default {
  name: 'CalendarList',
  components: {
    OtherCalendar,
    CalendarFormDialog,
    DayEventList
  },
  data() {
    return {
      selectedItem: [],
      selectedGroups: [],
      isCalendarDialogOpen: false,
      // events:[],
      value: format(new Date(), 'yyyy/MM/dd'),
    }
  },
  computed: {
    ...mapGetters('calendars', ['calendars', 'calendar']),
    ...mapGetters('groups', ['groups']),
    ...mapGetters('events', ['clickedDate']),
    filteredCalendars() {
      return this.calendars.filter(calendar => calendar.name !== '会議室' && calendar.name !== '社用車');
    },
    facilityCalendar() {
      return this.calendars.filter(calendar => calendar.name === '会議室' || calendar.name === '社用車');
    },
    title() {
      return format(new Date(this.value), 'yyyy年 M月');
    },
  },
  created() {
    this.fetchCalendars();
    this.fetchGroups();
  },
  methods: {
    ...mapActions('calendars', [
      'fetchCalendars',
      'deleteCalendar',
      'setCalendar'
    ]),
    ...mapActions('groups', [
      'fetchGroups',
    ]),
    initCalendar() {
      this.setCalendar({
        name: '',
        visibility: true
      });
    },
    openCalendarDialog(group) {
      this.selectedCalendar = group.calendar;
      this.isCalendarDialogOpen = true;
    },

    showDayEvents({ date }) {
      date = date.replace(/-/g, '/');
      this.setClickedDate(date);
    },

    closeDialog() {
      this.setCalendar(null);
    },
  }
};
</script>

