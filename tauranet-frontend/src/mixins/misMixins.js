const axios = require("axios");
export const misMixins = {
  data() {
    return {
      mixin_data_usuario: {}
    };
  },
  methods: {
    getDataUser: function(type_user) {
      // type_user = 0 mozo
      // type_user = 1 cajero
      // type_user = 2 administrador
      // type_user = 3 super administrador
      // type_user = 3 Cocinero
      axios.defaults.headers.common["Authorization"] =
        "Bearer " + this.$store.state.token;
      let url = "";
      if (type_user == 0) {
        url = this.$store.state.url_root + `api/auth/me-mozo`;
      } else if (type_user == 1) {
        url = this.$store.state.url_root + `api/auth/me-cajero`;
      } else if (type_user == 2) {
        url = this.$store.state.url_root + `api/auth/me-administrador`;
      } else if (type_user == 3) {
        url = this.$store.state.url_root + `api/auth/me-sadmin`;
      } else if (type_user == 4) {
        url = this.$store.state.url_root + `api/auth/me-cocinero`;
      }
      return new Promise((resolve, reject) => {
        axios
          .post(url)
          .then(response => {
            resolve(response);
          })
          .catch(error => {
            alert("misMixin.js: " + error);
            reject(error);
          });
      });
    },
    getDataRestaurante: function(type_user, id) {
      // type_user = 0 mozo
      // type_user = 1 cajero
      // type_user = 2 administrador
      // type_user = 3 super administrador
      // type_user = 4 Cocinero
      axios.defaults.headers.common["Authorization"] =
        "Bearer " + this.$store.state.token;
      return new Promise((resolve, reject) => {
        axios
          .get(
            this.$store.state.url_root +
              `api/auth/restaurantedatos/user/${id}/type/${type_user}`
          )
          .then(response => {
            resolve(response);
          })
          .catch(error => {
            this.$toasted.show("misMixin.js: " + error, { type: "error" });
            reject(error);
          });
      });
    }
  }
};
