<template>
    <Marco titulo="Historial de pedidos" icono="fas fa-table">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-3">
                    <h3 class="sub-cajero"><button type="button" class="btn btn-success" @click="getPedidosArray()"><i class="fas fa-sync-alt"></i></button> Pedidos</h3>
                    <input type="text" class="form-control input-style" placeholder="Buscar..." v-model="buscaPedido">
                    <div class="contenedor-pedidos">
                        <ContainerPedidos v-for="item in matchPedidos" v-bind:key="item.venta_producto" :pedidoObj="item" @sendPedidoMethod="showDatosPedido"></ContainerPedidos>
                    </div>
                </div>
                <div class="col-md-9">
                    <div class="row">
                        <div class="col-md-12 text-right margin-buttons">
                            <button class="btn btn-primary" v-if="pagoObj == null && type_user == 1" @click="hacerPagoMethod" ref="pagarPedidoBtn">Pagar</button>
                            <button class="btn btn-primary" v-if="nro_pedido!=0" @click="printTicket()"><i class="fas fa-print"></i> Imprimir</button>
                            <div class="form-check">
                            <label class="form-check-label" v-if="!(pagoObj == null) && (nro_pedido!=0) && (type_user == 1)">
                                <input type="checkbox" class="form-check-input" @click="chengeStatePrint" ref="statePrint">Ticket Cliente
                            </label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-6">
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
                                            <th scope="col">Sub total</th>
                                            <th>{{parseFloat(ventaProductoObj.sub_total).toFixed(2)}} {{tipoMoneda}}</th>
                                        </tr>
                                        <tr>
                                            <th scope="col">Descuento</th>
                                            <th>{{parseFloat(ventaProductoObj.descuento).toFixed(2)}} %</th>
                                        </tr>
                                        <tr>
                                            <th scope="col">Total</th>
                                            <th>{{parseFloat(ventaProductoObj.total).toFixed(2)}} {{tipoMoneda}}</th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <h5 class="sub-cajero">Cliente</h5>
                            <BoxMessage :message="pedidoMsg" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                            <div class="table-responsive">
                                <table class="table table-bordered table-striped table-condensed">
                                    <tbody>
                                        <tr>
                                            <td scope="col">Señor(es)</td>
                                            <td>{{ventaProductoObj.nombre_completo}}</td>
                                        </tr>
                                        <tr>
                                            <td scope="col">{{getIdentificacion}}</td>
                                            <td>{{ventaProductoObj.dni}}</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            <div class="table-responsive" v-if="type_user == 1">
                                <!-- Modulo de pagos -->
                                <table class="table table-bordered table-striped table-condensed">
                                    <tbody>
                                        <tr>
                                            <td scope="col" class="subtituloPedidos">TOTAL</td>
                                            <td class="subtituloPedidos">{{parseFloat(ventaProductoObj.total).toFixed(2)}} {{tipoMoneda}}</td>
                                        </tr>
                                        <tr>
                                            <td scope="col"><i class="far fa-money-bill-alt"></i> Efectivo</td>
                                            <td>
                                                <input type="number" class="form-control"  v-if="pagoObj != null" v-model="reg.efectivo" disabled>
                                                <input type="number" class="form-control"  v-else v-model="reg.efectivo">
                                                <ListErrors :errores="errores.efectivo"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td scope="col"><i class="fas fa-money-bill-wave"></i> Total pagar</td>
                                            <td>
                                                <input type="number" class="form-control" v-if="pagoObj != null" v-model="reg.total_pagar" disabled>
                                                <input type="number" class="form-control" v-else v-model="reg.total_pagar">
                                                <ListErrors :errores="errores.total_pagar"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td scope="col"><i class="fab fa-cc-visa"></i> Visa</td>
                                            <td>
                                                <input type="number" class="form-control" disabled v-model="reg.visa">
                                                <ListErrors :errores="errores.visa"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td scope="col"><i class="fab fa-cc-mastercard"></i> Master Card</td>
                                            <td>
                                                <input type="number" class="form-control" disabled v-model="reg.mastercard">
                                                <ListErrors :errores="errores.mastercard"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td scope="col"><i class="fas fa-hand-holding-usd"></i> Cambio</td>
                                            <td>
                                                <input type="number" class="form-control" v-if="pagoObj != null" disabled v-model="reg.cambio">
                                                <input type="number" class="form-control" v-else disabled :value="calculaCambio">
                                                <ListErrors :errores="errores.cambio"></ListErrors>    
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div> 
                        </div>
                    </div>
                </div>
            </div>
            <facturaCocina :nro_pedido="nro_pedido" :cliente="ventaProductoObj" :productosArray="productosArray" :esFactura="esFactura" :detallePago="reg"></facturaCocina>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import Pagination from '@/components/Pagination/Pagination';
import Modal from '@/components/Modal/Modal';
import BoxMessage from '@/components/Messages/BoxMessage';
import ListErrors from '@/components/Messages/ListErrors';
import ContainerPedidos from '@/components/Cajero/ContainerPedidos';
import {misMixins} from '@/mixins/misMixins.js';
import flatPickr from 'vue-flatpickr-component';
import 'flatpickr/dist/flatpickr.css';
import {Hindi} from 'flatpickr/dist/l10n/hi';
import facturaCocina from '@/components/Invoices/facturaCocina';
export default{
    name: 'HistorialPedidos',
    components: {
        Marco,
        BoxMessage,
        Modal,
        flatPickr,
        ListErrors,
        Pagination,
        ContainerPedidos,
        facturaCocina
    },
    data() {
        return {
            data_usr: {},
            pedidosArray: [],
            productosArray: [],
            ventaProductoObj: {
                total: 0,
                sub_total: 0,
                descuento: 0,
                nombre_cliente: ''
            },
            pagoObj: {},
            nro_pedido: 0,
            reg: {
                efectivo: 0,
                total_pagar: 0,
                visa: 0,
                mastercard: 0,
                sub_total: 0,
                cambio: 0,
            },
            buscaPedido: '',
            errores: {},
            pedidoMsg: '',
            sw: false,
            type_user: this.$store.state.type_user,
            esFactura: false
        }
    },
    mixins: [misMixins],
    computed: {
        calculaCambio() {
            return parseFloat(this.reg.efectivo-this.reg.total_pagar).toFixed(2)
        },
        matchPedidos: function() {
            return this.pedidosArray.filter(pedido=>{
                let b = this.buscaPedido.trim().toUpperCase()
                //let a = pedido.dni_cliente.toUpperCase()
                let c = pedido.nombre_completo
                if(c == null){
                    c = ''
                }
                let e = c.toUpperCase()
                let i = pedido.id_venta_producto.toString()
                return e.match(b) || i.match(b);
            });
        },
        tipoMoneda() {
            return this.$store.state.restauranteData.tipo_moneda
        },
        getIdentificacion(){
            return this.$store.state.restauranteData.identificacion
        }
    },
    created () {
        this.$Progress.start()
            this.getDataUser(this.type_user).then(response => {
            this.data_usr = response.data;
            this.getPedidosArray();
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    methods: {
        getPedidosArray(){
            this.$Progress.start()
            let url = ''
            if(this.type_user == 0){//mozo
                url = this.$store.state.url_root+`api/auth/ventaproductos/mozo/${this.data_usr.id_mozo}/sucursal/${this.data_usr.id_sucursal}`
            }else{
                url = this.$store.state.url_root+`api/auth/ventaproductos/caja/${this.data_usr.id_caja}`
            }
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.pedidosArray = response.data.data
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("HistorialPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        showDatosPedido(obj){
            if(this.$refs.statePrint != null){
                this.$refs.statePrint.checked = false;
            }
            this.esFactura = false;
            this.$Progress.start()
            this.nro_pedido = obj.nro_venta
            this.$store.dispatch('indicePedidosActiveAction', obj.id_venta_producto)
            let url = this.$store.state.url_root+`api/auth/productovendido/pedido/${obj.id_venta_producto}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.productosArray = response.data.data
                this.ventaProductoObj = response.data.vprod[0]
                this.pagoObj = response.data.vpag[0]
                if(this.pagoObj == null){
                    this.reg = {
                        efectivo: 0,
                        total_pagar: 0,
                        visa: 0,
                        mastercard: 0,
                        sub_total: 0,
                        cambio: 0,
                    }
                }else{
                    this.reg = this.pagoObj
                }
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("HistorialPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        hacerPagoMethod(){
            if(this.pagoObj == null){
                this.$refs.pagarPedidoBtn.className = "btn btn-primary disabled"
                this.$Progress.start()
                this.reg.total = parseFloat(this.ventaProductoObj.total).toFixed(2)
                this.reg.id_venta_producto = this.ventaProductoObj.id_venta_producto
                this.reg.cambio = parseFloat(this.reg.efectivo-this.reg.total_pagar).toFixed(2)
                this.reg.id_cajero = this.data_usr.id_cajero;
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.post(this.$store.state.url_root+`api/auth/pago`, this.reg)
                .then(response => {
                    if(response.data.error == null){
                        this.esFactura = false
                        this.pagoObj = response.data.data
                        this.reg = response.data.data
                        this.getPedidosArray();
                        this.limpiarPedido();
                        this.$Progress.finish()
                        this.$refs.pagarPedidoBtn.className = "btn btn-primary"
                    }else{
                        if(response.data.error.efectivo_mayor == null){//aumentar validacion cuando la caja este cerrada 
                            if(response.data.error.total_pagar_mayor == null){
                                this.errores = response.data.error;
                            }else{
                                this.pedidoMsg = `${response.data.error.total_pagar_mayor}`
                            }
                        }else{
                            this.pedidoMsg = `${response.data.error.efectivo_mayor}`   
                        }
                        this.$Progress.fail()
                        this.$refs.pagarPedidoBtn.className = "btn btn-primary"
                    }
                })
                .catch(error => {
                    this.$toasted.show("Historial Pedidos.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.pagarPedidoBtn.className = "btn btn-primary"
                })
            }
        },
        limpiarPedido(){
            this.pedidoMsg = '',
            this.errores = {}
        },
        printTicket(){
            window.print()
        },
        chengeStatePrint(){
            if(this.$refs.statePrint.checked){
                this.esFactura = true
            }else{
                this.esFactura = false
            }
        },
    },
}
</script>
<style lang="scss">
    .subtituloPedidos{
        font-weight: bold;
    }
    .margin-buttons{
        margin-bottom: 10px;
        button{
            margin: 0px 0px 3px 3px;
        }
    }
    .style-titulo-pedido{
        background: greenyellow;
        //opacity: 0.5;
        color: black;
    }
    .contenedor-pedidos{
        max-height: 35rem;
        border: 1px solid #a5a4a4;
        overflow: auto;
        padding: 3px;
        margin-top: 4px;
    }
</style>