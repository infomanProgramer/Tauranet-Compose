<template>
    <div class="col-md-12">
        <div class="row">
            <div class="col-md-12">
                <h4 class="sub-cajero">Fecha vs Importe</h4>
                <!-- Fecha vs Cantidad -->
            </div>
        </div>
        <div class="row">
            <div class="col-md-4">
                <div class="form-group">
                    <flat-pickr
                            v-model="fecha.ini"                                                       
                            class="form-control input-style"
                            :config="config"
                            placeholder="Fecha Ini">
                    </flat-pickr>
                    <ListErrors :errores="errores.ini"></ListErrors>
                </div>
            </div>
            <div class="col-md-4">
                <div class="form-group">
                    <flat-pickr
                        v-model="fecha.fin"                                                       
                        class="form-control input-style"
                        :config="config"
                        placeholder="Fecha Fin"
                    >
                    </flat-pickr>
                    <ListErrors :errores="errores.fin"></ListErrors>
                </div>
            </div>
            <div class="col-md-4">
                <button @click="fechaImporteMethod()" class="btn btn-primary float-right" ref="btnBuscarRef">Buscar</button>
            </div>
        </div>
        <div class="row" v-if="loaded">
            <div class="col-md-8 table-responsive">
                <LineChart v-if="empleadoPedidoTableArray.length>1" :chart-data="empleadoPedidoCollection" :options="options"></LineChart>
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
        fechaImporteMethod(url) {
            this.$Progress.start()
            this.$refs.btnBuscarRef.className = "btn btn-primary float-right disabled"
            url = url || this.$store.state.url_root+`api/auth/fechaimporte/${this.$store.state.id_restaurant}/fechaini/${this.fecha.ini}/fechafin/${this.fecha.fin}`
            this.labels = []
            this.pedidos = []
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                if(response.data.error == null){
                    this.errores = {}
                    this.empleadoPedidoArray = response.data.data;
                    this.empleadoPedidoTableArray = response.data.dataT.data
                    this.pagination = response.data.dataT
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
                    this.$refs.btnBuscarRef.className = "btn btn-primary float-right"
                    this.$Progress.finish()
                }else{
                    this.errores = response.data.error
                    this.$refs.btnBuscarRef.className = "btn btn-primary float-right"
                    this.$Progress.fail()
                }
            })
            .catch (error => {
                this.$toasted.show("Estadisticas.vue: "+error, {type: 'error'})
                this.$Progress.fail()
                this.$refs.btnBuscarRef.className = "btn btn-primary float-right"
            });
        }
    },
}
</script>