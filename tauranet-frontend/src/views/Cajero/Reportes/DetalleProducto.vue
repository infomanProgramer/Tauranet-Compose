<template>
    <Marco titulo="Detalle ventas por producto" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <form @submit.prevent="getDetalleProductos()">
                <div class="row">
                    <div class="col-md-3 d-flex justify-content-start align-items-end">
                        <flat-pickr
                            v-model="fecha_ini"                                                       
                            class="form-control input-style"
                            :config="config"
                            placeholder="Fecha Desde"
                        />
                        <!-- <ListErrors :errores="fecha"></ListErrors> -->
                    </div>
                    <div class="col-md-3 d-flex justify-content-start align-items-end">
                        <flat-pickr
                            v-model="fecha_fin"                                                       
                            class="form-control input-style"
                            :config="config"
                            placeholder="Fecha Hasta"
                        />
                        <!-- <ListErrors :errores="fecha"></ListErrors> -->
                    </div>
                    <div class="col-md-6 d-flex justify-content-end align-items-end">
                        <button type="submit" class="btn btn-primary mr-2">Generar</button>
                        <button type="button" class="btn btn-success mr-2" @click="getDetalleProductosExcel()">Excel</button>
                        <button type="button" class="btn btn-danger" @click="getDetalleProductosPDF()">PDF</button>
                    </div>
                </div>
            </form>
            <div class="row">
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table-component
                            :data="detalleProductosArray"
                            tableClass="table table-condensed table-bordered"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="categoria" label="Categoria"></table-column>
                            <table-column show="producto" label="Producto"></table-column>
                            <table-column show="precio_unitario" data-type="numeric" label="Precio unitario"></table-column>
                            <table-column show="cantidad_vendida" data-type="numeric" label="Cantidad vendida"></table-column>
                            <table-column show="ingreso_total" data-type="numeric" label="Ingreso total"></table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="getDetalleProductos"></Pagination>
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
import flatPickr from 'vue-flatpickr-component';
import 'flatpickr/dist/flatpickr.css';
import ListErrors from '@/components/Messages/ListErrors';
import Modal from '@/components/Modal/Modal';
export default{
    name: 'DetalleProducto',
    components: {
        Marco,
        flatPickr,
        ListErrors,
        Pagination,
        Modal
    },
    created () {
        this.$Progress.start()
        this.getDataUser(2).then(response => {
            this.data_usr = response.data;
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    data() {
        return {
            data_usr: {},
            detalleProductosArray: [],
            productosArray: [],
            pagination: {},
            nro_pedido: 0,
            ventaProductoObj: {},
            pagoObj: {},
            //fecha: new Date(),
            fecha_ini: null,
            fecha_fin: null,
            errores: {},
            totales: {},
            
            sucursalFiltro: -1,
            perfilFiltro: -1,
            clienteFiltro: -1,
            usuarioFiltro: -1,

            config: {
                wrap: true, // set wrap to true only when using 'input-group'
                altFormat: 'j/n/Y',
                altInput: true,
                dateFormat: 'Y-m-d',
                allowInput: true,
                wrap: false,
                static: true     
            },
            reg: {
                efectivo: 0,
                total_pagar: 0,
                visa: 0,
                mastercard: 0,
                sub_total: 0,
                cambio: 0,
            },

            tipo_reporte: 0,
        }
    },
    mixins: [misMixins],
    computed: {
        tipoMoneda() {
            return this.$store.state.restauranteData.tipo_moneda
        },
        getIdentificacion(){
            return this.$store.state.restauranteData.identificacion
        }
    },
    methods: {
        getDetalleProductos(url){
            this.tipo_reporte = 0; //json html
            url = url || this.$store.state.url_root+`api/auth/detalleproductos/${this.$store.state.id_restaurant}/fechaini/${this.fecha_ini}/fechafin/${this.fecha_fin}/tiporeporte/${this.tipo_reporte}`
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.detalleProductosArray = response.data.data.data;
                this.pagination = response.data.data
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("DetalleVentas.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        getDetalleProductosExcel(){
            this.tipo_reporte = 1; //excel
            let url = this.$store.state.url_root+`api/auth/detalleproductos/${this.$store.state.id_restaurant}/fechaini/${this.fecha_ini}/fechafin/${this.fecha_fin}/tiporeporte/${this.tipo_reporte}`
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data]));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `reporte_detalle_productos_${this.fecha_ini}_${this.fecha_fin}.xlsx`);
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.$Progress.finish();
            })
            .catch (error => {
                this.$toasted.show("DetalleVentas.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        getDetalleProductosPDF() {
            this.$Progress.start();
            let url = this.$store.state.url_root+`api/auth/detalleproductospdf`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            let datosPdf = {
                idRestaurante: this.$store.state.id_restaurant,
                nombre_restaurante: this.$store.state.restauranteData.restaurant,
                fecha_inicio: this.fecha_ini,
                fecha_fin: this.fecha_fin,
                sucursal: this.$store.state.restauranteData.sucursal,
                caja: this.$store.state.restauranteData.caja
            };
            axios.post(url, datosPdf, { responseType: 'blob' })
            .then(response => {
                const url = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `reporte_detalle_productos_${this.fecha_ini}_${this.fecha_fin}.pdf`);
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
<style lang="scss">
.col-center{
    text-align: center;
}
</style>