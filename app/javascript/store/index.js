import Vue from 'vue';
import Vuex from 'vuex';
import events from './modules/events';
import calendars from './modules/calendars';
import users from './modules/users';
import participants from './modules/participants';
import groups from './modules/groups';
import visibility from './modules/visibility';
import notifications from './modules/notifications';

Vue.use(Vuex);

export default new Vuex.Store({
  modules: {
    events,
    calendars,
    users,
    participants,
    groups,
    visibility,
    notifications,
  }
});
