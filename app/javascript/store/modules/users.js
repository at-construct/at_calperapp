import axios from 'axios';
import { serializeUser } from '../../functions/serializers';

const apiUrl = 'https://localhost:9292';

const state = {
  users: [],
};

const getters = {
  users: state => state.users.filter(user => serializeUser(user)),
  user: state => serializeUser(state.user)
};

const mutations = {
  setUsers: (state, users) => (state.users = users),
  appendUser: (state, user) => (state.users = [...state.users, user]),
  updateUser: (state, user) =>
    (state.users = state.users.map(c => (c.id === user.id ? user : c))),
  removeUser: (state, user) =>
    (state.users = state.users.filter(c => c.id !== user.id)),
  setUser: (state, user) => (state.user = user)
};

const actions = {
  async fetchUsers({ commit }) {
    const response = await axios.get(`${apiUrl}/users/excerpt`);
    commit('setUsers', response.data);
  },
  async addUser({ commit }, user) {
    console.log('addUser', user);
    const response = await axios.post(`${apiUrl}/users/excerpt`, user);
    commit('appendUser', response.data);
  },
  async updateUser({ dispatch, commit }, user) {
    const response = await axios.put(`${apiUrl}/users/excerpt/${user.id}`, user);
    commit('updateUser', response.data);
    dispatch('users/fetchUsers', null, { root: true });
  },
  async deleteUser({ dispatch, commit }, id) {
    const response = await axios.delete(`${apiUrl}/users/excerpt/${id}`);
    commit('removeUser', response.data);
    dispatch('users/fetchUsers', null, { root: true });
  },
  setUser({ commit }, user) {
    commit('setUser', user);
  }
};

export default {
  namespaced: true,
  state,
  getters,
  mutations,
  actions,
};
