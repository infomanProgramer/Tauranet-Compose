import Vue from "vue";
import Vuex from "vuex";
const axios = require("axios");

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    token: localStorage.getItem("access_token") || null,
    //url_root: "http://192.168.1.6/tauranet/public/",
    url_root: process.env.VUE_APP_API_URL || "http://localhost:8080/",
    type_user: localStorage.getItem("type_user") || null,
    id_restaurant: localStorage.getItem("idRestaurante") || null,
    sexo: localStorage.getItem("sex") || null,
    restauranteData: {},
    indicePedidosActive: 0,
    fotoPerfil: localStorage.getItem("fotoPerfil") || null
  },
  getters: {
    loggedIn(state) {
      return state.token != null;
    }
  },
  mutations: {
    retrieveDataRestaurantMutation(state, restaurante) {
      state.restauranteData = restaurante;
    },
    retrieveToken(state, token) {
      state.token = token;
    },
    destroyToken(state) {
      state.token = null;
    },
    changeTypeUser(state, type) {
      state.type_user = type;
    },
    destroyTypeUser(state) {
      state.type_user = null;
    },
    getIdRestaurant(state, type) {
      state.id_restaurant = type;
    },
    destroyIdRestaurant(state) {
      state.id_restaurant = null;
    },
    retrieveSexo(state, type) {
      state.sexo = type;
      if(type){
        state.fotoPerfil = 'perfil-masculino.svg'
        localStorage.setItem("fotoPerfil", "perfil-masculino.svg");
      }else{
        state.fotoPerfil = 'perfil-femenino.svg'
        localStorage.setItem("fotoPerfil", "perfil-femenino.svg");
      }
    },
    destroySexo(state) {
      state.sexo = null;
      state.fotoPerfil = null;
    },
    indicePedidosActiveMutation(state, val) {
      state.indicePedidosActive = val;
    }
  },
  actions: {
    retrieveToken(context, credentials) {
      let ruta_user = "";
      if (credentials.type_user == 0) {
        //Mozo
        localStorage.setItem("type_user", 0);
        context.commit("changeTypeUser", 0);
        ruta_user = "login-mozo";
      } else if (credentials.type_user == 1) {
        //Cajero
        localStorage.setItem("type_user", 1);
        context.commit("changeTypeUser", 1);
        ruta_user = "login-cajero";
      } else if (credentials.type_user == 2) {
        //Administrador
        localStorage.setItem("type_user", 2);
        context.commit("changeTypeUser", 2);
        ruta_user = "login-administrador";
      } else if (credentials.type_user == 3) {
        //Super Administrador
        localStorage.setItem("type_user", 3);
        context.commit("changeTypeUser", 3);
        ruta_user = "login-sadmin";
      } else if (credentials.type_user == 4) {
        //Cocinero
        localStorage.setItem("type_user", 4);
        context.commit("changeTypeUser", 4);
        ruta_user = "login-cocinero";
      }
      return new Promise((resolve, reject) => {
        axios
          .post(context.state.url_root + "api/auth/" + ruta_user, {
            nombre_usuario: credentials.nombre_usuario,
            password: credentials.password,
            type_user: credentials.type_user
          })
          .then(response => {
            const token = response.data.access_token;
            localStorage.setItem("access_token", token);
            localStorage.setItem("idRestaurante", response.data.id_restaurant);
            localStorage.setItem("sex", response.data.sexo);
            context.commit("retrieveToken", token);
            context.commit("getIdRestaurant", response.data.id_restaurant);
            context.commit("retrieveSexo", response.data.sexo);
            resolve(response);
          })
          .catch(error => {
            localStorage.removeItem("access_token");
            localStorage.removeItem("type_user");
            localStorage.removeItem("getIdRestaurant");
            localStorage.removeItem("sex");
            reject(error);
          });
      });
    },
    destroyToken(context) {
      if (context.getters.loggedIn) {
        axios.defaults.headers.common["Authorization"] =
          "Bearer " + context.state.token;
        let ruta_user = "";
        if (context.state.type_user == 0) {
          ruta_user = "logout-mozo";
        } else if (context.state.type_user == 1) {
          ruta_user = "logout-cajero";
        } else if (context.state.type_user == 2) {
          ruta_user = "logout-administrador";
        } else if (context.state.type_user == 3) {
          ruta_user = "logout-sadmin";
        } else if (context.state.type_user == 4) {
          ruta_user = "logout-cocinero";
        }
        return new Promise((resolve, reject) => {
          axios
            .post(context.state.url_root + "api/auth/" + ruta_user)
            .then(response => {
              localStorage.removeItem("access_token");
              context.commit("destroyToken");
              localStorage.removeItem("type_user");
              context.commit("destroyTypeUser");
              localStorage.removeItem("idRestaurante");
              context.commit("destroyIdRestaurant");
              localStorage.removeItem("sex");
              context.commit("destroySexo");
              resolve(response);
            })
            .catch(error => {
              localStorage.removeItem("access_token");
              context.commit("destroyToken");
              localStorage.removeItem("type_user");
              context.commit("destroyTypeUser");
              localStorage.removeItem("idRestaurante");
              context.commit("destroyIdRestaurant");
              localStorage.removeItem("sex");
              context.commit("destroySexo");
              reject(error);
            });
        });
      }
    },
    indicePedidosActiveAction(context, x) {
      context.commit("indicePedidosActiveMutation", x);
    },
    retrieveDataRestaurantAction(context, r) {
      context.commit("retrieveDataRestaurantMutation", r);
    }
  }
});
