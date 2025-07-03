<template>
    <Marco titulo="Hoy" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    <div class="form-group">
                        <button type="button" class="btn btn-success" @click="getReportToday"><i class="fas fa-sync-alt"></i></button>
                    </div>
                </div>
            </div>
            <div class="row" v-for="item in date_reportHoy" v-bind:key="item.id">
                <div class="col-md-4">
                    <CardSucursal :nameSucursal="item.nombre"></CardSucursal>
                </div>
                <div class="col-md-4">
                    <CardVenta :fechaActual="item.fecha" :cantVentas="parseInt(item.count)"></CardVenta>
                </div>
                <div class="col-md-4">
                    <CardApertura :nombreCaja="item.nombreCaja" :fechaActual="item.fecha" :montoIni="Number(item.monto_inicial)" :montoFin="Number(item.monto)"></CardApertura>
                </div>
            </div>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import CardVenta from '@/components/Administrador/CardVenta'
import CardApertura from '@/components/Administrador/CardApertura'
import CardSucursal from '@/components/Administrador/CardSucursal'
import {misMixins} from '@/mixins/misMixins.js';

export default{
    name: 'Hoy',
    components: {
        Marco,
        CardVenta,
        CardApertura,
        CardSucursal
    },
    created () {
        this.$Progress.start()
        this.getDataUser(2).then(response => {
            this.data_usr = response.data;
            this.getReportToday()
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    data() {
        return {
            data_usr: {},
            date_reportHoy: []
        }
    },
    mixins: [misMixins],
    methods: {
        getReportToday(){
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/reportehoy/${this.$store.state.id_restaurant}`)
            .then(response => {
                this. date_reportHoy = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Hoy.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        }
    },
}
</script>