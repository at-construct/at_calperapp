import axios from 'axios';

const apiUrl = 'https://atcalperapp.herokuapp.com';

const state = {
  unreadCount: 0,
  unreadNotifications: [],
  eventsWithReadStatus: [],
  readNotifications: [],
};

const getters = {
  hasUnreadNotifications: state => state.unreadCount > 0,
  getUnreadNotifications: state => state.unreadNotifications,
};

const mutations = {
  DECREASE_UNREAD_COUNT(state) {
    if (state.unreadCount > 0) {
      state.unreadCount--;
    }
  },
  SET_UNREAD_COUNT: (state, count) => {
    console.log("Setting unread count to:", count); // この行を追加 
    state.unreadCount = count;
  },
  SET_UNREAD_NOTIFICATIONS: (state, notifications) => {
    state.unreadNotifications = notifications;
  },
  SET_EVENTS_WITH_READ_STATUS: (state, events) => {
    state.eventsWithReadStatus = events;
  },
  // 既読にした通知のIDを追加する
  ADD_TO_READ(state, notificationId) {
    const index = state.unreadNotifications.findIndex(n => n.id === notificationId);
    if (index > -1) {
      state.unreadNotifications.splice(index, 1);
    }
  },
  // 未読通知のカウントを減らす（オプション）
  DECREMENT_UNREAD_COUNT(state) {
    if (state.unreadCount > 0) {
      state.unreadCount--;
    }
  },
  SET_READ_NOTIFICATIONS: (state, notificationIds) => {
    state.readNotifications = notificationIds;
  },
  REMOVE_FROM_READ: (state, notificationId) => {
    const index = state.readNotifications.indexOf(notificationId);
    if (index > -1) {
      state.readNotifications.splice(index, 1);
    }
  },
  SET_READ_NOTIFICATIONS: (state, ids) => {
    state.readNotifications = ids;
  },
};

const actions = {
  async fetchUnreadNotificationsCount({ commit }) {
    try {
      const response = await axios.get(`${apiUrl}/notifications/unread_count`);
      commit('SET_UNREAD_COUNT', response.data.count); 
    } catch (error) {
      console.error("Error fetching unread notifications count:", error);
    }
  },

  async fetchNotificationsWithParticipantsAndReadStatus({ commit }) {
    try {
      const response = await axios.get(`${apiUrl}/notifications/index_with_participants_and_read_status`);
      commit('SET_EVENTS_WITH_READ_STATUS', response.data);
    } catch (error) {
      console.error('An error occurred:', error);
    }
  },

  async fetchReadNotifications({ commit }) {
    try {
      const response = await axios.get(`${apiUrl}/notifications/read`);
      commit('SET_READ_NOTIFICATIONS', response.data.ids);
      return response.data;
    } catch (error) {
      console.error('An error occurred while fetching read notifications:', error);
      throw error;
    }
  },

  async markNotificationAsRead({ commit }, notificationId) {
    console.log("markNotificationAsRead action called with ID:", notificationId);
    try {
      const response = await axios.put(`${apiUrl}/notifications/mark_as_read`, { id: notificationId });
      if (response.data.success) {
        // 更新成功時の処理
        commit('ADD_TO_READ', notificationId);  // 既読にした通知のIDを追加
        commit('DECREMENT_UNREAD_COUNT');  // カウントを減らす（オプション）
      } else {
        console.error('Failed to mark the notification as read:', response.data.error);
      }
      return response.data;
    } catch (error) {
      console.error('An error occurred:', error);
    }
  },

  async fetchUnreadNotifications({ commit }) {
    try {
      const response = await axios.get(`${apiUrl}/notifications/unread`);
      commit('SET_UNREAD_NOTIFICATIONS', response.data);
      return response.data;
    } catch (error) {
      console.error('An error occurred while fetching unread notifications:', error);
      throw error;
    }
  },

  markAsRead({ commit, dispatch }, notificationId) {
    commit('ADD_TO_READ', notificationId);
    dispatch('updateReadStatusOnServer', notificationId);
  },
  markAsUnread({ commit, dispatch }, notificationId) {
    commit('REMOVE_FROM_READ', notificationId);
    dispatch('updateReadStatusOnServer', notificationId);
  },
  async updateReadStatusOnServer({ state }, notificationId) {
    try {
      // サーバーに既読状態を更新するAPIリクエストを発行
      await axios.put(`${apiUrl}/notifications/${notificationId}/read_status`, {
        isRead: state.readNotifications.includes(notificationId),
      });
    } catch (error) {
      console.error('An error occurred while updating read status:', error);
    }
  },
};

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions,
};
