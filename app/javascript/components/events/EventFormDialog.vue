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

      <!-- カレンダーセレクトフォーム -->
      <!-- <DialogSection icon="mdi-calendar">
        <CalendarSelectForm :value="calendar" @input="changeCalendar($event)" />
      </DialogSection> -->

      <DialogSection icon="mdi-account-group">
          <GuestSelectForm v-model="user" />
      </DialogSection>

      <!-- 設備の選択機能 -->
      <DialogSection icon="mdi-office-building-outline">
        <FacillitiesForm v-model="user" />
      </DialogSection>

    </v-card-text>

    <v-card-actions class="d-flex justify-end">
      <v-btn @click="cancel" style="font-size: 14px;">キャンセル</v-btn>
      <v-btn :disabled="isInvalid" @click="submit" style="font-size: 14px;">保存</v-btn>
    </v-card-actions>
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
// import CalendarSelectForm from '../forms/CalendarSelectForm';
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
    // CalendarSelectForm,
    GuestSelectForm,
    FacillitiesForm,
  },
  data: () => ({
    name: '',
    startDate: new Date(), // set default value to current date
    startTime: null,
    endDate: new Date(), // set default value to current date
    endTime: null,
    description: '',
    color: '',
    allDay: false,
    // calendar: null,
    user: [], // 空の配列として初期化する
    facillities: [], // 空の配列として初期化する
  }),
  validations: {
    name: { required },
    startDate: { required },
    endDate: { required }
    // calendar: { required },
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
      return this.$v.$invalid || this.isInvaledDatetime;
    }
  },

  created() {
    if (this.event !== null && this.event !== undefined) {
      this.name = this.event.name || '';
      this.startDate = this.event.startDate || '';
      this.startTime = this.event.startTime || '';
      this.endDate = this.event.endDate || '';
      this.endTime = this.event.endTime || '';
      this.description = this.event.description || '';
      this.color = this.event.color || '';
      this.allDay = this.event.timed ? false : true;
      if (this.event.id && this.event.user) {
        const userIds = this.event.user.map(user => user.id);
        this.fetchUsers().then(() => {
          this.user = this.users.filter(user =>
            userIds.includes(user.id)
          );
        });
      } else {
        this.fetchUsers();
      }
    }
  },

  methods: {
    ...mapActions('events', [
      'setEvent',
      'setEditMode',
      'createEvent',
      'updateEvent'
    ]),
    ...mapActions('users', [
      'setUsers',
      'setEditModeUser',
      'createUser',
      'fetchUsers',
    ]),
    closeDialog() {
      this.setEvent(null);
      this.setEditMode(false);
    },

    submit() {
      if (this.isInvalid) {
        return;
      };
      const eventParams = {
        ...this.event,
        name: this.name,
        start: `${this.startDate || ''} ${this.startTime || ''}`,
        end: `${this.endDate || ''} ${this.endTime || ''}`,
        description: this.description,
        color: this.color,
        timed: !this.allDay,
        participant: this.user,
        user: this.user.name,
      };
      if (this.event.id) { 
        this.updateEvent(eventParams)
          .then(() => {
            this.closeDialog();
          })
          .catch((error) => {
            console.error(error);
          });
      }
      else {
        this.createEvent(eventParams)
          .then(() => {
            this.closeDialog();
          })
          .catch((error) => {
            console.error(error);
          });
      }
    },
    cancel() {
      this.setEditMode(false);
      if (!this.event.id) {
        this.setEvent(null);
      }
    },
    // changeCalendar(calendar) {
    //   this.color = calendar.color;
    //   this.calendar = calendar;
    // },
  }

};
</script>