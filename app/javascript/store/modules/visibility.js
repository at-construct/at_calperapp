import axios from 'axios';

const apiUrl = 'https://atcalperapp.herokuapp.com';

const state = {
  visibilities: [],
};

const getters = {
  getVisibilityByUserId: (state) => (userId) => {
    return state.visibilities.find(visibility => visibility.user_id === userId);
  },
};

const mutations = {
  setVisibilities(state, visibilities) {
    state.visibilities = visibilities;
  },
  updateVisibility(state, updatedVisibility) {
    const index = state.visibilities.findIndex(visibility => visibility.user_id === updatedVisibility.user_id);
    if (index !== -1) {
      state.visibilities.splice(index, 1, updatedVisibility);
    }
  },
};

const actions = {
  async fetchVisibilities({ commit }) {
    try {
      const response = await axios.get('/api/visibilities');
      commit('setVisibilities', response.data);
    } catch (error) {
      console.error(error);
    }
  },
  async updateVisibility({ commit }, payload) {
    try {
      const { userId, targetUserId, visibility } = payload;
      const response = await axios.patch(`/api/visibilities/${userId}`, {
        target_user_id: targetUserId,
        visibility: visibility,
      });
      commit('updateVisibility', response.data);
    } catch (error) {
      console.error(error);
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
