<template>
  <v-card class="pb-12">
    <v-card-actions class="d-flex justify-end pa-2">
      <v-btn icon @click="closeDialog">
        <v-icon size="20px">mdi-close</v-icon>
      </v-btn>
    </v-card-actions>

    <v-card-text>
      <DialogSection icon="mdi-square" :color="color">
        <v-text-field v-model="name" label="リスト名"></v-text-field>
      </DialogSection>
      <DialogSection icon="mdi-palette">
        <ColorForm v-model="color" />
      </DialogSection>

      <!-- カレンダーメンバー追加機能途中 -->
      <!-- <DialogSection icon="mdi-account-group">
        <GroupCheckBox v-model="user" />
      </DialogSection> -->
    </v-card-text>
    <v-card-actions class="d-flex justify-end">
      <v-btn @click="close" style="font-size: 14px;">キャンセル</v-btn>
      <v-btn @click="submit" :disabled="$v.$invalid" style="font-size: 14px;">保存</v-btn>
    </v-card-actions>
  </v-card>
</template>

<script>
import { mapActions, mapGetters } from 'vuex';
import { validationMixin } from 'vuelidate';
import { required } from 'vuelidate/lib/validators';
import DialogSection from '../layouts/DialogSection';
import ColorForm from '../forms/ColorForm';

export default {
  name: 'CalendarFormDialog',
  mixins: [validationMixin],
  components: { DialogSection, ColorForm },
  data: () => ({
    name: '',
    color: null
  }),
  validations: {
    name: { required }
  },
  computed: {
    ...mapGetters('calendars', ['calendar'])
  },
  created() {
    this.name = this.calendar.name;
    this.color = this.calendar.color;
  },
  methods: {
    ...mapActions('calendars', [
      'createCalendar',
      'updateCalendar',
      'setCalendar'
    ]),
    closeDialog() {
      this.setCalendar(null);
    },
    close() {
      this.setCalendar(null);
    },
    submit() {
      if (this.$v.$invalid) {
        return;
      }
      const params = {
        ...this.calendar,
        ...this.user,
        name: this.name,
        color: this.color
      };
      if (params.id) {
        this.updateCalendar(params);
      } else {
        this.createCalendar(params);
      }
      this.close();
    }
  }
};
</script>
