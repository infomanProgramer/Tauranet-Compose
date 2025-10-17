<template>
    <Marco titulo="Simbolo de moneda" icono="fas fa-table">
        <div class="container">
            <BoxMessage :message="datosRepetidos" :cod="'su'" icono="fas fa-check-circle"></BoxMessage>
            <form @submit.prevent="cambiaMoneda()">
            <div class="row">
                <div class="col-md-6 d-flex align-items-center">
                    <div class="form-group">
                        <label for="" class="label-style">Restaurante</label>
                        <select class="form-control input-style" v-model="IdRestauranteSelectedFromForm" @change="getSucursalByRestaurant(2)">
                            <option value="-1" selected>Restaurante...</option>
                            <option v-for="s in listOfAllRestaurantes" v-bind:key="s.id_restaurant" :value="s.id_restaurant">{{s.nombre}}</option>
                        </select>
                        <ListErrors :errores="errores.id_restaurant"></ListErrors>
                    </div>
                </div>
                <div class="col-md-6 d-flex align-items-center">
                    <button type="button" class="btn btn-primary" @click="getConfigByRestaurant()"><i class="fas fa-search"></i> Buscar</button>
                </div>
            </div>
            <div class="row">
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="" class="label-style">Moneda Actual</label>
                        <input type="text" class="form-control" :value="restauranteObj.tipo_moneda" disabled>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="form-group">
                        <label for="" class="label-style">Nueva Moneda</label>
                        <input type="text" class="form-control" v-model="nueva_moneda">
                        <ListErrors :errores="errores.tipo_moneda"></ListErrors>
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
    name: 'TipoMoneda',
    components: {
        Marco,
        BoxMessage,
        ListErrors
    },
    data() {
        return {
            data_usr: {},
            restauranteObj: {},
            nueva_moneda: '',
            datosRepetidos: '',
            errores: {},
            listOfAllRestaurantes: [],
            IdRestauranteSelectedFromForm: -1,
        }
    },
    created () {
        this.$Progress.start()
        this.getAllRestaurantes();
        this.getDataUser(3).then(response => {
            this.data_usr = response.data;
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    mixins: [misMixins],
    methods: {
        getAllRestaurantes(){
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/restaurantall`)
            .then(response => {
                this.listOfAllRestaurantes = response.data.data;
            })
            .catch (error => {
                this.$toasted.show("TipoMoneda.vue: "+error, {type: 'error'})
            });
        },
        getConfigByRestaurant() {
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/restaurant/${this.IdRestauranteSelectedFromForm}`)
            .then(response => {
                this.restauranteObj = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("TipoMoneda: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaMoneda(){
            this.$Progress.start()
            let obj = {}
            obj.tipo_moneda = this.nueva_moneda
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.put(this.$store.state.url_root+`api/auth/updatemoneda/${this.IdRestauranteSelectedFromForm}`, obj)
            .then(response => {
                if(response.data.error == null){
                    this.datosRepetidos = 'El simbolo de la moneda se cambio correctamente'
                    this.nueva_moneda = ''
                    this.getConfigByRestaurant()
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