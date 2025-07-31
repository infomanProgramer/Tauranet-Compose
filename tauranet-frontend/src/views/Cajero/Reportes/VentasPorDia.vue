<template>
    <Marco titulo="Reporte de ventas por día" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <form @submit.prevent="getReportPerDay()">
                <div class="row">
                    <div class="col-md-12">
                        <h4 class="mt-3 mb-2 font-weight-bold text-primary" style="font-size: 1.5rem; border-bottom: 3px solid #007bff; padding-bottom: 6px;">
                            Detalle general
                        </h4>
                    </div>
                </div>
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
                            <button type="submit" class="btn btn-primary mr-2">Generar</button>
                            <button class="btn btn-success mr-2" @click="exportarExcel">Excel</button>
                            <button class="btn btn-danger" @click="exportarPDF">PDF</button>
                        </div>
                </div>
            </form>
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
                            <table-column show="importe" label="Importe" :sortable="false"></table-column>
                            <table-column show="importe_neto" label="Importe Neto" :sortable="false"></table-column>
                            <table-column show="ganancia" label="Ganancia" :sortable="false"></table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="getReportPerDay"></Pagination>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <h4 class="mt-3 mb-2 font-weight-bold text-primary" style="font-size: 1.5rem; border-bottom: 3px solid #007bff; padding-bottom: 6px;">
                        Total del día
                    </h4>
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-condensed">
                            <tbody>
                                <tr>
                                    <td scope="col" class="subtituloPedidos">Importe total</td>
                                    <td scope="col">{{totalDia.importe_total}}</td>
                                </tr>
                                <tr>
                                    <td scope="col" class="subtituloPedidos">Importe neto total</td>
                                    <td scope="col">{{totalDia.importe_neto_total}}</td>
                                </tr>
                                <tr>
                                    <td scope="col" class="subtituloPedidos">Ganancia total</td>
                                    <td scope="col">{{totalDia.ganancia_total}}</td>
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
            <div class="row">
                <ProductoCantidad :hasOneParameter="true"></ProductoCantidad>
            </div>
            <div class="row">
                <ProductoImporte :hasOneParameter="true"></ProductoImporte>
            </div>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import {misMixins} from '@/mixins/misMixins.js';
import flatPickr from 'vue-flatpickr-component';
import ProductoCantidad from '@/components/Cajero/GraphTable/ProductoCantidad';
import ProductoImporte from '@/components/Cajero/GraphTable/ProductoImporte';
import Pagination from '@/components/Pagination/Pagination';

export default{
    name: 'VentasPorDia',
    components: {
        Marco,
        flatPickr,
        ProductoCantidad,
        ProductoImporte,
        Pagination
    },
    data(){
        return {
            fecha: null,
            ventasPorDiaArray: [],
            totalDia: {},
            pagination: {},
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
        getReportPerDay(url){
            this.$Progress.start();
            url = url || this.$store.state.url_root+`api/auth/getreporteperday/${this.$store.state.id_restaurant}/fecha/${this.fecha}`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                //this.ListaClientes = response.data.data;
                console.log(response.data.ventasPorDia);
                this.ventasPorDiaArray = response.data.ventasPorDia.data;
                this.pagination = response.data.ventasPorDia;
                this.totalDia = response.data.totalDia;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });

        },
        exportarExcel() {
            // Lógica para exportar a Excel
            this.$Progress.start();
            let url = this.$store.state.url_root+`api/auth/getreporteperdayexcel/${this.$store.state.id_restaurant}/fecha/${this.fecha}`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url, { responseType: 'blob' })
            .then(response => {
                console.log(response.data);
                const url = window.URL.createObjectURL(new Blob([response.data]));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `reporte_ventas_${this.fecha}.xlsx`);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.$Progress.finish();
            })
            .catch(error => {
                this.$toasted.show("Error al exportar a Excel: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        exportarPDF() {
            this.$Progress.start();
            let url = this.$store.state.url_root + `api/auth/getreporteperdaypdf/${this.$store.state.restauranteData.restaurant}/fecha/${this.fecha}/sucursal/${this.$store.state.restauranteData.sucursal}/caja/${this.$store.state.restauranteData.caja}`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `reporte_ventas_${this.fecha}.pdf`);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.$Progress.finish();
            })
            .catch(error => {
                this.$toasted.show("Error al exportar a PDF: " + error, { type: 'error' });
                this.$Progress.fail();
            });
        }
    },
}
</script>