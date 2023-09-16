<template>
  <v-card class="pb-8">
    <v-card-actions class="d-flex justify-end pa-2">
      <v-btn icon @click="closeDialog">
        <v-icon size="20px">mdi-close</v-icon>
      </v-btn>
    </v-card-actions>

    <v-card-text>
      <DialogSection icon="mdi-square" :color="color" style="margin-bottom: -20px;">
        <v-container fluid>
          <v-row align="center">
            <v-col cols="12" md="6">
              <v-text-field v-model="name" label="タイトル"></v-text-field>
            </v-col>
          </v-row>
        </v-container>
      </DialogSection>

      <DialogSection icon="mdi-palette" style="margin-top: -20px;">
        <ColorForm v-model="color" />
      </DialogSection>

      <DialogSection icon="mdi-clock-outline">
        <AlldayCheck v-model="allDay" label="終日" />
      </DialogSection>

      <div style="margin-top: -30px; margin-bottom: -30px;">
        <!-- 余白を追加する -->
      </div>

      <DialogSection>
        <DateForm v-model="startDate" />
        <div v-show="!allDay">
          <TimeForm v-model="startTime" />
        </div>
      </DialogSection>

      <DialogSection>
        <DateForm v-model="endDate" :isError="isInvalidDatetime" />
        <div v-show="!allDay">
          <TimeForm v-model="endTime" :isError="isInvalidDatetime" />
        </div>
      </DialogSection>

      <DialogSection icon="mdi-card-text-outline">
        <TextForm v-model="description" />
      </DialogSection>

      <DialogSection icon="mdi-account-group">
        <GuestSelectForm
          v-model="guestSelectFormData"
          @duplicate="handleDuplicateParticipant"
        />
      </DialogSection>

      <DialogSection icon="mdi-office-building-outline">
        <FacillitiesForm v-model="facilitiesFormData" />
      </DialogSection>

    </v-card-text>

    <v-card-actions class="d-flex justify-end">
      <v-btn @click="cancel" style="font-size: 14px;">キャンセル</v-btn>
      <v-btn :disabled="isInvalid" @click="submit" style="font-size: 14px;">保存</v-btn>
    </v-card-actions>

    <!-- アラートダイアログ -->
    <v-dialog v-model="showAlert" max-width="500px">
      <v-card>
        <v-card-title class="red--text">
          <span class="headline">予定重複</span>
        </v-card-title>
        <v-card-text>
          <div v-if="duplicateOrganizerNames.length > 0">
            <p>{{ `作成者の${duplicateOrganizerNames.join(', ')} は、他の予定と重複します。登録しますか？` }}</p>
          </div>
          <div v-if="duplicateParticipantNames.length > 0">
            <p>{{ `参加者の${duplicateParticipantNames.join(', ')} は、他の予定と重複します。登録しますか？` }}</p>
          </div>
          <div v-if="errorMessage" class="red--text">{{ errorMessage }}</div>
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn color="primary" text @click="confirmDuplicateEvent">はい</v-btn>
          <v-btn color="primary" text @click="cancelDuplicateEvent">いいえ</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

  </v-card>
</template>

<script>
import { mapGetters, mapActions } from 'vuex';
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';
import DialogSection from '../layouts/DialogSection';
import DateForm from '../forms/DateForm';
import TimeForm from '../forms/TimeForm';
import TextForm from '../forms/TextForm';
import ColorForm from '../forms/ColorForm';
import AlldayCheck from '../forms/AlldayCheck';
import GuestSelectForm from '../forms/GuestSelectForm';
import FacillitiesForm from '../forms/FacillitiesForm';
import { isGreaterEndThanStart } from '../../functions/datetime';

export default {
  name: 'EventFormDialog',
  mixins: [validationMixin],
  components: {
    DialogSection,
    DateForm,
    TimeForm,
    TextForm,
    ColorForm,
    AlldayCheck,
    GuestSelectForm,
    FacillitiesForm,
  },
  data: () => ({
    name: '',
    startDate: new Date(),
    startTime: null,
    endDate: new Date(),
    endTime: null,
    description: '',
    color: '',
    allDay: false,
    duplicateParticipantName: '',
    guestSelectFormData: [],
    facilitiesFormData: [],
    errorMessage: '',
    showAlert: false,
    duplicateType: '',
    duplicateOrganizerNames: [],
    duplicateParticipantNames: [],
  }),
  watch: {
    guestSelectFormData(newVal) {
      this.guestSelectFormData = newVal;
    },
    facilitiesFormData(newVal) {
      this.facilitiesFormData = newVal;
    },
  },
  validations: {
    name: { required },
    startDate: { required },
    endDate: { required },
  },
  computed: {
    ...mapGetters('events', ['event', 'events']),
    ...mapGetters('participants', ['participantsList', 'participantUsers']),
    ...mapGetters('users', ['users']),
    currentUser() {
      return this.$store.state.events.currentUser;
    },
    isInvalidDatetime() {
      return !isGreaterEndThanStart(
        this.startDate,
        this.startTime,
        this.endDate,
        this.endTime,
        this.allDay
      );
    },
    isInvalid() {
      return this.$v.$invalid || this.isInvalidDatetime;
    },
    selectedParticipants() {
      return [...this.guestSelectFormData, ...this.facilitiesFormData];
    },
  },
  created() {
    if (this.event && Object.keys(this.event).length > 0) { 
      this.name = this.event.name || '';
      this.startDate = this.event.startDate || '';
      this.startTime = this.event.startTime || '';
      this.endDate = this.event.endDate || '';
      this.endTime = this.event.endTime || '';
      this.description = this.event.description || '';
      this.color = this.event.color || '';
      this.allDay = this.event.timed ? false : true;
      this.fetchUsers();
      const participants = this.event.participant || [];
      this.guestSelectFormData = participants.filter(participant => participant.type === 'guest');
      this.facilitiesFormData = participants.filter(participant => participant.type === 'facility');
    }
    this.fetchParticipantsList();
  },

  methods: {
    ...mapActions('events', [
      'setEvent',
      'setEditMode',
      'createEvent',
      'updateEvent',
    ]),
    ...mapActions('users', [
      'setUsers',
      'createUser',
      'fetchUsers',
    ]),
    ...mapActions('participants', [
      'setParticipantUsers',
      'setEditModeParticipantUser',
      'setSelectedParticipants',
      'fetchParticipantUsers',
      'fetchParticipantsList'
    ]),
    closeDialog() {
      this.setEvent(null);
      this.setEditMode(false);
      this.setParticipantUsers([]); // 参加者を空にする
      this.setEditModeParticipantUser(false); // isEditModeParticipantUserをfalseに設定する
      this.setSelectedParticipants([]); // 選択された参加者を空にする
    },

    submit() {
      // 編集モードでない場合は重複チェックを実行
      const eventId = this.event ? this.event.id : null;
      if (!eventId) {
        let start = new Date(`${this.startDate} ${this.startTime}`);
        let end = new Date(`${this.endDate} ${this.endTime}`);
    
        if (this.isOverlapping(start, end)) {
          // 重複している場合はエラーメッセージを表示する
          this.showAlert = true;
          return;
        }
      }

      if (this.isInvalid) {
        this.showAlert = true; // バリデーションエラー時にアラートを表示する
        return;
      }

      // GuestSelectFormコンポーネントに変更を反映する
      this.guestSelectFormData = [...this.guestSelectFormData];
      this.facilitiesFormData = [...this.facilitiesFormData];

      const eventParams = {
        id: this.event.id || null,
        name: this.name,
        start: `${this.startDate || ''} ${this.startTime || ''}`,
        end: `${this.endDate || ''} ${this.endTime || ''}`,
        description: this.description,
        color: this.color,
        timed: !this.allDay,
        participant: this.selectedParticipants,
        user: this.selectedParticipants,
      };

      console.log("Sending the following params to backend:", JSON.parse(JSON.stringify(eventParams)));

      if (this.event && this.event.id) {
        this.updateEvent(eventParams)
          .then(() => {
            this.closeDialog();
          })
          .catch((error) => {
            this.handleErrorResponse(error);
          });
      } else {
        this.createEvent(eventParams)
          .then(() => {
            this.closeDialog();
          })
          .catch((error) => {
            if (error.response && error.response.status === 422) {
              const errorMessage = error.response.data.error || 'イベントの重複エラーが発生しました。';
              this.errorMessage = errorMessage; // エラーメッセージをセット
            }
          });
      }
    },
    cancel() {
      this.setEditMode(false);
      this.setEditModeParticipantUser(false); // isEditModeParticipantUserをfalseに設定する
      if (!this.event.id) {
        this.setEvent(null);
        this.guestSelectFormData = []; // guestSelect FormDataを空に初期化
        this.facilitiesFormData = []; // facilities FormDataを空に初期化
        this.setParticipantUsers([]); // 参加者を空にする
      }
    },
    handleDuplicateParticipant(participantName) {
      this.duplicateParticipantName = participantName;
      this.showAlert = true; // 重複イベントアラートを表示する
    },
    confirmDuplicateEvent() {
      // 重複している場合の処理を記述する（登録するなど）
      this.showAlert = false; // アラートを非表示にする
      this.saveEvent();
      this.closeDialog(); // 保存後にダイアログを閉じる
      this.duplicateOrganizerNames = []; // 重複ユーザーリストをクリア
    },
    cancelDuplicateEvent() {
      // 重複している場合の処理を記述する（キャンセルするなど）
      this.showAlert = false; // アラートを非表示にする
      // this.closeDialog(); // キャンセル後にダイアログを閉じる
      this.duplicateOrganizerNames = []; // 重複ユーザーリストをクリア
      console.log('重複しています。キャンセルしました。');
    },
    saveEvent() {
      const eventParams = {
        id: this.event.id || null,
        name: this.name,
        start: `${this.startDate || ''} ${this.startTime || ''}`,
        end: `${this.endDate || ''} ${this.endTime || ''}`,
        description: this.description,
        color: this.color,
        timed: !this.allDay,
        participant: this.selectedParticipants,
        user: this.selectedParticipants,
      };

      if (this.event && this.event.id) {
        this.updateEvent(eventParams)
          .then(() => {
          })
          .catch((error) => {
            console.error(error);
          });
      } else {
        this.createEvent(eventParams)
          .then(() => {
          })
          .catch((error) => {
            console.error(error);
          });
      }
    },
    handleErrorResponse(error) {
      if (error.response && error.response.status === 409) {
        const { message, participantName } = error.response.data;
        this.duplicateParticipantName = participantName;
        this.showAlert = true;
      }
    },

isOverlapping(start, end) {
  console.log("Participants List:", this.participantsList);
  console.log("Selected Participants:", this.selectedParticipants);
  let isOverlapFound = false;

  this.duplicateOrganizerNames = [];
  this.duplicateParticipantNames = [];
  this.duplicateType = [];

  for (let event of this.events) {
    if ((start >= event.start && start < event.end) ||
        (end > event.start && end <= event.end) ||
        (start <= event.start && end >= event.end)) {

      isOverlapFound = true;
      
      // 登録者の重複チェック
      if (event.user_id === this.currentUser.id && !this.duplicateType.includes('user')) {
        this.duplicateType.push('user');
        this.duplicateOrganizerNames.push(this.currentUser.name);
      } else {
        const overlappingParticipant = this.selectedParticipants.find(p => p.id === event.user_id);

        if (overlappingParticipant) {
          if (!this.duplicateType.includes('participant')) {
            this.duplicateType.push('participant');
          }
          if (!this.duplicateParticipantNames.includes(overlappingParticipant.name)) {
            this.duplicateParticipantNames.push(overlappingParticipant.name);
          }
        }
      }

      // 参加者の重複チェック: participantsListを使用
      if (this.participantsList && Array.isArray(this.participantsList)) {
        for (let existingParticipant of this.participantsList) {
        console.log("Inspecting existing participant:", existingParticipant);  // ログ追加
      
          if (this.selectedParticipants.includes(existingParticipant.user_id)) {
            console.log("Duplicate participant found:", existingParticipant);
      
            if (!this.duplicateType.includes('participant')) {
              this.duplicateType.push('participant');
            }
      
            if (!this.duplicateParticipantNames.includes(existingParticipant.user_name)) { // user_nameが存在すると仮定
              console.log("Adding to duplicate names:", existingParticipant.user_name); 
              this.duplicateParticipantNames.push(existingParticipant.user_name);
            }
          }
        }
      }

    }
  }

  return isOverlapFound;
}

  },
};
</script>

<style scoped lang="scss">
  @import "../../../assets/stylesheets/event_form_dialog.scss";
</style>