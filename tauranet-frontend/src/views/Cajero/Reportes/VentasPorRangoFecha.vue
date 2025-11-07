<template>
    <Marco titulo="Reporte de ventas por rango de fecha" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <form @submit.prevent="getReportByInterval()">
                <div class="row">
                    <div class="col-md-12">
                        <h4 class="mt-3 mb-2 font-weight-bold text-primary" style="font-size: 1.5rem; border-bottom: 3px solid #007bff; padding-bottom: 6px;">
                            Detalle de ventas
                        </h4>
                    </div>
                </div>
                <div class="row">
                        <div class="col-md-3 d-flex justify-content-start align-items-end">
                            <flat-pickr
                                v-model="fecha.ini"
                                class="form-control input-style"
                                :config="config"
                                placeholder="Fecha desde"
                            >
                            </flat-pickr>
                            <!-- <ListErrors :errores="fecha"></ListErrors> -->
                        </div>
                        <div class="col-md-3 d-flex justify-content-start align-items-end">
                            <flat-pickr
                                v-model="fecha.fin"
                                class="form-control input-style"
                                :config="config"
                                placeholder="Fecha hasta"
                            >
                            </flat-pickr>
                            <!-- <ListErrors :errores="fecha"></ListErrors> -->
                        </div>
                        <div class="col-md-6 d-flex justify-content-end align-items-end">
                            <button type="submit" class="btn btn-primary mr-2">Generar</button>
                            <button type="button" class="btn btn-success mr-2" @click="exportarExcel">Excel</button>
                            <button type="button" class="btn btn-danger" @click="exportarPDF">PDF</button>
                        </div>
                </div>
            </form>
            <div class="row">
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table-component
                            :data="ventasPorRangoArray"
                            tableClass="table table-condensed table-bordered"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="fecha" label="Fecha"></table-column>
                            <table-column show="cantidad" label="Pedidos"></table-column>
                            <table-column show="total_efectivo" label="Total efectivo"></table-column>
                            <table-column show="total_tarjeta" label="Total tarjeta"></table-column>
                            <table-column show="total_qr" label="Total QR" :sortable="false"></table-column> 
                            <table-column show="total_ventas" label="Total ventas" :sortable="false"></table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="getReportByInterval"></Pagination>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <h4 class="mt-3 mb-2 font-weight-bold text-primary" style="font-size: 1.5rem; border-bottom: 3px solid #007bff; padding-bottom: 6px;">
                        Totales
                    </h4>
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped table-condensed" style="table-layout: fixed; width: 100%;">
                            <colgroup>
                                <col style="width: 20%;">
                                <col style="width: 40%;">
                                <col style="width: 40%;">
                            </colgroup>
                            <tbody>
                                <tr>
                                    <td scope="col" class="subtituloPedidos">Total pedidos</td>
                                    <td scope="col">{{totalDia.total_pedidos}}</td>
                                    <td scope="col"></td>
                                </tr>
                                <tr>
                                    <td scope="col" class="subtituloPedidos">Total importe</td>
                                    <td scope="col">{{totalDia.total_ventas}}</td>
                                    <td scope="col"></td>
                                </tr>
                                <tr>
                                    <td scope="col" class="subtituloPedidos">Total por tipo de pago</td>
                                    <td scope="col"></td>
                                    <td scope="col"></td>
                                </tr>
                                <tr>
                                    <td scope="col" class="subtituloPedidos"></td>
                                    <td scope="col" class="subtituloPedidos">Efectivo</td>
                                    <td scope="col">{{totalEfectivo.total_efectivo}}</td>
                                </tr>
                                <tr>
                                    <td scope="col" class="subtituloPedidos"></td>
                                    <td scope="col" class="subtituloPedidos">Tarjeta</td>
                                    <td scope="col">{{totalTarjeta.total_tarjeta}}</td>
                                </tr>
                                <tr>
                                    <td scope="col" class="subtituloPedidos"></td>
                                    <td scope="col" class="subtituloPedidos">QR</td>
                                    <td scope="col">{{totalQR.total_qr}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div class="row">
                <FechaImporte/>
            </div>
            <div class="row">
                <SemanaImporte/>
            </div>
            <div class="row">
                <MesImporte/>
            </div>
            <div class="row">
                <ProductoImporte :hasOneParameter="false"></ProductoImporte>
            </div>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import {misMixins} from '@/mixins/misMixins.js';
import flatPickr from 'vue-flatpickr-component';
import Pagination from '@/components/Pagination/Pagination';
import FechaImporte from '@/components/Cajero/GraphTable/FechaImporte'
import SemanaImporte from '@/components/Cajero/GraphTable/SemanaImporte'
import MesImporte from '@/components/Cajero/GraphTable/MesImporte'
import ProductoImporte from '@/components/Cajero/GraphTable/ProductoImporte'
export default{
    name: 'VentasPorRangoFecha',
    components: {
        Marco,
        flatPickr,
        Pagination,
        FechaImporte,
        SemanaImporte,
        MesImporte,
        ProductoImporte
    },
    data(){
        return {
            fecha: {},
            ventasPorRangoArray: [],
            totalDia: {},
            totalEfectivo: {},
            totalTarjeta: {},
            totalQR: {},
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
        getReportByInterval(url){
            let datosPdf = {
                idRestaurante: this.$store.state.id_restaurant,
                fecha_inicio: this.fecha.ini,
                fecha_fin: this.fecha.fin
            };
            this.$Progress.start();
            url = url || this.$store.state.url_root+`api/auth/getreportbyinterval`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, datosPdf)
            .then(response => {
                this.ventasPorRangoArray = response.data.ventasPorRangoFecha.data;
                this.pagination = response.data.ventasPorRangoFecha;
                this.totalDia = response.data.totalDia;
                this.totalEfectivo = response.data.totalEfectivo;
                this.totalTarjeta = response.data.totalTarjeta;
                this.totalQR = response.data.totalQR;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });

        },
        exportarExcel(){
            // Lógica para exportar a Excel
            this.$Progress.start();
            let datosPdf = {
                idRestaurante: this.$store.state.id_restaurant,
                fecha_inicio: this.fecha.ini,
                fecha_fin: this.fecha.fin
            };
            let url = this.$store.state.url_root+`api/auth/getreportbyintervalexcel`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, datosPdf, { responseType: 'blob' })
            .then(response => {
                console.log(response.data);
                const url = window.URL.createObjectURL(new Blob([response.data]));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `reporte_ventas_intervalo_fechas_${this.fecha.ini}-${this.fecha.fin}.xlsx`);
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
        exportarPDF(){
            this.$Progress.start();
            let datosPdf = {
                idRestaurante: this.$store.state.id_restaurant,
                nombre_restaurante: this.$store.state.restauranteData.restaurant,
                fecha_inicio: this.fecha.ini,
                fecha_fin: this.fecha.fin,
                sucursal: this.$store.state.restauranteData.sucursal,
                caja: this.$store.state.restauranteData.caja
            };
            let url = this.$store.state.url_root + `api/auth/getreportbyintervalpdf`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, datosPdf, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `reporteVentasPorRangoFecha${this.fecha.ini}-${this.fecha.fin}.pdf`);
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