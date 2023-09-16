<template>
  <v-dialog v-model="dialog" fullscreen>
    <v-card class="mx-auto" max-width="500">
      <v-toolbar color="white" flat>
        <v-spacer></v-spacer>
        <v-toolbar-title color="black" class="notification-title">お知らせ</v-toolbar-title>
        <v-spacer></v-spacer>
        <v-btn icon @click="closeDialog" class="close-button">
          <v-icon>mdi-close</v-icon>
        </v-btn>
      </v-toolbar>
      <v-divider></v-divider>
        <v-list-item-group
        v-model="selected"
        active-class="grey lighten-3"
        multiple
        >
        <template v-for="(event, index) in paginatedEvents">
              <v-list-item :value="event.notification_id" @click="markAsRead(event.notification_id)">
                <!-- v-html用の内部要素 -->
                <v-list-item-content>
                  <v-list-item-title class="event-title">
                    <span v-html="eventTitle(event)"></span>
                  </v-list-item-title>
                </v-list-item-content>
              </v-list-item>
            <v-divider v-if="index < eventsWithReadStatus.length - 1" class="custom-divider"></v-divider>
          </template>
        </v-list-item-group>
        <div>
          <v-pagination v-if="numberOfPagesComputed > 0" :length="numberOfPagesComputed" v-model="currentPage"></v-pagination>
        </div>
    </v-card>
  </v-dialog>
</template>

<script>
import { mapActions, mapState } from 'vuex';
import { format } from 'date-fns';

export default {
  name: 'NotificationDialog',
  data: () => ({
  dialog: true,
  selected: [], 
  currentPage: 1,  // 現在のページ
  itemsPerPage: 10,  // 1ページあたりのアイテム数
  }),
  computed: {
    ...mapState('notifications', ['eventsWithReadStatus', 'unreadNotifications', 'unreadCount']),
    reversedNotifications() {
      return [...this.eventsWithReadStatus].reverse();
    },
    paginatedEvents() {
      if (Array.isArray(this.reversedNotifications)) {
        const start = (this.currentPage - 1) * this.itemsPerPage;
        const end = this.currentPage * this.itemsPerPage;
        return this.reversedNotifications.slice(start, end);
      }
      return [];
    },
    numberOfPagesComputed() {
      return this.eventsWithReadStatus ? Math.ceil(this.eventsWithReadStatus.length / this.itemsPerPage) : 0;
    },
  },
  methods: {
    ...mapActions('notifications', ['fetchNotificationsWithParticipantsAndReadStatus', 'markNotificationAsRead']),
    async getNotifications() {
      try {
        await this.fetchNotificationsWithParticipantsAndReadStatus();
      } catch (error) {
        console.error('Error fetching notifications:', error);
      }
    },
    eventTitle(event) {
      const start = format(new Date(event.start), 'MM/dd HH:mm');
      const end = format(new Date(event.end), 'MM/dd HH:mm');
      return `${event.user_name}の予定【${event.name}】に参加者で追加されました <br> ${start} 〜 ${end}`;
    },
    closeDialog() {
      this.dialog = false;
      this.$emit('close');
    },
    markAsRead(eventId) {
    // 既読にするAPI呼び出し
      this.markNotificationAsRead(eventId)
      .then(() => {
        // selected配列に既読にした通知のIDを追加
        this.selected.push(eventId);
        
        // 未読通知のカウントを減らす（Vuexのミューテーションを呼び出す）
        this.$store.commit('DECREASE_UNREAD_COUNT');
      })
      .catch(error => {
        console.error('Error marking notification as read:', error);
      });
    },
  },
  async mounted() {
    await this.getNotifications();
    console.log("Number of Pages:", this.numberOfPagesComputed);
    this.selected = this.$store.state.notifications.readNotifications;
    this.selected = this.eventsWithReadStatus.filter(event => event.read_status === 'read').map(event => event.notification_id);
  }
};
</script>

<style scoped lang="scss">
  @import "../../../assets/stylesheets/notification.scss";
</style>