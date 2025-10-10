<template>
    <Marco titulo="Apertura y cierre de cajas" icono="fas fa-chart-bar">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <label for="">
                                Sucursal
                                <select class="form-control" v-model="idSucursal" @change="listaAperturCajas()">
                                    <option value="-1" selected>Seleccionar...</option>
                                    <option v-for="s in listaSucursales" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                                </select>
                        </label>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table-component
                            :data="aperturaCajas"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombreSucursal" label="Sucursal"></table-column>
                            <table-column show="nombreCaja" label="Caja"></table-column>
                            <table-column show="fecha" label="Fecha"></table-column>
                            <table-column show="monto_inicial" label="Monto Apertura"></table-column>
                            <table-column show="monto" label="Monto Cierre"></table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="listaAperturCajas"></Pagination>
                </div>
            </div>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import {misMixins} from '@/mixins/misMixins.js';
import Pagination from '@/components/Pagination/Pagination';
export default{
    name: 'CajaReport',
    components: {
        Marco,
        Pagination
    },
    created () {
        // this.$Progress.start()
        // this.getDataUser(2).then(response => {
        //     this.data_usr = response.data;
        //     this.$Progress.finish()
        // }).catch(error => {
        //     this.$toasted.show(error, {type: 'error'})
        //     this.$Progress.fail()
        // });
        this.listaSucursalesMethod()
        this.listaAperturCajas()
    },
    data() {
        return {
            data_usr: {},
            pagination: {},
            aperturaCajas: [],
            idSucursal: -1,
            listaSucursales: [],
        }
    },
    mixins: [misMixins],
    methods: {
        listaSucursalesMethod(){
            //this.$Progress.start() comentado a proposito
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/sucursalcombo/${this.$store.state.id_restaurant}`)
            .then(response => {
                this.listaSucursales = response.data.data;
                //this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                //this.$Progress.fail()
            });
        },
        listaAperturCajas(url) {
            this.$Progress.start()
            url = url || this.$store.state.url_root+`api/auth/aperturacajas/${this.$store.state.id_restaurant}/sucursal/${this.idSucursal}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.aperturaCajas = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("CajaReport.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
    },
}
</script>