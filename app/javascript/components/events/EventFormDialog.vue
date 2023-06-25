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
          v-model="selectedParticipants"
          @duplicate="handleDuplicateParticipant"
        />
      </DialogSection>

      <DialogSection icon="mdi-office-building-outline">
        <FacillitiesForm v-model="selectedFacilities" />
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
          <span class="headline">予定の重複</span>
        </v-card-title>
        <v-card-text>
          <p>{{ duplicateParticipantName }}は予定が重複します。登録しますか？</p>
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
    showAlert: false,
    duplicateParticipantName: '',
    selectedParticipants: [], 
    selectedFacilities: [], 
  }),
  validations: {
    name: { required },
    startDate: { required },
    endDate: { required },
  },
  computed: {
    ...mapGetters('events', ['event']),
    ...mapGetters('participants', ['participantUsers']),
    ...mapGetters('users', ['users']),
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
    facilities: {
      get() {
        return this.selectedFacilities;
      },
      set(value) {
        this.selectedFacilities = value;
      },
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
      this.selectedParticipants = this.event.participant || [];
    }
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
    ]),
    closeDialog() {
      this.setEvent(null);
      this.setEditMode(false);
      this.setParticipantUsers([]); // 参加者を空にする
      this.setEditModeParticipantUser(false); // isEditModeParticipantUserをfalseに設定する
      this.setSelectedParticipants([]); // 選択された参加者を空にする
    },
    submit() {
      if (this.isInvalid) {
        this.showAlert = true; // バリデーションエラー時にアラートを表示する
        return;
      }

      const duplicateParticipants = this.checkDuplicateParticipants();
      if (duplicateParticipants.length > 0) {
        this.handleDuplicateParticipant(duplicateParticipants[0]); // 重複する参加者が存在する場合、その名前をhandleDuplicateParticipantに渡す
        return;
      }

      this.saveEvent();
    },
    cancel() {
      this.setEditMode(false);
      this.setEditModeParticipantUser(false); // isEditModeParticipantUserをfalseに設定する
      if (!this.event.id) {
        this.setEvent(null);
        this.setParticipantUsers([]); // 参加者を空にする
      }
    },
    handleDuplicateParticipant(participantName) {
      this.duplicateParticipantName = participantName;
      this.showAlert = true; // 重複イベントアラートを表示する
    },
    confirmDuplicateEvent() {
      // 重複している場合の処理を記述する（登録するなど）
      // console.log('登録しました');
      this.showAlert = false; // アラートを非表示にする
      this.saveEvent();
    },
    cancelDuplicateEvent() {
      // 重複している場合の処理を記述する（キャンセルするなど）
      // console.log('キャンセルしました');
      this.showAlert = false; // アラートを非表示にする
    },
    checkDuplicateParticipants() {
      const participantNames = this.selectedParticipants.map((participant) => participant.name);
      const uniqueNames = new Set(participantNames);
      const duplicateNames = participantNames.filter((name) => participantNames.indexOf(name) !== participantNames.lastIndexOf(name));
      return Array.from(new Set(duplicateNames));
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
            this.closeDialog();
          })
          .catch((error) => {
            console.error(error);
          });
      } else {
        this.createEvent(eventParams)
          .then(() => {
            this.closeDialog();
          })
          .catch((error) => {
            console.error(error);
          });
      }
    },
  },
};
</script>
