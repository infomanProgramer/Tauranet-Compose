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
                                <input type="checkbox" class="form-check-input" @click="changeStateIsForCustomer" ref="statePrint">Para Cliente
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
                                        <tr v-for="prod in listOfProductsInTheOrder" v-bind:key="prod.id_producto">
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
                                            <th scope="col">Importe total</th>
                                            <th>{{ reg.importe?parseFloat(reg.importe).toFixed(2):"" }} {{ reg.importe?tipoMoneda:"" }}</th>
                                        </tr>
                                    </thead>
                                </table>
                            </div>
                            
                            <button type="button" class="btn btn-danger" v-if="nro_pedido!=0 && type_user == 1" @click="cancelarPedidoMethod(ventaProductoObj)">Cancelar Pedido</button>

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
                                            <td scope="col" class="subtituloPedidos">Tipo de pago</td>
                                            <td class="subtituloPedidos"></td>
                                        </tr>
                                        <tr>
                                            <!-- inicio tipo de pago -->
                                                <ul class="mb-0 mt-0" style="list-style: none;">
                                                    <li class="li-horizontal">
                                                        <i class="far fa-money-bill-alt"></i>
                                                        <input class="form-check-input" type="radio" name="tipo_pago" v-model="reg.tipo_pago" id="checkEfectivo" :value=formaDePago.efectivo disabled>
                                                        <label class="form-check-label" for="checkEfectivo">
                                                            Efectivo
                                                        </label>
                                                    </li>
                                                    <li class="li-horizontal">
                                                        <i class="fas fa-qrcode"></i>
                                                        <input class="form-check-input" type="radio" name="tipo_pago" v-model="reg.tipo_pago" id="checkQR" :value=formaDePago.qr disabled>
                                                        <label class="form-check-label" for="checkQR">Pago QR</label>
                                                    </li>
                                                    <li class="li-horizontal">
                                                        <i class="fab fa-cc-visa"></i>
                                                        <input class="form-check-input" type="radio" name="tipo_pago" v-model="reg.tipo_pago" id="checkTarjeta" :value=formaDePago.tarjeta disabled>
                                                        <label class="form-check-label" for="checkTarjeta">
                                                            Tarjeta
                                                        </label>
                                                    </li>
                                                </ul>
                                                <!-- fin tipo de pago -->
                                        </tr>
                                        <tr>
                                            <td scope="col" class="subtituloPedidos">Tipo de servicio</td>
                                            <td class="subtituloPedidos"></td>
                                        </tr>
                                        <tr>
                                            <!-- inicio tipo de servicio -->
                                                <ul class="mb-0 mt-0" style="list-style: none;">
                                                    <li class="li-horizontal">
                                                        <input class="form-check-input" type="radio" name="tipo_servicio" v-model="pagoObj.tipo_servicio" id="checkMesa" :value=tipoServicio.mesa disabled>
                                                        <label class="form-check-label" for="checkMesa">
                                                            Mesa
                                                        </label>
                                                    </li>
                                                    <li class="li-horizontal">
                                                        <input class="form-check-input" type="radio" name="tipo_servicio" v-model="pagoObj.tipo_servicio" id="checkDelivery" :value=tipoServicio.delivery disabled>
                                                        <label class="form-check-label" for="checkDelivery">
                                                            Delivery
                                                        </label>
                                                    </li>
                                                    <li class="li-horizontal">
                                                        <input class="form-check-input" type="radio" name="tipo_servicio" v-model="pagoObj.tipo_servicio" id="checkTakeAway" :value=tipoServicio.take_away disabled>
                                                        <label class="form-check-label" for="checkTakeAway">
                                                            Para llevar
                                                        </label>
                                                    </li>
                                                </ul>
                                                <!-- fin tipo de servicio -->
                                        </tr>
                                        <tr v-if="reg.tipo_pago == 0">
                                            <td scope="col"><i class="far fa-money-bill-alt"></i> Efectivo</td>
                                            <td>
                                                <input type="number" class="form-control"  v-if="pagoObj != null" v-model="reg.efectivo" disabled>
                                                <input type="number" class="form-control"  v-else v-model="reg.efectivo">
                                                <ListErrors :errores="errores.efectivo"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td scope="col"><i class="fas fa-money-bill-wave"></i> Importe</td>
                                            <td>
                                                <input type="number" class="form-control" v-if="pagoObj != null" v-model="reg.importe" disabled>
                                                <input type="number" class="form-control" v-else v-model="reg.importe">
                                                <ListErrors :errores="errores.total_pagar"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr v-if="reg.tipo_pago == 0">
                                            <td scope="col"><i class="fab fa-cc-visa"></i> Cambio</td>
                                            <td>
                                                <input type="number" class="form-control" disabled v-model="reg.cambio">
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
import {renderFrameComanda, listOfProductsToString} from '@/utils/printcomandas.js';

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
        //facturaCocina
    },
    data() {
        return {
            data_usr: {},
            pedidosArray: [],
            listOfProductsInTheOrder: [],
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
            isForCustomer: false,
            formaDePago: {
                efectivo: 0,
                tarjeta: 1,
                qr: 2
            }, //0 efectivo, 1 tarjeta, 2 qr
            tipoServicio: {
                mesa: 0,
                delivery: 1,
                take_away: 2
            }, //0 mesa, 1 delivery, 2 take away
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
            this.isForCustomer = false;
            this.$Progress.start()
            this.nro_pedido = obj.nro_venta
            this.$store.dispatch('indicePedidosActiveAction', obj.id_venta_producto)
            let url = this.$store.state.url_root+`api/auth/productovendido/pedido/${obj.id_venta_producto}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.listOfProductsInTheOrder = response.data.data
                this.ventaProductoObj = response.data.vprod[0]
                this.pagoObj = response.data.vpag[0]
                console.log("Detalle de pago: ",this.pagoObj)
                if(this.pagoObj == null){
                    this.reg = {
                        efectivo: 0,
                        importe: 0,
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
                        this.isForCustomer = false
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
        cleanOrder(){
            this.pedidoMsg = '',
            this.errores = {}
            this.nro_pedido = 0;
            this.listOfProductsInTheOrder = [];
            this.ventaProductoObj = {
                total: 0,
                sub_total: 0,
                descuento: 0,
                nombre_cliente: ''
            },
            this.reg = {
                efectivo: 0,
                total_pagar: 0,
                visa: 0,
                mastercard: 0,
                sub_total: 0,
                cambio: 0,
            }
        },
        changeStateIsForCustomer(){
            if(this.$refs.statePrint.checked){
                this.isForCustomer = true
            }else{
                this.isForCustomer = false
            }
        },
        printTicket(){
            let dataForOrderTicket = {
                nombre_restaurant: this.$store.state.restauranteData.restaurant,
                sucursal: this.$store.state.restauranteData.sucursal,
                caja: this.$store.state.restauranteData.caja,
                listaProductos: listOfProductsToString(this.listOfProductsInTheOrder),
                paymentDetails: this.reg,
                nro_pedido: this.nro_pedido,
                datosCliente: this.ventaProductoObj,
                identificacion: this.getIdentificacion,
                isForCustomer: this.isForCustomer
            }
            console.log(dataForOrderTicket)
            renderFrameComanda();
             // Obtener el PDF
            const loadingToast = this.$toasted.show('Cargando comprobante...', { 
                type: 'info',
                duration: null // No se cierra automáticamente
            });

            let _dataForOrderTicket = dataForOrderTicket;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(this.$store.state.url_root + 'api/auth/printcomanda', _dataForOrderTicket, { responseType: 'blob' })
            .then(response => {
                const file = new Blob([response.data], { type: 'application/pdf' });
                const fileURL = URL.createObjectURL(file);
                const iframe = document.getElementById('pdfIframe');
                iframe.src = fileURL;
                loadingToast.goAway(0); // Cerrar mensaje de carga
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido: "+error, {type: 'error'})
            });
        },
        cancelarPedidoMethod(orderById){
            this.$Progress.start()
            let cancelFoodOrderById = confirm(`¿Desea cancelar el Pedido # ${orderById.nro_venta}?`)
            orderById.estado_venta = 1;
            if(cancelFoodOrderById){
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.post(this.$store.state.url_root+`api/auth/updateventaproducto`, orderById)
                .then(response => {
                    this.getPedidosArray();
                    this.$toasted.show(`Pedido # ${orderById.nro_venta} cancelado correctamente`, {type: 'success'})
                    this.cleanOrder();
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show(`Error al cancelar el pedido # ${orderById.nro_venta}`, {type: 'error'})
                    this.$Progress.fail()
                });
            }else{
                console.log("No se cancelo el pedido");
                this.$Progress.fail()
            }    
        }
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