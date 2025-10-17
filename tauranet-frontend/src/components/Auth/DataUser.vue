<template>
    <span>
        <span v-for="item in dataReturn" :key="item.id">
            {{datosUsuarioObj[item]}}
        </span>
    </span>
</template>
<script>
    const axios = require("axios");
    export default{
        name: 'DataUser',
        props: {
            dataReturn: {
                type: Array,
            }
        },
        data() {
            return {
                datosUsuarioObj: {}
            }
        },
        created () {
            this.dataUser();
        },
        methods: {
            dataUser() {
                let user_path = "";
                if (this.$store.state.type_user == 0) {
                    user_path = "me-mozo";
                } else if (this.$store.state.type_user == 1) {
                    user_path = "me-cajero";
                } else if (this.$store.state.type_user == 2) {
                    user_path = "me-administrador";
                } else if (this.$store.state.type_user == 3) {
                    user_path = "me-sadmin";
                } else if (this.$store.state.type_user == 4) {
                    user_path = "me-cocinero";
                }
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.post(this.$store.state.url_root+"api/auth/"+user_path)
                .then(response => {
                    this.datosUsuarioObj = response.data;
                })
                .catch(error => {
                    this.$toasted.show("DataUser.vue: "+error, {type: 'error'});
                });
            },
        }
    }
</script>