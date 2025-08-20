<template>
    <div class="col-md-12">
        <div class="row">
            <div class="col-md-12">
                <h4 class="mt-3 mb-2 font-weight-bold text-primary" style="font-size: 1.5rem; border-bottom: 3px solid #007bff; padding-bottom: 6px;">
                    Ventas por mes
                </h4>
            </div>
        </div>
        <div class="row">
            <div class="col-md-2">
                <div class="form-group">
                    <select class="form-control input-style" v-model="selectedYear">
                        <option v-for="year in availableYears" v-bind:key="year" :value="year">{{year}}</option>
                    </select>
                    <ListErrors :errores="errores.year"></ListErrors>
                </div>
            </div>
            <div class="col-md-3"></div>
            <div class="col-md-1 d-flex justify-content-start align-items-end">
                <div class="form-group">
                    X: Fecha Y:
                </div>
            </div>
            <div class="col-md-2 d-flex justify-content-start align-items-end">
                <div class="form-group">
                    <select class="form-control input-style" v-model="comboEjeY">
                        <option v-for="s in datosEjeY" v-bind:key="s.id" :value="s.id" :selected="s.id == 1">{{s.label}}</option>
                    </select>
                </div>
            </div>
            <div class="col-md-4 d-flex justify-content-end align-items-end">
                <button @click="mesImporteMethod()" class="btn btn-primary mr-2" ref="btnBuscarRef">Generar</button>
                <button class="btn btn-success mr-2" @click="exportarExcel">Excel</button>
                <button class="btn btn-danger" @click="exportarPDF">PDF</button>
            </div>
        </div>
        <div class="row" v-if="loaded">
            <div class="col-md-6 table-responsive">
                <LineChart ref="barChartRef" v-if="empleadoPedidoTableArray.length>1" :chart-data="empleadoPedidoCollection" :options="options"></LineChart>
            </div>
            <div class="col-md-6">
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
                            <table-column show="mes" label="Mes"></table-column>
                            <table-column show="total_pedidos" label="Total Pedidos"></table-column>
                            <table-column show="total_ventas" label="Total Ventas"></table-column>
                            <table-column show="total_ganancia" label="Total Ganancia"></table-column>
                        </table-component>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 table-responsive">
                        <Pagination :pagination="pagination" v-on:funcion="mesImporteMethod"></Pagination>
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
    name: 'MesImporte',
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
            selectedYear: new Date().getFullYear(),
            availableYears: [],
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
    mounted() {
        this.getGestionesPagos();
    },
    methods: {
        getGestionesPagos() {
            this.$Progress.start();
            let url = this.$store.state.url_root+`api/auth/getgestionespagos`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.availableYears = response.data.data;
                this.$Progress.finish();
            })
            .catch(error => {
                this.$toasted.show("Error al obtener las gestiones de pagos: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        generateAvailableYears() {
            const currentYear = new Date().getFullYear();
            const startYear = currentYear - 5; // 5 años atrás
            const endYear = currentYear + 1; // 1 año adelante
            
            this.availableYears = [];
            for (let year = endYear; year >= startYear; year--) {
                this.availableYears.push(year);
            }
        },
        exportarExcel() {
            this.$Progress.start();
            let url = this.$store.state.url_root+`api/auth/mesimporte`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, {
                idRestaurante: this.$store.state.id_restaurant,
                year: this.selectedYear,
                formato: 3
            }, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data]));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `mesImporteExcel_${this.selectedYear}.xlsx`);
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
                year: this.selectedYear,
                sucursal: this.$store.state.restauranteData.sucursal,
                caja: this.$store.state.restauranteData.caja,
                chartBase64: chartBase64,
                formato: 2
            };
            let url = this.$store.state.url_root + `api/auth/mesimporte`;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, datosPdf, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `mesImportePDF_${this.selectedYear}.pdf`);
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
        mesImporteMethod(url) {
            this.$Progress.start()
            this.$refs.btnBuscarRef.className = "btn btn-primary mr-2 disabled"
            url = url || this.$store.state.url_root+`api/auth/mesimporte`
            this.labels = []
            this.pedidos = []
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(url, {
                idRestaurante: this.$store.state.id_restaurant,
                year: this.selectedYear,
                formato: 1, //1 html, 2 pdf, 3 excel
            })
            .then(response => {
                if(response.data.error == null){
                    this.errores = {}
                    this.empleadoPedidoArray = response.data.dataChart;
                    this.empleadoPedidoTableArray = response.data.mesesArray.data
                    this.pagination = response.data.mesesArray
                    this.empleadoPedidoArray.forEach(element => {
                        this.labels.push(element.mes)
                        this.pedidos.push(this.comboEjeY == 1?element.total_ventas:element.total_ganancia)
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
                this.$toasted.show("MesImporte.vue: "+error, {type: 'error'})
                this.$Progress.fail()
                this.$refs.btnBuscarRef.className = "btn btn-primary mr-2"
            });
        }
    },
}
</script>
