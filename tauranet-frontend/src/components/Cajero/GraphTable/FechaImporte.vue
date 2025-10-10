<template>
    <div class="col-md-12">
        <div class="row">
            <div class="col-md-12">
                <h4 class="mt-3 mb-2 font-weight-bold text-primary" style="font-size: 1.5rem; border-bottom: 3px solid #007bff; padding-bottom: 6px;">
                    Ventas por fecha
                </h4>
            </div>
        </div>
        <div class="row">
            <div class="col-md-3">
                <div class="form-group">
                    <flat-pickr
                            v-model="fecha.ini"                                                       
                            class="form-control input-style"
                            :config="config"
                            placeholder="Fecha desde">
                    </flat-pickr>
                    <ListErrors :errores="errores.ini"></ListErrors>
                </div>
            </div>
            <div class="col-md-3">
                <div class="form-group">
                    <flat-pickr
                        v-model="fecha.fin"                                                       
                        class="form-control input-style"
                        :config="config"
                        placeholder="Fecha hasta"
                    >
                    </flat-pickr>
                    <ListErrors :errores="errores.fin"></ListErrors>
                </div>
            </div>
            <div class="col-md-1 d-flex justify-content-start align-items-end">
                <!-- <div class="form-group">
                    X: Fecha Y:
                </div> -->
            </div>
            <div class="col-md-2 d-flex justify-content-start align-items-end">
                <!-- <div class="form-group">
                    <select class="form-control input-style" v-model="comboEjeY">
                        <option v-for="s in datosEjeY" v-bind:key="s.id" :value="s.id" :selected="s.id == 1">{{s.label}}</option>
                    </select>
                </div> -->
            </div>
            <div class="col-md-3 d-flex justify-content-end align-items-end">
                <button @click="fechaImporteMethod()" class="btn btn-primary mr-2" ref="btnBuscarRef">Generar</button>
                <button class="btn btn-success mr-2" @click="exportarExcel">Excel</button>
                <button class="btn btn-danger" @click="exportarPDF">PDF</button>
            </div>
        </div>
        <div class="row" v-if="loaded">
            <div class="col-md-8 table-responsive">
                <LineChart ref="barChartRef" v-if="empleadoPedidoTableArray.length>1" :chart-data="empleadoPedidoCollection" :options="options"></LineChart>
            </div>
            <div class="col-md-4">
                <div class="row">
                    <div class="col-md-12 table-responsive">
                        <table-component
                            :data="empleadoPedidoTableArray"
                            tableClass="table table-bordered table-condensed"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="fecha" label="Fecha"></table-column>
                            <table-column show="importe" label="Importe"></table-column>
                        </table-component>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 table-responsive">
                        <Pagination :pagination="pagination" v-on:funcion="fechaImporteMethod"></Pagination>
                    </div>
                </div>
            </div>
        </div>
    </div>  
</template>
<script>
const axios = require("axios");
import flatPickr from 'vue-flatpickr-component';
import LineChart from '@/components/Charts/LineChart';
import Pagination from '@/components/Pagination/Pagination';
import 'flatpickr/dist/flatpickr.css';
import ListErrors from '@/components/Messages/ListErrors';
export default{
    name: 'FechaImporte',
    components: {
        flatPickr,
        LineChart,
        Pagination,
        ListErrors
    },
    data() {
        return {
            loaded: false,
            empleadoPedidoArray: [],
            empleadoPedidoTableArray: [],
            pagination: {},
            errores: {},
            empleadoPedidoCollection: null,
            labels: [],
            pedidos: [],
            fecha: {
                ini: null,
                fin: null
            },
            datosEjeY: [
                {
                    id: 1,
                    label: 'Total ventas' 
                },
                {
                    id: 2,
                    label: 'Total ganancias' 
                }
            ],
            comboEjeY: 1,
            config: {
                wrap: true, // set wrap to true only when using 'input-group'
                altFormat: 'j/n/Y',
                altInput: true,
                dateFormat: 'Y-m-d',
                allowInput: true,
                wrap: false,
                static: true     
            },
            options: {
                responsive: true,
                maintainAspectRatio: false
            }
        }
    },
    methods: {
        exportarExcel() {
            if(this.hasOneParameter)
                this.fecha.fin = this.fecha.ini;   
            this.$Progress.start();
            let url = this.$store.state.url_root+`api/auth/fechaimporteexcel`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, {
                idRestaurante: this.$store.state.id_restaurant,
                fecha_inicio: this.fecha.ini,
                fecha_fin: this.fecha.fin
            }, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data]));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `ventasPorRangoFechaExcel_${this.fecha.ini}_${this.fecha.fin}.xlsx`);
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
            let chartBase64 = null;
            if (this.$refs.barChartRef && this.$refs.barChartRef.$el) {
                const canvas = this.$refs.barChartRef.$el.querySelector('canvas');
                if (canvas) {
                    chartBase64 = canvas.toDataURL('image/png');
                }
            }
            let datosPdf = {
                idRestaurante: this.$store.state.id_restaurant,
                nombre_restaurante: this.$store.state.restauranteData.restaurant,
                fecha_inicio: this.fecha.ini,
                fecha_fin: this.fecha.fin,
                sucursal: this.$store.state.restauranteData.sucursal,
                caja: this.$store.state.restauranteData.caja,
                chartBase64: chartBase64
            };
            let url = this.$store.state.url_root + `api/auth/fechaimportepdf`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, datosPdf, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `ventasPorRangoFechaPDF_${this.fecha.ini}_${this.fecha.fin}.pdf`);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.$Progress.finish();
            })
            .catch(error => {
                this.$toasted.show("Error al exportar a PDF: " + error, { type: 'error' });
                this.$Progress.fail();
            });
        },
        fechaImporteMethod(url) {
            this.$Progress.start()
            this.$refs.btnBuscarRef.className = "btn btn-primary mr-2 disabled"
            url = url || this.$store.state.url_root+`api/auth/fechaimporte`
            this.labels = []
            this.pedidos = []
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, {
                idRestaurante: this.$store.state.id_restaurant,
                fecha_inicio: this.fecha.ini,
                fecha_fin: this.fecha.fin
            })
            .then(response => {
                if(response.data.error == null){
                    this.errores = {}
                    this.empleadoPedidoArray = response.data.dataChart;
                    this.empleadoPedidoTableArray = response.data.dataTable.data
                    this.pagination = response.data.dataTable
                    this.empleadoPedidoArray.forEach(element => {
                        this.labels.push(element.fecha)
                        this.pedidos.push(element.importe)
                    })
                    this.empleadoPedidoCollection = {
                        labels: this.labels,
                        datasets: [{
                            label: 'Importe',
                            borderColor: '#6141f9',
                            data: this.pedidos
                        }]
                    }
                    this.loaded = true
                    this.$refs.btnBuscarRef.className = "btn btn-primary mr-2"
                    this.$Progress.finish()
                }else{
                    this.errores = response.data.error
                    this.$refs.btnBuscarRef.className = "btn btn-primary mr-2"
                    this.$Progress.fail()
                }
            })
            .catch (error => {
                this.$toasted.show("Estadisticas.vue: "+error, {type: 'error'})
                this.$Progress.fail()
                this.$refs.btnBuscarRef.className = "btn btn-primary mr-2"
            });
        }
    },
}
</script>