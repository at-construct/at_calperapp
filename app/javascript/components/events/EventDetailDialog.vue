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
      <EventFormDialog v-if="event !== null && isEditMode" :initial-participants="selectedParticipants" />
    </v-card-actions>

    <!-- 予定削除確認ダイアログ -->
    <v-dialog v-model="showDeleteConfirmation" max-width="230">
      <v-card>
        <v-card-title class="headline">この予定を削除しますか？</v-card-title>
        <v-card-actions>
          <v-btn text color="red" @click="deleteEventConfirmed" class="btn-delete">削除</v-btn>
          <v-btn text color="primary" @click="showDeleteConfirmation = false" class="btn-cancel">キャンセル</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-card-title>
      <DialogSection icon="mdi-square" :color="event.color">
        <span class="large-text">{{ event.name }}</span>
      </DialogSection>
    </v-card-title>
    <br>
    <v-card-text>
      <DialogSection icon="mdi-clock-time-three-outline" class="event-date event-font-size-small">
        {{ event.startDate }}{{ event.timed ? ' ' + event.startTime : ''}} ~
        {{ event.endDate }} 
        {{ event.timed ? event.endTime : ' 終日' }}
      </DialogSection>
    </v-card-text>

    <v-card-text>
      <DialogSection icon="mdi-card-text-outline" class="event-description event-font-size-small">
        <div class="title-text">詳細</div>
      </DialogSection>
      <DialogSection class="event-description event-font-size-small margin-text">
        {{ event.description || 'なし' }}
      </DialogSection>
    </v-card-text>

    <v-card-text>
      <!-- v-forディレクティブを使ってparticipantUsersからユーザー名を表示 -->
      <DialogSection icon="mdi-account-group-outline" class="event-participants event-font-size-small">
        <div class="title-text">参加予定者</div>
      </DialogSection>
      <DialogSection class="event-participants event-font-size-small margin-text">
        {{ (participantUsers.length > 0 && getUniqueParticipants(event, participantUsers).map(user => user.name).join(', ')) || 'なし' }}
      </DialogSection>
    </v-card-text>

    <v-card-text>
      <!-- v-forディレクティブを使ってparticipantUsersから施設名を表示 -->
      <DialogSection icon="mdi-office-building-outline" class="event-facilities event-font-size-small">
        <div class="title-text">利用予定設備</div>
      </DialogSection>
      <DialogSection class="event-facilities event-font-size-small margin-text">
        {{ (participantUsers.length > 0 && getUniqueFacilities(event, participantUsers).map(user => user.name).join(', ')) || 'なし' }}
      </DialogSection>
    </v-card-text>

    <v-card-text>
      <DialogSection icon="mdi-head-outline" class="event-creator event-font-size-small">
        <div class="title-text">作成者</div>
      </DialogSection>
      <DialogSection class="event-creator event-font-size-small margin-text">
        {{ event.user_name || 'なし' }}
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
    ...mapGetters('participants', ['participantUsers','selectedParticipants', 'participantAllEvents']),
    ...mapGetters('users', ['users'])
  },
  created() {
    this.fetchParticipantUsers();
  },
  methods: {
    ...mapActions('events', ['setEvent', 'deleteEvent', 'setEditMode']),
    ...mapActions('participants', ['fetchParticipantUsers','setParticipantUsers', 'setEditModeParticipantUser', 'setSelectedParticipants']),
    ...mapActions('users', ['setUsers']),

  // getUniqueParticipantsメソッド
  getUniqueParticipants(event, participantUsers) {
    const uniqueParticipants = [];
    const facilities = ["A会議室", "Aスタジオ", "ハイエース"];
    participantUsers.forEach(participantEvent => {
      if (participantEvent.id === event.id) {
        participantEvent.participants.forEach(participant => {
          const { id, name } = participant; // idとnameを抽出
          if (!uniqueParticipants.some(p => p.id === id) && !facilities.includes(name)) {
            uniqueParticipants.push({ id, name }); // 抽出したidとnameを新しいオブジェクトに格納
          }
        });
      }
    });
    return uniqueParticipants;
  },
  // isFacilityメソッド：参加者が施設であるかを判定するメソッド
  isFacility(participant) {
    const facilities = ["A会議室", "Aスタジオ", "ハイエース"];
    return facilities.includes(participant.name);
  },
  
  // getUniqueFacilitiesメソッド
  getUniqueFacilities(event, participantUsers) {
    const uniqueFacilities = [];
    participantUsers.forEach(participantEvent => {
      if (participantEvent.id === event.id) {
        participantEvent.participants.forEach(participant => {
          const facilityNames = ["A会議室", "Aスタジオ", "ハイエース"];
          if (facilityNames.includes(participant.name) && !uniqueFacilities.some(f => f.name === participant.name)) {
            uniqueFacilities.push({ id: participant.id, name: participant.name });
          }
        });
      }
    });
    return uniqueFacilities;
  },

    closeDialog() {
      this.setEvent(null);
      this.setParticipantUsers([]);
      this.setEditMode(false);
      this.setEditModeParticipantUser(false);
      this.setSelectedParticipants([]); // 選択された参加者を空にする
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
      
      // 参加者と施設の両方を選択された参加者に設定
      const uniqueParticipants = this.getUniqueParticipants(this.event, this.participantUsers);
      const uniqueFacilities = this.getUniqueFacilities(this.event, this.participantUsers);
      this.setSelectedParticipants([...uniqueParticipants, ...uniqueFacilities]);
    },
  },
};
</script>

<style scoped>

.large-text {
  font-size: 18px;
  margin-bottom: 5px;
  color: black;
}

.title-text {
  font-size: 14px;
  margin-bottom: 5px;
  color: grey;
}

.event-font-size-small {
  font-size:14px;
  color: black;
}

.event-description {
  line-height: 1.6;
  white-space: pre-line;
  word-wrap: break-word;
  margin-bottom: 0; 
  margin-top: 0;
}

.margin-text {
  margin-top: -50px; /* 上のマージンをマイナス値に設定して詳細に近づける */
}

.event-participants {
  line-height: 1.6;  /* 行の高さを調整 */
  white-space: pre-line;  /* 改行を認識させる */
  word-wrap: break-word;  /* 単語がはみ出したら折り返す */
}

.event-creator {
  line-height: 1.6;
  white-space: pre-line;
  word-wrap: break-word; 
}
.event-facilities {
  line-height: 1.6;
  white-space: pre-line;
  word-wrap: break-word;
}

.btn-delete,
.btn-cancel {
  font-size: 14px;
}

</style>