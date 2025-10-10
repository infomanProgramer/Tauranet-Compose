<template>
    <Marco titulo="Cambiar contraseña" icono="fas fa-table">
        <div class="container">
            <BoxMessage :message="datosRepetidos" :cod="'su'" icono="fas fa-check-circle"></BoxMessage>
            <form @submit.prevent="changePasssword()">
            <div class="row">
                <div class="col-md-4">
                    <div class="form-group">
                        <label for="" class="label-style">Contraseña</label>
                        <input type="password" class="form-control" v-model="req.password_ant">
                        <ListErrors :errores="errores.password_ant"></ListErrors>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label for="" class="label-style">Nueva Contraseña</label>
                        <input type="password" class="form-control" v-model="req.password">
                        <ListErrors :errores="errores.password"></ListErrors>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="form-group">
                        <label for="" class="label-style">Confirmar Contraseña</label>
                        <input type="password" class="form-control" v-model="req.password_confirmation">
                        <ListErrors :errores="errores.password_confirm"></ListErrors>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <button class="btn btn-primary" type="submit">Cambiar</button>
                </div>
            </div>
            </form>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import {misMixins} from '@/mixins/misMixins.js';
import BoxMessage from '@/components/Messages/BoxMessage';
import ListErrors from '@/components/Messages/ListErrors';
export default{
    name: 'Password',
    components: {
        Marco,
        BoxMessage,
        ListErrors
    },
    data() {
        return {
            data_usr: {},
            req: {},
            datosRepetidos: '',
            errores: {}
        }
    },
    created () {
        this.$Progress.start()
        this.getDataUser(this.$store.state.type_user).then(response => {//cajero
            this.data_usr = response.data;
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    mixins: [misMixins],
    methods: {
        limpiaPassword(){
            this.req =  {}
            this.errores = {}
        },
        changePasssword(){
            this.$Progress.start()
            let idUsuario = -1
            if(this.$store.state.type_user == 0){
                idUsuario = this.data_usr.id_mozo
            }else if(this.$store.state.type_user == 1){
                idUsuario = this.data_usr.id_cajero
            }else if(this.$store.state.type_user == 2){
                idUsuario = this.data_usr.id_administrador
            }else if(this.$store.state.type_user == 3){
                idUsuario = this.data_usr.id_superadministrador
            }else if(this.$store.state.type_user == 4){
                idUsuario = this.data_usr.id_cocinero
            }
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(this.$store.state.url_root+`api/auth/changepassword/usuario/${idUsuario}/typeuser/${this.$store.state.type_user}`, this.req)
            .then(response => {
                if(response.data.error == null){
                    this.datosRepetidos = 'La contraseña se cambio correctamente'
                    this.limpiaPassword();
                    this.$Progress.finish()
                }else{
                    this.errores = response.data.error
                    this.$Progress.fail()
                }
            })
            .catch (error => {
                this.$toasted.show("TipoMoneda: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        }
    },
}
</script>