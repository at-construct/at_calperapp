import axios from 'axios';
import { isDateWithinInterval, compareDates } from '../../functions/datetime';
import { serializeEvent } from '../../functions/serializers';

const apiUrl = '';

const state = {
  events: [],
  event: null,
  isEditMode: false,
  clickedDate: null,
  otherClickedDate: null,
  otherUserEvents: [],
  currentUser: null, 
  selectedUserId: null,
  duplicateEventError: null,
  allEvents: [],
  participantAllEvents: [],
};

const getters = {
  events: state =>
    state.events.filter(event => event).map(event => serializeEvent(event)),
  event: state => serializeEvent(state.event),
  dayEvents: state =>
    state.events
      .map(event => serializeEvent(event))
      .filter(event =>
        isDateWithinInterval(state.clickedDate, event.startDate, event.endDate)
      )
      .sort(compareDates),
  otherDayEvents: state => {
    console.log("State before calculation: ", state);  // デバッグ用: stateの全体像を出力
  
    const serializedEvents = state.otherUserEvents.map(event => {
      const serialized = serializeEvent(event);
      console.log("Serialized Event: ", serialized);  // デバッグ用: シリアライズされた各イベントを出力
      return serialized;
    });
  
    const filteredEvents = serializedEvents.filter(event => {
      const withinInterval = isDateWithinInterval(state.otherClickedDate, event.startDate, event.endDate);
      console.log("Event within interval: ", withinInterval);  // デバッグ用: 日付が範囲内かどうかを出力
      return withinInterval;
    });
  
    const sortedEvents = filteredEvents.sort(compareDates);
    console.log("Sorted and Filtered otherDayEvents: ", sortedEvents);  // デバッグ用: ソートとフィルタリングが完了したイベントを出力
  
    return sortedEvents;
  },
  isEditMode: state => state.isEditMode,
  clickedDate: state => state.clickedDate,
  otherClickedDate: state => state.otherClickedDate,
};

const mutations = {
  setAllevents: (state, events) => (state.events = events),
  setEvents: (state, events) => (state.events = events),
  appendEvent: (state, event) => (state.events = [...state.events, event]),
  setEvent: (state, event) => (state.event = event),
  removeEvent: (state, event) =>
    (state.events = state.events.filter(e => e.id !== event.id)),
  resetEvent: state => (state.event = null),
  updateEvent: (state, event) =>
    (state.events = state.events.map(e => (e.id === event.id ? event : e))),
  setEditMode: (state, bool) => (state.isEditMode = bool),
  setClickedDate: (state, date) => (state.clickedDate = date),
  otherSetClickedDate: (state, date) => (state.otherClickedDate = date),
  setDuplicateEventError(state, error) {
    state.duplicateEventError = error;
  },
  setCurrentUser: (state, user) => {
    state.currentUser = user;
  },
  setOtherUserEvents: (state, events) => {
    console.log("Setting Other User Events: ", events);  
    state.otherUserEvents = events
  },
  SET_OTHER_CLICKED_DATE(state, payload) {
    state.otherClickedDate = payload;
  },
  SET_FETCHED_ALL_EVENTS(state, payload) {
    state.allEvents = payload;
  },
  SET_FETCHED_PARTICIPANT_ALL_EVENTS(state, payload) {
    state.participantAllEvents = payload;
  },
  resetEvents: (state) => {
    state.events = [];
  },
};
const actions = {
  async fetchAllEvents({ commit }) {
    const response = await axios.get(`${apiUrl}/events/all`);
    commit('setEvents', response.data);
  },
  async fetchEvents({ commit }) {
    const response = await axios.get(`${apiUrl}/events/my_events_with_participants`);
    commit('setEvents', response.data.events);
    commit('setCurrentUser', response.data.current_user); 
  },
  async fetchUserSpecificEvents({ commit }, userId, date) {
    const response = await axios.get(`${apiUrl}/events/selected_user_events?group_user_id=${userId}&date=${date}`);
    commit('setOtherUserEvents', response.data.events);
  },
  async createEvent({ commit, dispatch }, event) {
    try {
      const response = await axios.post(`${apiUrl}/events`, event);
      commit('appendEvent', response.data);
    } catch (error) {
      if (error.response && error.response.status === 422) {
        // 重複エラーが発生した場合の処理
        const duplicateError = error.response.data.error;
        dispatch('handleDuplicateEventError', duplicateError);
      } else {
        // その他のエラーの処理
        console.error('Event creation failed:', error);
      }
    }
  },
  async deleteEvent({ commit, dispatch }, id) {
    try {
      const response = await axios.delete(`${apiUrl}/events/${id}`);
      commit('removeEvent', response.data);
      commit('resetEvent');
  
      // イベント削除後、未読通知のカウントを更新
      await dispatch('notifications/fetchUnreadNotificationsCount', null, { root: true });
    } catch (error) {
      console.error("Error deleting event:", error);
    }
  },
  async updateEvent({ commit, dispatch }, event) {
    try {
      const response = await axios.put(`${apiUrl}/events/${event.id}`, event);
      commit('updateEvent', response.data);
      console.log('Event updated:', response.data);
  
      // イベント更新後、未読通知のカウントを更新
      await dispatch('notifications/fetchUnreadNotificationsCount', null, { root: true });
    } catch (error) {
      console.error("Error updating event:", error);
    }
  },
  setEvent({ commit }, event) {
    commit('setEvent', event);
  },
  setEditMode({ commit }, bool) {
    commit('setEditMode', bool);
  },
  setClickedDate({ commit }, date) {
    commit('setClickedDate', date);
  },
  otherSetClickedDate({ commit }, date) {
    commit('otherSetClickedDate', date);
  },
  handleDuplicateEventError({ commit }, error) {
    // 重複エラーメッセージをセットするミューテーションをコミットします
    commit('setDuplicateEventError', error);
  },
  async resetOtherStates({ commit }) {
    console.log("resetOtherStates is called"); 
    commit('SET_OTHER_CLICKED_DATE', null); // 既存のリセット処理
    commit('SET_FETCHED_ALL_EVENTS', []); // 全てのイベントをリセット
    commit('SET_FETCHED_PARTICIPANT_ALL_EVENTS', []); // 全ての参加者イベントをリセット
    commit('resetEvents'); 
    // events データを空の配列に設定して表示された予定データをクリア
    commit('setEvents', []); // この行を追加または適切な mutations を呼び出す
    // その他のデータをクリアする処理も追加する（必要に応じて）
  },
};

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions
};
