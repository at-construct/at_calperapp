<template>
  <v-list dense>
    <hr class="tight-up-hr">
    <!-- 設備以外のカレンダーリストを表示する -->
    <v-list-item-group :value="selectedItem">
      <v-list-group v-for="calendar in filteredCalendars" :key="calendar.id" class="mb-3">
        <template v-slot:activator>
          <v-list-item-title class="list-item-title d-flex justify-space-between align-center">
            <v-icon :color="calendar.color" class="icon" small>mdi-square</v-icon>
              <span class="calendar-name">{{ calendar.name }}</span>

                <v-btn icon class="align-self-end" @click="edit(calendar)">
                  <!-- カレンダーリストの編集機能 -->
                  <v-menu transition="scale-transition" offset-y min-width="100px">
                    <template v-slot:activator="{ on }">
                      <v-btn icon v-on="on">
                        <v-icon size="12px">mdi-pencil</v-icon>
                      </v-btn>
                    </template>
                    <v-list>
                      <v-list-item @click="edit(calendar)">編集</v-list-item>
                      <v-list-item @click="confirmDeletion(calendar)">削除</v-list-item>
                    </v-list>
                  </v-menu>
                </v-btn>

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

    <hr class="tight-under-hr">
    <!-- 設備カレンダーを表示する -->
    <v-list-group :value="false" v-for="calendar in facilityCalendar" :key="calendar.id">
      <template v-slot:activator>
        <v-list-item-title class="list-item-title d-flex justify-space-between align-center">
          <v-icon :color="calendar.color" class="icon" small>mdi-square</v-icon>
          <span class="calendar-name">{{ calendar.name }}</span>

            <v-btn icon class="align-self-end" @click="edit(calendar)">
              <!-- カレンダーリストの編集機能 -->
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
            </v-btn>

        </v-list-item-title>
          <v-dialog
            v-model="isDeleteDialogOpen"
            max-width="420"
          >
            <v-card>
              <v-card-title class="headline">このカレンダーを削除しますか？</v-card-title>
          
              <v-card-text class="text-h6">
                ※関連する予定も削除されます
              </v-card-text>
          
              <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn text color="red" @click="agreeToDelete" class="text-h6">削除</v-btn> <!-- ここを`agreeToDelete`に修正 -->
                <v-btn color="primary" text @click="cancelDeletion" class="text-h6">キャンセル</v-btn> <!-- ここを`cancelDeletion`に修正 -->
              </v-card-actions>
            </v-card>
          </v-dialog>
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
        <v-subheader class="font-size-small">カレンダー追加</v-subheader>
      </v-list-item-content>
      <v-list-item-action>
        <v-btn icon @click="initCalendar">
          <v-icon class="icon-size-small">mdi-plus</v-icon>
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
      <OtherCalendar
        v-if="isCalendarDialogOpen"
        :group="selectedGroup"
        @close="handleOtherCalendarClose"
      />
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
      selectedGroup: null,
      isCalendarDialogOpen: false,
      value: format(new Date(), 'yyyy/MM/dd'),
      isDeleteDialogOpen: false,
      calendarToDelete: null,  // 削除するカレンダーの情報を一時保存する
    }
  },
  computed: {
    ...mapGetters('calendars', ['calendars', 'calendar']),
    ...mapGetters('groups', ['groups']),
    filteredCalendars() {
      return this.calendars.filter(calendar => calendar.name !== '会議室' && calendar.name !== '社用車' && calendar.name !== 'スタジオ');
    },
    facilityCalendar() {
      return this.calendars.filter(calendar => calendar.name === '会議室' || calendar.name === '社用車' || calendar.name === 'スタジオ');
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
      'setSelectedGroup',
    ]),
    initCalendar() {
      this.setCalendar({
        name: '',
        visibility: true
      });
    },
    openCalendarDialog(group) {
      this.selectedCalendar = group.calendar;
      this.selectedGroup = group;
      this.setSelectedGroup(group); 
      this.isCalendarDialogOpen = true;
    },

    showDayEvents({ date }) {
      date = date.replace(/-/g, '/');
      this.setClickedDate(date);
    },

    closeDialog() {
      this.setCalendar(null);
    },
    handleOtherCalendarClose() {
      this.isCalendarDialogOpen = false;
    },
    edit(calendar) {
      this.setCalendar(calendar);
    },
    del(calendar) {
      this.deleteCalendar(calendar.id);
    },

    confirmDeletion(calendar) {
      this.calendarToDelete = calendar; // 削除するカレンダーを保存
      this.isDeleteDialogOpen = true; // ダイアログを表示
    },
  
    agreeToDelete() {
      this.deleteCalendar(this.calendarToDelete.id); // カレンダーを削除
      this.isDeleteDialogOpen = false; // ダイアログを閉じる
    },
  
    cancelDeletion() {
      this.calendarToDelete = null; // 保存したカレンダー情報をクリア
      this.isDeleteDialogOpen = false; // ダイアログを閉じる
    },

  }
};
</script>

<style scoped lang="scss">
  @import "../../../assets/stylesheets/calendar_list.scss";
</style>