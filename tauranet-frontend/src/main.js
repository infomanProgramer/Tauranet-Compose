import Vue from "vue";
//import Login from "./views/Auth/Login";
import App from "./App";
import router from "./router";
import store from "./store";
import "bootstrap";
import "./assets/styles/custom.scss";
//import "bootstrap/dist/css/bootstrap.min.css";
window.$ = window.jQuery = require("jquery");
import "@/assets/fonts/all.css";
import { TableComponent, TableColumn } from "vue-table-component";
import VueProgressBar from "vue-progressbar";
import VueProgress from "vue-progress";
import Croppa from "vue-croppa";
import "vue-croppa/dist/vue-croppa.css";
import Toasted from "vue-toasted";
import axios from "axios";

Vue.component("table-component", TableComponent);
Vue.component("table-column", TableColumn);

Vue.config.productionTip = false;
Vue.use(Croppa);
Vue.use(Toasted, {
  action: {
    text: "Cerrar",
    onClick: (e, toastObject) => {
      toastObject.goAway(0);
    }
  },
  position: "top-center",
  theme: "toasted-primary"
});

//Redirecciona a la ruta de login, si el usuario no esta logueado
router.beforeEach((to, from, next) => {
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!store.getters.loggedIn) {
      next({
        name: "login"
      });
    } else {
      //Valida rutas entre roles
      if (to.matched.some(record => record.meta.requiresRolAdministrador)) {
        if (store.state.type_user == 2) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      if (to.matched.some(record => record.meta.requiresRolCajero)) {
        if (store.state.type_user == 1) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      if (to.matched.some(record => record.meta.requiresRolMozo)) {
        if (store.state.type_user == 0) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      if (to.matched.some(record => record.meta.requiresCajeroOrMozo)) {
        if (store.state.type_user == 0 || store.state.type_user == 1) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      if (
        to.matched.some(
          record => record.meta.requiresAdministradorOrMozoOrCajero
        )
      ) {
        if (
          store.state.type_user == 0 ||
          store.state.type_user == 1 ||
          store.state.type_user == 2
        ) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      if (to.matched.some(record => record.meta.requiresAllUsers)) {
        if (
          store.state.type_user == 0 ||
          store.state.type_user == 1 ||
          store.state.type_user == 2 ||
          store.state.type_user == 3 ||
          store.state.type_user == 4
        ) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      if (to.matched.some(record => record.meta.requiresSuperAdmin)) {
        if (store.state.type_user == 3) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      if (to.matched.some(record => record.meta.requiresCocinero)) {
        if (store.state.type_user == 4) {
          next();
        } else {
          next({
            name: "login"
          });
        }
      }
      //next();
    }
  } else {
    next();
  }
});

Vue.use(VueProgress);
Vue.use(VueProgressBar, {
  color: "#ff9800",
  failedColor: "red",
  thickness: "2px",
  transition: {
    speed: "0.2s",
    opacity: "1",
    termination: 300
  },
  autoRevert: true,
  location: "top",
  inverse: false
});

// Interceptor global: en 403 redirige a la pantalla CLI del frontend
axios.interceptors.response.use(
  response => response,
  error => {
    try {
      const status = error && error.response && error.response.status;
      console.log(error.response.data);
      if (status === 403) {
        const msg = (error.response.data && (error.response.data.message || error.response.data.m)) || "Error de licencia.";
        if (router.currentRoute.name !== "license-error") {
          router.push({ name: "license-error", query: { m: msg } });
        }
        // Evitar unhandled rejection en llamadas que no esperan continuar
        return Promise.reject(error);
      }
    } catch (e) {
      // noop
    }
    return Promise.reject(error);
  }
);

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount("#app");
