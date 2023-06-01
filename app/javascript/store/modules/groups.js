import axios from 'axios';

const apiUrl = 'https://localhost:9292';

const state = {
  groups: [],
};

const getters = {
  groups: state => state.groups
};

const mutations = {
  setGroups(state, groups) {
    state.groups = groups
  }
};

const actions = {
  async fetchGroups({ commit }) {
      const response = await axios.get(`${apiUrl}/groups`);
      commit('setGroups', response.data);
  },
};

export default {
  namespaced: true,
  getters,
  state,
  mutations,
  actions,
};
