import axios from 'axios';

const apiUrl = 'https://localhost:9292';

const state = {
  participantEvents: [],
  participantAllEvents: [],
  participantUsers: [],
  isEditModeParticipantUser: false,
  editModeParticipantUser: null,
  selectedParticipants: [],
};

const getters = {
  participantEvents: (state) =>
  state.participantEvents.map((participantEvent) => {
    return {
      ...participantEvent,
      start: new Date(participantEvent.start),
      end: new Date(participantEvent.end),
    };
  }),
  participantAllEvents: (state) => 
    state.participantAllEvents.map((participantAllEvent) => {
      return {
        ...participantAllEvent,
        start: new Date(participantAllEvent.start),
        end: new Date(participantAllEvent.end),
      };
    }),
  participantUsers: state => state.participantUsers,
  isEditModeParticipantUser: state => state.isEditModeParticipantUser,
  selectedParticipants: (state) => state.selectedParticipants,
};

const mutations = {
  setParticipantAllEvents: (state, participantAllEvents) =>
    (state.participantAllEvents = participantAllEvents),
  setParticipantEvents: (state, participantEvents) =>
    (state.participantEvents = participantEvents),
  appendParticipantEvent: (state, participantEvent) =>
    (state.participantEvents = [...state.participantEvents, participantEvent]),
  removeParticipantEvent: (state, participantEvent) =>
    (state.participantEvents = state.participantEvents.filter(
      (e) => e.id !== participantEvent.id
    )),
  updateParticipantEvent: (state, participantEvent) =>
    (state.participantEvents = state.participantEvents.map((p) =>
      p.id === participantEvent.id ? participantEvent : p
    )),

  setParticipantUsers(state, participantUsers) {
    state.participantUsers = participantUsers;
  },
  appendParticipantUser: (state, participantUser) =>
    (state.participantUsers = [...state.participantUsers, participantUser]),
  updateParticipantUser: (state, participantUser) =>
    (state.participantUsers = state.participantUsers.map((user) =>
      user.id === participantUser.id ? participantUser : user
    )),
  removeParticipantUser: (state, participantUser) =>
    (state.participantUsers = state.participantUsers.filter(
      (user) => user.id !== participantUser.id
    )),
  setEditModeParticipantUser: (state, bool) => (state.isEditModeParticipantUser = bool),
  setSelectedParticipants(state, participants) {
    state.selectedParticipants = participants;
  },
};

const actions = {
  async fetchParticipantAllEvents({ commit }) { 
    const response = await axios.get(`${apiUrl}/participants/all`);
    commit('setParticipantAllEvents', response.data);
  },
  async fetchParticipantEvents({ commit }) {
    const response = await axios.get(`${apiUrl}/participants/event_excerpt`);
    commit('setParticipantEvents', response.data);
  },
  async fetchParticipnatUserEvents({ commit }, userId) {
    console.log("User ID: ", userId); 
      const response = await axios.get(`${apiUrl}/participants/${userId}`);
      commit('setEvents', response.data);
  },
  async createParticipantEvent({ commit }, participantEvent) {
    console.log('createParticipantEvent', participantEvent);
    await axios.post(
      `${apiUrl}/participants/event_excerpt`,
      participantEvent
    );
    commit('appendParticipantEvent', participantEvent);
  },
  async deleteParticipantEvent({ commit }, participantEventId) {
    await axios.delete(
      `${apiUrl}/participants/event_excerpt/${participantEventId}`
    );
    commit('removeParticipantEvent', participantEventId);
  },
  async updateParticipantEvent({ commit }, participantEvent) {
    await axios.put(
      `${apiUrl}/participants/event_excerpt/${participantEvent.id}`,
      participantEvent
    );
    commit('updateParticipantEvent', participantEvent);
  },

  async fetchParticipantUsers({ commit }) {
    const response = await axios.get(`${apiUrl}/participants/events_with_participants`);
    commit('setParticipantUsers', response.data);
  },
  async createParticipantUser({ commit }, participantUser) {
    console.log('createParticipantUser', participantUser);
    const response = await axios.post(`${apiUrl}/participants/events_with_participants`, participantUser);
    commit('appendParticipantUser', response.data);
  },
  async updateParticipantUser({ dispatch, commit }, participantUser) {
    await axios.put(
      `${apiUrl}/participants/events_with_participants/${participantUser.id}`,
      participantUser
    );
    commit('updateParticipantUser', participantUser);
    dispatch('fetchParticipantUsers');
  },
  async deleteParticipantUser({ dispatch, commit }, participantUserId) {
    await axios.delete(`${apiUrl}/participants/events_with_participants/${participantUserId}`);
    commit('removeParticipantUser', participantUserId);
    dispatch('fetchParticipantUsers');
  },
  setParticipantUsers({ commit }, participantUsers) { // セッターを追加
    commit('setParticipantUsers', participantUsers);
  },
  setEditModeParticipantUser({ commit }, bool) {
    commit('setEditModeParticipantUser', bool);
  },
  setSelectedParticipants({ commit }, participants) {
    commit('setSelectedParticipants', participants);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions
};
