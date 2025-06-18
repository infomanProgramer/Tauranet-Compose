<template>
    <Marco titulo="Tipo de identificación" icono="fas fa-table">
        <div class="container">
            <BoxMessage :message="datosRepetidos" :cod="'su'" icono="fas fa-check-circle"></BoxMessage>
            <form @submit.prevent="cambiaIdentifcacion()">
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="" class="label-style">Identificación Actual</label>
                        <input type="text" class="form-control" :value="restauranteObj.identificacion" disabled>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="" class="label-style">Nueva Identificación</label>
                        <input type="text" class="form-control" v-model="new_identificacion">
                        <ListErrors :errores="errores.identificacion"></ListErrors>
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
    name: 'ConfigDni',
    components: {
        Marco,
        BoxMessage,
        ListErrors
    },
    data() {
        return {
            data_usr: {},
            restauranteObj: {},
            new_identificacion: '',
            datosRepetidos: '',
            errores: {}
        }
    },
    created () {
        this.$Progress.start()
        this.getDataUser(2).then(response => {
            this.data_usr = response.data;
            this.cargaConfigIdentificacion();
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    mixins: [misMixins],
    methods: {
        cargaConfigIdentificacion() {
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/restaurant/${this.data_usr.id_restaurant}`)
            .then(response => {
                this.restauranteObj = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("TipoMoneda: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaIdentifcacion(){
            this.$Progress.start()
            let obj = {}
            obj.identificacion = this.new_identificacion
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.put(this.$store.state.url_root+`api/auth/udpateidentificacacion/${this.data_usr.id_restaurant}`, obj)
            .then(response => {
                if(response.data.error == null){
                    this.datosRepetidos = 'El simbolo de la moneda se cambio correctamente'
                    this.new_identificacion = ''
                    this.errores = {}
                    this.cargaConfigIdentificacion()
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