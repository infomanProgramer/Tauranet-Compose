<template>
    <Marco titulo="Reporte de ventas por día" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <form @submit.prevent="getReportPerDay()">
                <div class="row">
                        <div class="col-md-6 d-flex justify-content-start align-items-end">
                            <flat-pickr
                                v-model="fecha"
                                class="form-control input-style"
                                :config="config"
                                placeholder="Seleccionar fecha"
                            >
                            </flat-pickr>
                            <!-- <ListErrors :errores="fecha"></ListErrors> -->
                        </div>
                        <div class="col-md-6 d-flex justify-content-end align-items-end">
                            <button type="submit" class="btn btn-primary">Buscar</button>
                        </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="table-responsive">
                        <table-component
                            :data="ventasPorDiaArray"
                            tableClass="table table-condensed table-bordered"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="hora" label="Hora"></table-column>
                            <table-column show="nro_pedido" label="Nro. Pedido"></table-column>
                            <table-column show="cliente" label="Cliente"></table-column>
                            <table-column show="atendido_por" label="Atendido Por:"></table-column>
                            <table-column show="tipo_pago" label="Tipo Pago" :sortable="false"></table-column> 
                            <table-column show="total_bruto" label="Total Bruto" :sortable="false"></table-column>
                            <table-column show="total_neto" label="Total Neto" :sortable="false"></table-column>
                            <table-column show="ganancia" label="Ganancia" :sortable="false"></table-column>
                        </table-component>
                    </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                        <div class="table-responsive">
                            <table class="table table-bordered table-striped table-condensed">
                                <tbody>
                                    <tr>
                                        <td scope="col" class="subtituloPedidos">Total Bruto</td>
                                        <td scope="col">{{totalDia.total_bruto}}</td>
                                    </tr>
                                    <tr>
                                        <td scope="col" class="subtituloPedidos">Total Neto</td>
                                        <td scope="col">{{totalDia.total_neto}}</td>
                                    </tr>
                                    <tr>
                                        <td scope="col" class="subtituloPedidos">Total Ganancia</td>
                                        <td scope="col">{{totalDia.ganancia}}</td>
                                    </tr>
                                    <tr>
                                        <td scope="col" class="subtituloPedidos">Tipo pago - Efectivo</td>
                                        <td scope="col">{{totalDia.total_efectivo}}</td>
                                    </tr>
                                    <tr>
                                        <td scope="col" class="subtituloPedidos">Tipo pago - Tarjeta</td>
                                        <td scope="col">{{totalDia.total_tarjeta}}</td>
                                    </tr>
                                    <tr>
                                        <td scope="col" class="subtituloPedidos">Tipo pago - QR</td>
                                        <td scope="col">{{totalDia.total_qr}}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
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
import flatPickr from 'vue-flatpickr-component';
export default{
    name: 'VentasPorDia',
    components: {
        Marco,
        flatPickr
    },
    data(){
        return {
            fecha: null,
            ventasPorDiaArray: [],
            totalDia: {},
            config: {
                wrap: true, // set wrap to true only when using 'input-group'
                altFormat: 'j/n/Y',
                altInput: true,
                dateFormat: 'Y-m-d',
                allowInput: true,
                wrap: false,
                static: true     
            },
        }
    },
    created(){
        this.$Progress.start()
    },
    mixins: [misMixins],
    methods: {
        getReportPerDay(){
            this.$Progress.start();
            console.log(`data: id_restaurante = ${this.$store.state.id_restaurant} fecha = ${this.fecha}`);
            let url = this.$store.state.url_root+`api/auth/getreporteperday/${this.$store.state.id_restaurant}/fecha/${this.fecha}`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                //this.ListaClientes = response.data.data;
                console.log(response.data.ventasPorDia);
                this.ventasPorDiaArray = response.data.ventasPorDia;
                this.totalDia = response.data.totalDia;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });

        },
    },
}
</script>