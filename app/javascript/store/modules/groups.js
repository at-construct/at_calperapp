import axios from 'axios';

const apiUrl = 'https://atcalperapp.herokuapp.com';

const state = {
  groups: [],
  selectedGroup: null,
};

const getters = {
  groups: state => state.groups,
  selectedGroup: (state) => state.selectedGroup,
};

const mutations = {
  SET_GROUPS(state, groups) {
    state.groups = groups
  },
  SET_SELECTED_GROUP(state, group) {
    state.selectedGroup = group;
  },
};

const actions = {
  setSelectedGroup({ commit }, group) {
    commit('SET_SELECTED_GROUP', group);
  },
  async fetchGroups({ commit }) {
      const response = await axios.get(`${apiUrl}/groups`);
      commit('SET_GROUPS', response.data);
  },
};

export default {
  namespaced: true,
  getters,
  state,
  mutations,
  actions,
};
