<template>
  <v-card class="pb-12">
    <v-card-actions class="d-flex pa-2">
      <v-btn icon @click="del">
        <v-icon size="20px">mdi-trash-can-outline</v-icon>
      </v-btn>
      <v-spacer></v-spacer>
      <v-btn icon @click="edit">
        <v-icon size="20px">mdi-pencil-outline</v-icon>
      </v-btn>
      <v-btn icon @click="closeDialog">
        <v-icon size="20px">mdi-close</v-icon>
      </v-btn>
      <EventFormDialog v-if="event !== null && isEditMode && isEditModeParticipantUser" :initialParticipants="selectedParticipants" />
    </v-card-actions>

    <!-- 予定削除確認ダイアログ -->
    <v-dialog v-model="showDeleteConfirmation" max-width="230">
      <v-card>
        <v-card-title class="headline">この予定を削除しますか？</v-card-title>
        <v-card-actions>
          <v-btn text color="red" @click="deleteEventConfirmed" style="font-size: 14px;">削除</v-btn>
          <v-btn text @click="showDeleteConfirmation = false" style="font-size: 14px;">キャンセル</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-card-title>
      <DialogSection icon="mdi-square" :color="event.color" class="event-name" style="font-size: 18px;">
        {{ event.name }}
      </DialogSection>
    </v-card-title>
    <v-card-text>
      <DialogSection icon="mdi-clock-time-three-outline" class="event-date" style="font-size: 14px;">
        {{ event.startDate }}{{ event.timed ? ' ' + event.startTime : ''}} ~
        {{ event.endDate }} 
        {{ event.timed ? event.endTime : ' 終日' }}
      </DialogSection>
    </v-card-text>
    <v-card-text>
      <DialogSection icon="mdi-card-text-outline" class="event-description" style="font-size: 14px;">
        {{ event.description || '予定の説明なし' }}
      </DialogSection>
    </v-card-text>
    <v-card-text>
      <DialogSection icon="mdi-account-group-outline" style="font-size: 14px;">
        参加予定者<br>{{ (participantUsers.length > 0 && getUniqueParticipants(event, participantUsers).join(', ')) || 'なし' }}
      </DialogSection>
    </v-card-text>
    <v-card-text>
      <DialogSection icon="mdi-office-building-outline" style="font-size: 14px;">
        利用予定設備<br>{{ (participantUsers.length > 0 && getUniqueFacilities(event, participantUsers).join(', ')) || 'なし' }}
      </DialogSection>
    </v-card-text>
    <v-card-text>
      <DialogSection icon="mdi-head-outline" style="font-size: 14px;">
        作成者<br>{{ event.user_name || 'なし' }}
      </DialogSection>
    </v-card-text>
  </v-card>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import DialogSection from '../layouts/DialogSection';
import EventFormDialog from '../events/EventFormDialog';

export default {
  name: 'EventDetailDialog',
  components: {
    DialogSection,
    EventFormDialog
  },
  data() {
    return {
      showDeleteConfirmation: false,
      participant: [],
    };
  },
  computed: {
    ...mapGetters('events', ['event', 'isEditMode']),
    ...mapGetters('participants', ['participantUsers','selectedParticipants']),
    ...mapGetters('users', ['users'])
  },
  created() {
    this.fetchParticipantUsers();
  },
  methods: {
    ...mapActions('events', ['setEvent', 'deleteEvent', 'setEditMode']),
    ...mapActions('participants', ['fetchParticipantUsers','setParticipantUsers', 'setEditModeParticipantUser', 'setSelectedParticipants']),
    ...mapActions('users', ['setUsers']),
    getUniqueParticipants(event, participantUsers) {
      const uniqueParticipants = [];
      participantUsers.forEach(participantEvent => {
        if (participantEvent.id === event.id) {
          participantEvent.participants.forEach(participant => {
            if (!uniqueParticipants.includes(participant) && participant !== "会議室A" && participant !== "ホールA" && participant !== "ハイエース") {
              uniqueParticipants.push(participant);
            }
          });
        }
      });
      return uniqueParticipants;
    },
    getUniqueFacilities(event, participantUsers) {
      const uniqueFacilities = [];
      participantUsers.forEach(participantEvent => {
        if (participantEvent.id === event.id) {
          participantEvent.participants.forEach(participant => {
            if (!uniqueFacilities.includes(participant) && (participant === "会議室A" || participant === "ホールA" || participant === "ハイエース")) {
              uniqueFacilities.push(participant);
            }
          });
        }
      });
      return uniqueFacilities;
    },
    closeDialog() {
      this.setEvent(null);
      this.setEditMode(false);
      this.setEditModeParticipantUser(false);
    },
    del() {
      this.showDeleteConfirmation = true; // 警告ダイアログを表示
    },
    deleteEventConfirmed() {
      this.deleteEvent(this.event.id); // 実際の削除処理
      this.showDeleteConfirmation = false; // 警告ダイアログを非表示
    },
    edit() {
      this.setEvent(this.event);
      this.setParticipantUsers(this.participantUsers);
      this.setEditMode(true);
      this.setEditModeParticipantUser(true);
      this.setSelectedParticipants(this.getUniqueParticipants(this.event, this.participantUsers));
    },
  },
};
</script>
