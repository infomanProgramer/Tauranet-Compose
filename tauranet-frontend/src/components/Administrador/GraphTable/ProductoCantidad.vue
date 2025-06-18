<template>
    <div class="col-md-12">
        <div class="row">
            <div class="col-md-12">
                <h4 class="sub-cajero">Producto vs Cantidad</h4>
            </div>
        </div>
        <div class="row">
            <div class="col-md-3">
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
            <div class="col-md-3">
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
            <div class="col-md-3">
                <div class="form-group">
                    <label for="">
                        <select class="form-control input-style" v-model="comboCategorias">
                            <option value="-1" selected>Categoria...</option>
                            <option v-for="s in listaCategoria" v-bind:key="s.id_categoria_producto" :value="s.id_categoria_producto">{{s.nombre}}</option>
                        </select>
                    </label>
                </div>
            </div>
            <div class="col-md-3">
                <button @click="productoCantidadMethod()" class="btn btn-primary float-right" ref="btnBuscarRef">Buscar</button>
            </div>
        </div>
        <div class="row" v-if="loaded">
            <div class="col-md-8 table-responsive">
                <BarChart :chart-data="empleadoPedidoCollection" :options="options"></BarChart>
            </div>
            <div class="col-md-4">
                <div class="row">
                    <div class="col-md-12 table-responsive">
                        <table-component
                            :data="productoCantidadTableArray"
                            tableClass="table table-bordered table-condensed"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nom_producto" label="Producto"></table-column>
                            <table-column show="nom_categoria" label="Categoría"></table-column>
                            <table-column show="cantidad" label="Cantidad"></table-column>
                        </table-component>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12 table-responsive">
                        <Pagination :pagination="pagination" v-on:funcion="productoCantidadMethod"></Pagination>
                    </div>
                </div>
            </div>
        </div>
    </div>  
</template>
<script>
const axios = require("axios");
import flatPickr from 'vue-flatpickr-component';
import BarChart from '@/components/Charts/BarChart';
import Pagination from '@/components/Pagination/Pagination';
import 'flatpickr/dist/flatpickr.css';
import ListErrors from '@/components/Messages/ListErrors';
export default{
    name: 'ProductoCantidad',
    components: {
        flatPickr,
        BarChart,
        Pagination,
        ListErrors
    },
    data() {
        return {
            comboCategorias: -1,
            listaCategoria: [],
            loaded: false,
            productoCantidadArray: [],
            productoCantidadTableArray: [],
            pagination: {},
            empleadoPedidoCollection: null,
            labels: [],
            cantidad: [],
            errores: {},
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
    created () {
        this.comboCategoria()
    },
    methods: {
        comboCategoria(){
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/cproducto/restaurant/${this.$store.state.id_restaurant}`)
            .then(response => {
                this.listaCategoria = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        productoCantidadMethod(url) {
            this.$Progress.start()
            this.$refs.btnBuscarRef.className = "btn btn-primary float-right disabled"
            url = url || this.$store.state.url_root+`api/auth/productocantidad/${this.$store.state.id_restaurant}/categoria/${this.comboCategorias}/fechaini/${this.fecha.ini}/fechafin/${this.fecha.fin}`
            this.labels = []
            this.cantidad = []
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                if(response.data.error == null){
                    this.errores = {}
                    this.productoCantidadArray = response.data.data;
                    this.productoCantidadTableArray = response.data.dataT.data
                    this.pagination = response.data.dataT
                    this.productoCantidadArray.forEach(element => {
                        this.labels.push(element.nom_producto)
                        this.cantidad.push(element.cantidad)
                    })
                    this.empleadoPedidoCollection = {
                        labels: this.labels,
                        datasets: [{
                            label: 'Producto',
                            backgroundColor: '#9c27b0',
                            data: this.cantidad
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
                this.$toasted.show("ProductoCantidad.vue: "+error, {type: 'error'})
                this.$Progress.fail()
                this.$refs.btnBuscarRef.className = "btn btn-primary float-right"
            });
        }
    },
}
</script>