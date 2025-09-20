<template>
    <Marco titulo="Detalle Ventas" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <form @submit.prevent="getDetalleVentas()">
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
                        <button type="button" class="btn btn-success mr-2" @click="getDetalleVentasExcel()">Excel</button>
                        <button type="button" class="btn btn-danger" @click="getDetalleVentasPDF()">PDF</button>
                    </div>
                </div>
            </form>
            <div class="row">
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table-component
                            :data="detalleVentasArray"
                            tableClass="table table-condensed table-bordered"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombreSucursal" label="Sucursal"></table-column>
                            <table-column show="fecha" label="Fecha"></table-column>
                            <table-column show="nro_venta" data-type="numeric" label="Nro"></table-column>
                            <table-column show="nombre_completo" label="Cliente"></table-column>
                            <table-column show="nombre_usuario" label="Atendido por:"></table-column>
                            <table-column show="tipo_pago" label="Tipo Pago" :sortable="false"></table-column>
                            <table-column show="tipo_servicio" label="Tipo Servicio" :sortable="false"></table-column>
                            <table-column show="importe" label="Importe Total" :sortable="false"></table-column>
                            <table-column label="Ver" :sortable="false" :filterable="false" cell-class="col-center">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalDetallePedido" @click="showDatosPedido(row)"><i class="fas fa-eye"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="getDetalleVentas"></Pagination>
                </div>
            </div>
            <!-- VentanasModales -->
            <div class="row">
                <Modal titulo="Detalle Pedido" idModal="modalDetallePedido" icono="fas fa-clipboard">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <div class="col-md-12">
                                    <h5 class="sub-cajero">Detalle <span class="style-titulo-pedido" v-if="nro_pedido!=0">PEDIDO # {{nro_pedido}}</span></h5>
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-condensed">
                                            <thead class="head-table">
                                                <tr>
                                                    <th scope="col">Cod</th>
                                                    <th scope="col">Cant</th>
                                                    <th scope="col">Detalle</th>
                                                    <th scope="col">P.Unit</th>
                                                    <th scope="col">Importe</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr v-for="prod in productosArray" v-bind:key="prod.id_producto">
                                                    <td>{{prod.id_producto}}</td>
                                                    <td>{{prod.cantidad}}</td>
                                                    <td>{{prod.detalle}}</td>
                                                    <td>{{parseFloat(prod.p_unit).toFixed(2)}}</td>
                                                    <td>{{parseFloat(prod.importe).toFixed(2)}}</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-condensed">
                                            <thead class="head-table">
                                                <tr>
                                                    <th scope="col">Importe Total</th>
                                                    <th>{{parseFloat(pagoObj.importe).toFixed(2)}} {{tipoMoneda}}</th>
                                                </tr>
                                            </thead>
                                        </table>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <!-- Datos Cliente -->
                                    <h5 class="sub-cajero">Cliente</h5>
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-striped table-condensed">
                                            <tbody>
                                                <tr>
                                                    <td scope="col">Señor(es)</td>
                                                    <td v-if="ventaProductoObj.nombre_completo!=null">{{ventaProductoObj.nombre_completo}}</td>
                                                    <td v-else>GENERAL</td>
                                                </tr>
                                                <tr>
                                                    <td scope="col">{{getIdentificacion}}</td>
                                                    <td v-if="ventaProductoObj.dni!=null">{{ventaProductoObj.dni}}</td>
                                                    <td v-else>GENERAL</td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div> 
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiarPedidoDetalles">Cerrar</button>
                    </template>
                </Modal>
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
    name: 'DetalleVentas',
    components: {
        Marco,
        flatPickr,
        ListErrors,
        Pagination,
        Modal
    },
    created () {
        this.$Progress.start()
        this.listaSucursalesMethod()
        this.getDataUser(2).then(response => {
            this.data_usr = response.data;
            this.getListaClientes()
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    data() {
        return {
            data_usr: {},
            detalleVentasArray: [],
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

            listaSucursales: [],
            ListaClientes: [],
            ListaUsuarios: [],

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
        listaSucursalesMethod(){
            //this.$Progress.start() comentado a proposito
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/sucursalcombo/${this.$store.state.id_restaurant}`)
            .then(response => {
                this.listaSucursales = response.data.data;
                //this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("DetalleVentas.vue: "+error, {type: 'error'})
                //this.$Progress.fail()
            });
        },
        getListaClientes(){
            this.$Progress.start()
            //let url = this.$store.state.url_root+`api/auth/cliente/restaurant/${this.data_usr.id_restaurant}`
            let url = this.$store.state.url_root+`api/auth/cliente/restaurant/${this.$store.state.id_restaurant}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.ListaClientes = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        getDetalleVentas(url){
            this.tipo_reporte = 0; //json html
            url = url || this.$store.state.url_root+`api/auth/detalleventas/${this.$store.state.id_restaurant}/fechaini/${this.fecha_ini}/fechafin/${this.fecha_fin}/tiporeporte/${this.tipo_reporte}`
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.detalleVentasArray = response.data.data.data;
                this.pagination = response.data.data
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("DetalleVentas.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        getDetalleVentasExcel(){
            this.tipo_reporte = 2; //excel
            let url = this.$store.state.url_root+`api/auth/detalleventasexcel/${this.$store.state.id_restaurant}/fechaini/${this.fecha_ini}/fechafin/${this.fecha_fin}/tiporeporte/${this.tipo_reporte}`
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url, { responseType: 'blob' })
            .then(response => {
                console.log(response.data);
                const url = window.URL.createObjectURL(new Blob([response.data]));
                const link = document.createElement('a');
                link.href = url;
                link.setAttribute('download', `reporte_detalle_ventas_${this.fecha_ini}_${this.fecha_fin}.xlsx`);
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
        getDetalleVentasPDF() {
            this.tipo_reporte = 1; //pdf
            this.$Progress.start();
            let url = this.$store.state.url_root+`api/auth/detalleventaspdf`
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
                link.setAttribute('download', `reporte_detalle_ventas_${this.fecha_ini}_${this.fecha_fin}.pdf`);
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
        showDatosPedido(obj){
            this.$Progress.start()
            this.nro_pedido = obj.nro_venta
            let url = this.$store.state.url_root+`api/auth/productovendido/pedido/${obj.id_venta_producto}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.productosArray = response.data.data
                this.ventaProductoObj = response.data.vprod[0]
                this.pagoObj = response.data.vpag[0]
                if(this.pagoObj == null){
                    this.reg = {}
                }else{
                    this.reg = this.pagoObj
                }
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("DetallePedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        limpiarPedidoDetalles(){
            this.productosArray = []
            this.ventaProductoObj = {}
            this.reg = {}
        }
    },
}
</script>
<style lang="scss">
.col-center{
    text-align: center;
}
</style>