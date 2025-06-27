<template>
    <Marco titulo="Nuevo Pedido" icono="fas fa-clipboard">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-8">
                    <div class="row">
                        <div class="col-md-9 alineacion-botones">
                            <button class="btn btn-primary" ref="btnNuevoCliente" @click="addNewClient()"><i class="far fa-save"></i> Ciente Nuevo</button>
                            <button class="btn btn-primary" @click="limpiarPedido()"><i class="fas fa-broom"></i> Limpiar</button>
                            <button class="btn btn-primary" @click="printTicket()" :class="{disabled: ventaProdObj==null}"><i class="fas fa-print"></i> Imprimir</button>
                        </div>
                        <div class="col-md-3">
                            <div class="form-check" v-if="btnClientePrint">
                            <label class="form-check-label">
                                <input type="checkbox" class="form-check-input" @click="chengeStatePrint" ref="statePrint">Ticket Cliente
                            </label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <BoxMessage :message="nuevoPedidoMsg" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                            <h4 class="sub-cajero">Datos Cliente</h4>
                            <div class="row">
                                <div class="col-md-2 style-datos-cliente align-self-center">
                                    <label for="validationCustom04">Nombre</label>
                                </div>
                                <div class="col-md-10">
                                    <input v-if="isNewCustomer" type="text" class="caja_texto" v-model="cliente.nombre_completo" >
                                    <input
                                        type="text"
                                        class="caja_texto"
                                        v-model="cliente.nombre_completo"
                                        v-else
                                        disabled
                                        style="background-color: #f5f5f5; color: #888; cursor: not-allowed; opacity: 1;"
                                    >
                                    
                                    <ListErrors :errores="errores.nombre_completo"></ListErrors>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-2 style-datos-cliente align-self-center">
                                    <label for="validationCustom04">{{getIdentificacion}}</label>
                                </div>
                                <div class="col-md-10">
                                    <form @submit.prevent="getListaClientes()">
                                    <div class="enlinea caja_texto">                                        
                                        <!-- <input type="number" v-model="cliente.dni" v-if="isNewCustomer" disabled> -->
                                        <input type="number" v-model="cliente.dni">
                                        <button type="submit" class="btn" data-toggle="modal" data-target="#modalListaClientes" v-if="!isNewCustomer"><i class="fas fa-search"></i></button>
                                    </div>
                                    <ListErrors :errores="errores.dni"></ListErrors>
                                    </form>
                                    <a href="#" class="style-limpiar" @click="habilitaCamposCliente()">Limpiar</a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row caja-style" v-if="type_user == 0">
                        <div class="col-md-12">
                            <!-- <h4 class="sub-cajero">Seleccionar Caja</h4> -->
                            <div class="form-check" v-for="item in cajasArray" v-bind:key="item.id_caja">
                                <input class="form-check-input" type="radio" name="exampleRadios" id="exampleRadios1" v-model="cajaCheck" :value="item.id_caja">
                                <label class="form-check-label" for="exampleRadios1">
                                    {{item.nombre}}
                                </label>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12">
                            <h4 class="sub-cajero">Detalles</h4>
                            <TableCondensed 
                                :productosPedidos="tablaProductosPedidos"
                                :rotulos="rotulosProductosPedidos"
                                v-on:addNota="addNotaMethod"
                                v-on:addCant="addCantMethod"
                                v-on:delCant="delCantMethod">
                            </TableCondensed>
                            <ListErrors :errores="errores.listaProductos"></ListErrors>
                            <div class="table-responsive">
                                <table class="table table-bordered table-condensed">
                                    <tbody>
                                        <tr>
                                            <th scope="row">Importe total</th>
                                            <td>{{calculaImporte}} {{tipoMoneda}}</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                    <div class="row" v-if="type_user==1">
                        <div class="col-md-12 alineacion-botones">
                            <button class="btn btn-primary" @click="addNuevoPedidoPago()" ref="pagarPedidoBtn"><i class="fas fa-comment-dollar"></i> Pagar</button>
                        </div>
                    </div>
                    <div class="row" v-if="type_user==1">
                        <div class="col-md-12">
                            <!-- Modulo de pagos -->
                            <BoxMessage :message="pedidoMsg" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                            <div class="table-responsive">
                                <table class="table table-bordered table-striped table-condensed">
                                    <tbody>
                                        <tr>
                                            <td scope="col">Seleccione el método de pago</td>
                                            <td>
                                                <ul class="mb-0 mt-0" style="list-style: none;">
                                                    <li class="li-horizontal">
                                                        <i class="far fa-money-bill-alt"></i>
                                                        <input class="form-check-input" type="radio" name="tipo_pago" v-model="reg.tipo_pago" id="checkEfectivo" :value=formaDePago.efectivo>
                                                        <label class="form-check-label" for="checkEfectivo">
                                                            Efectivo
                                                        </label>
                                                    </li>
                                                    <li class="li-horizontal">
                                                        <i class="fas fa-qrcode"></i>
                                                        <input class="form-check-input" type="radio" name="tipo_pago" v-model="reg.tipo_pago" id="checkQR" :value="formaDePago.qr">
                                                        <label class="form-check-label" for="checkQR">Pago QR</label>
                                                    </li>
                                                    <li class="li-horizontal">
                                                        <i class="fab fa-cc-visa"></i>
                                                        <input class="form-check-input" type="radio" name="tipo_pago" v-model="reg.tipo_pago" id="checkTarjeta" :value=formaDePago.tarjeta>
                                                        <label class="form-check-label" for="checkTarjeta">
                                                            Tarjeta
                                                        </label>
                                                    </li>
                                                </ul>
                                                <ListErrors :errores="errores.tipo_pago"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr v-if="reg.tipo_pago == 0">
                                            <td scope="col"><i class="far fa-money-bill-alt"></i> Monto entregado por el cliente ({{tipoMoneda}})</td>
                                            <td>
                                                <input type="number" class="form-control" v-model="reg.efectivo">
                                                <ListErrors :errores="errores.efectivo"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td scope="col"><i class="fas fa-money-bill-wave"></i> Importe ({{tipoMoneda}})</td>
                                            <td>
                                                <div style="display: flex; align-items: center; gap: 0.5rem;">
                                                    <input
                                                        v-if="!editarImporte"
                                                        type="number"
                                                        class="form-control"
                                                        v-model="calculaImporte"
                                                        style="margin-bottom: 0;"
                                                        disabled
                                                    />
                                                    <input
                                                        v-if="editarImporte"
                                                        type="number"
                                                        class="form-control"
                                                        v-model="reg.importeRecalculado"
                                                        style="margin-bottom: 0;"
                                                    />
                                                    <button
                                                        v-if="!editarImporte"
                                                        class="btn btn-primary"
                                                        @click="editImporteField"
                                                        ref="editarBtn"
                                                    >Editar</button>
                                                    <button
                                                        v-if="editarImporte"
                                                        class="btn btn-primary"
                                                        @click="recalcularImporte"
                                                        ref="recalcularBtn"
                                                    >Recalcular</button>
                                                </div>
                                                <ListErrors :errores="errores.importe"></ListErrors>
                                            </td>
                                        </tr>
                                        <tr v-if="reg.tipo_pago == 0">
                                            <td scope="col"><i class="fas fa-hand-holding-usd"></i> Cambio ({{tipoMoneda}})</td>
                                            <td>
                                                <input type="number" class="form-control" disabled :value="calculaCambio">
                                                <ListErrors :errores="errores.cambio"></ListErrors>    
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div> 
                        </div>
                    </div>    
                </div>
                <div class="col-md-4">
                    <div class="row"><h4 class="sub-cajero">Categoria</h4></div>
                    <div class="row contenedor-categorias">
                        <div class="item-categoria" :class="{itemCategoriaActive: indiceActive==-1}" @click="getAllProductosMethod(-1)">Todos</div>
                        <div class="item-categoria" :class="{itemCategoriaActive: item.id_categoria_producto==indiceActive}" v-for="item in listaCategorias" v-bind:key="item.id_categoria_producto" @click="getAllProductosMethod(item.id_categoria_producto)">{{item.nombre}}</div>
                    </div>
                    <div class="row">
                        <h4 class="sub-cajero">Productos</h4>
                    </div>
                    <div class="row">
                        <input type="text" class="form-control input-style" placeholder="Buscar..." v-model="buscaProducto">    
                    </div>
                    <div class="row contenedor-productos">
                        <div class="item-producto" v-for="item in matchProductos" v-bind:key="item.id_producto" @click="agregaProductoMethod(item)">
                            <div>
                                <img v-if="item.producto_image != null" :src="ruta_publica+'imgProductos/'+item.producto_image" class="img-fluid" alt="No se encontro la imagen" width="120" height="120">
                                <img v-else :src="ruta_publica+'imgLogos/sinImagen.svg'" class="img-fluid" alt="No se encontro la imagen" width="120" height="120">
                            </div>
                            <div>
                                <span class="nombre_producto">{{item.nombre.toUpperCase()}}</span>
                            </div>
                            <div>
                                <span class="precio_producto">{{parseFloat(item.precio)}} {{tipoMoneda}}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Ventanas Modales -->
            <!-- Añade notas -->
            <form @submit.prevent="addNotaSubmit()">
                <Modal titulo="Insertar Nota" idModal="modalEditaNota" :icono="'fas fa-sticky-note'">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">Nota</label>
                                        <input type="text" class="form-control input-style" v-model="nota">
                                        <ListErrors :errores="errores.nota_submit"></ListErrors>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="cerrarNota">Cerrar</button>
                        <button type="submit" class="btn btn-primary">Guardar</button>
                    </template>
                </Modal>
            </form>
            <!-- Lista de clientes -->
            <form  @submit.prevent="'#'">
                <Modal titulo="Lista de Clientes" idModal="modalListaClientes" :icono="'fas fa-list'">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="table-responsive">
                                        <table class="table table-bordered table-condensed">
                                            <thead class="head-table">
                                                <tr>
                                                    <th>{{getIdentificacion}}</th>
                                                    <th>Nombre Completo</th>
                                                    <th>Añadir</th>  
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr v-for="l in listaClientes" v-bind:key="l.id_cliente">
                                                    <td>{{l.dni}}</td>
                                                    <td>{{l.nombre_completo}}</td>
                                                    <td class="botonTablaProducto">
                                                        <button class="btn btn-success" @click="addClienteMethod(l)"><i class="fas fa-plus"></i></button>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiarListaClientes">Cerrar</button>
                    </template>
                </Modal>
            </form>

            <!-- Modal Factura -->
             <facturaCocina :nro_pedido="nroPedido_ticket" :cliente="cliente_ticket" :productosArray="productosArray_ticket" :esFactura="esFactura" :detallePago="detallePago"></facturaCocina>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import facturaCocina from '@/components/Invoices/facturaCocina';
import Modal from '@/components/Modal/Modal';
import BoxMessage from '@/components/Messages/BoxMessage';
import ListErrors from '@/components/Messages/ListErrors';
import {misMixins} from '@/mixins/misMixins.js';
import TableCondensed from '@/components/Table/TableCondensed';
import * as jsPDF from 'jspdf';
export default{
    name: 'NuevoPedido',
    components: {
        Marco,
        BoxMessage,
        TableCondensed,
        Modal,
        ListErrors,
        facturaCocina
    },
    data() {
        return {
            rotulosProductosPedidos: [
                {name: 'Cod', visible: true},
                {name: 'Cant', visible: true},
                {name: 'Detalle', visible: true},
                {name: 'P.Unit', visible: true},
                {name: 'Importe', visible: true},
                {name: 'Nota', visible: true},
                {name: 'Opera', visible: true}
            ],
            buscaProducto: '',
            listaCategorias: [],
            listaProductos: [],
            data_usr: {},
            ruta_publica: this.$store.state.url_root,
            indiceActive: -1,
            tablaProductosPedidos: [],
            indiceTPP: -1,
            nota: '',
            pedidoObj: {},
            subTotal: 0,
            listaClientes: [],
            // cliente: {
            //     nombre_completo: '',
            //     dni: ''
            // },
            formaDePago: {
                efectivo: 0,
                tarjeta: 1,
                qr: 2
            }, //0 efectivo, 1 tarjeta, 2 qr
            cliente: {},
            cliente_ticket: {
                nombre_completo: '',
                dni: ''
            },
            nroPedido_ticket: -1,
            productosArray_ticket: [],
            isNewCustomer: false,
            errores: {},
            nuevoPedidoMsg: '',
            reg: {
                efectivo: 0,
                importe: 0,
                importeRecalculado: 0,
                pago_qr: 0,
                tarjeta: 0,
                cambio: 0,
                tipo_pago: 0, //0 efectivo, 1 tarjeta, 2 qr
            },
            pedidoMsg: '',
            type_user: this.$store.state.type_user,
            cajasArray: [],
            cajaCheck: -1,
            notaVerified: '',
            ventaProdObj: null,
            mostrarFactura: true,
            esFactura: false,
            detallePago: {},
            btnClientePrint: false,
            editarImporte: false,
        }
    },
    computed: {
        matchProductos: function() {
            return this.listaProductos.filter(prod=>{
                let a = prod.nombre.trim().toUpperCase()
                let b = this.buscaProducto.toUpperCase()
                return a.match(b);
            });
        },
        calculaImporte: function(){
            let suma = 0
            if(this.tablaProductosPedidos.length>0){
                this.tablaProductosPedidos.forEach(element => {
                    suma = Number(suma) + Number(element.importe)
                });
            }
            // this.reg.importe = parseFloat(suma).toFixed(2)
            // this.reg.importe = this.reg.importe || 0
            return parseFloat(suma).toFixed(2)
        },
        //eliminacion de funcion calculaTotal
        calculaCambio: function() {
            //return parseFloat(this.reg.efectivo-this.reg.importe).toFixed(2)
            if(!this.editarImporte){
                console.log("No se edito el importe ");
                return parseFloat(this.reg.efectivo-this.calculaImporte).toFixed(2)
            }
            else{
                console.log("Se edito el importe");
                return parseFloat(this.reg.efectivo-this.reg.importeRecalculado).toFixed(2)
            }
                
        },
        tipoMoneda() {
            return this.$store.state.restauranteData.tipo_moneda
        },
        getIdentificacion(){
            return this.$store.state.restauranteData.identificacion
        }
    },
    mixins: [misMixins],
    created () {
        this.$Progress.start()
        this.getDataUser(this.$store.state.type_user).then(response => {
            this.data_usr = response.data;
            this.getAllCategoriasMethod();
            this.getAllProductosMethod(-1);
            if(this.$store.state.type_user == 0){
                this.loadCajaPerSucursal();
            }
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show('NuevoPedido '+error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    methods: {
        loadCajaPerSucursal(){
            this.$Progress.start()
            let url = this.$store.state.url_root+`api/auth/allcajas/${this.data_usr.id_sucursal}`//Corregir
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.cajasArray = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        getAllCategoriasMethod() {
            this.$Progress.start()
            let url = this.$store.state.url_root+`api/auth/cproducto/sucursal/${this.data_usr.id_sucursal}`//Corregir
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaCategorias = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        getAllProductosMethod(idCategoria) {
            this.$Progress.start()
            this.indiceActive = idCategoria
            idCategoria = idCategoria || -1
            let url = this.$store.state.url_root+`api/auth/productoall/sucursal/${this.data_usr.id_sucursal}/categoria/${idCategoria}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaProductos = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        agregaProductoMethod(item){
            //Verifica si el elemento existe en la tabla
            let sw = false
            let indice = -1;
            let i = 0;
            let cant_prod = 1;
            let nota = '';
            this.tablaProductosPedidos.forEach(element => {
                if(item.id_producto==element.id_producto){
                    sw = true
                    indice = i
                    cant_prod = element.cantidad+1
                    nota = element.nota
                }
                i++
            });
            if(sw){
                this.tablaProductosPedidos.splice(indice, 1, {id_producto: item.id_producto, cantidad: cant_prod, detalle: item.nombre, p_unit: parseFloat(item.precio), importe: parseFloat(item.precio*cant_prod).toFixed(2) ,nota: nota})
            }else{//nuveo pedido
                this.tablaProductosPedidos.push({id_producto: item.id_producto, cantidad: cant_prod, detalle: item.nombre, p_unit: parseFloat(item.precio), importe: parseFloat(item.precio*cant_prod).toFixed(2) ,nota: ''})
            }
        },
        cerrarNota(){
            this.nota = ''
            this.pedidoObj = {}
            this.errores = {}
        },
        addNotaMethod(x){
            this.pedidoObj = x
            this.nota = this.pedidoObj.nota
            window.$('#modalEditaNota').modal('show')
        },
        addNotaSubmit(){
            let msgError = ""
            let swMsg = true
            if(this.nota.includes('|')){
                swMsg = false;
                msgError = "La nota no puede contener el caracter |"    
            }
            if(this.nota.includes(':')){
                swMsg = false;
                msgError = "La nota no puede contener el caracter :"    
            }
            if(swMsg){
                let sw = false
                let indice = -1;
                let i = 0;
                let cant_prod = 1;
                this.pedidoObj.nota = this.nota;
                this.tablaProductosPedidos.forEach(element => {
                    if(this.pedidoObj.id_producto==element.id_producto){
                        sw = true
                        indice = i
                    }
                    i++
                });
                if(sw){
                    this.tablaProductosPedidos.splice(indice, 1, this.pedidoObj)
                    window.$("#modalEditaNota").modal('hide');
                    this.cerrarNota();
                }
                this.errores = {}
            }else{
                this.errores = {nota_submit: [msgError]}
            }
        },
        addCantMethod(x){
            this.pedidoObj = x
            let sw = false
            let indice = -1;
            let i = 0;
            let cant_prod = 1;
            this.pedidoObj.cantidad = this.pedidoObj.cantidad+1
            this.pedidoObj.importe = parseFloat(this.pedidoObj.cantidad*this.pedidoObj.p_unit).toFixed(2)
            this.tablaProductosPedidos.forEach(element => {
                if(this.pedidoObj.id_producto==element.id_producto){
                    sw = true
                    indice = i
                }
                i++
            });
            if(sw){
                this.tablaProductosPedidos.splice(indice, 1, this.pedidoObj)
                window.$("#modalEditaNota").modal('hide');
                this.cerrarNota();
            }
        },
        delCantMethod(x){
            this.pedidoObj = x
            let sw = false
            let indice = -1;
            let i = 0;
            let cant_prod = 1;
            this.tablaProductosPedidos.forEach(element => {
                if(this.pedidoObj.id_producto==element.id_producto){
                    sw = true
                    indice = i
                }
                i++
            });
            this.pedidoObj.cantidad = this.pedidoObj.cantidad-1;
            this.pedidoObj.importe = parseFloat(this.pedidoObj.importe-this.pedidoObj.p_unit).toFixed(2);
            if(sw){
                if(this.pedidoObj.cantidad == 0){
                    //eliminar item
                    this.tablaProductosPedidos.splice(indice, 1)
                    window.$("#modalEditaNota").modal('hide');
                    this.cerrarNota();
                }
                else{
                    this.tablaProductosPedidos.splice(indice, 1, this.pedidoObj)
                    window.$("#modalEditaNota").modal('hide');
                    this.cerrarNota();
                }
            }
        },
        getListaClientes(){
            this.$Progress.start()
            let dni = this.cliente.dni || -1
            let url = this.$store.state.url_root+`api/auth/cliente/sucursal/${this.data_usr.id_sucursal}/identificador/${dni}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaClientes = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        limpiarListaClientes(){
            this.listaClientes = [];
        },
        addClienteMethod(objCliente){
            this.cliente.id_cliente = objCliente.id_cliente
            this.cliente.dni = objCliente.dni
            this.cliente.nombre_completo = objCliente.nombre_completo
            //this.isNewCustomer = true
            this.listaClientes = [];
            window.$("#modalListaClientes").modal('hide');
        },
        limpiarPedido(){
            this.tablaProductosPedidos = [];
            this.cliente = {};
            this.isNewCustomer = false;
            this.errores = {};
            this.pedidoMsg = '';
            this.reg = {
                        efectivo: 0, //Monto entregado por el cliente
                        importe: 0, //El monto que debe pagar el cliente
                        importeRecalculado: null, //El monto que debe pagar el cliente
                        tipo_pago: 0, //0 efectivo, 1 tarjeta, 2 qr
                        cambio: 0,
                    }
            this.nuevoPedidoMsg = '';
            this.cajaCheck = -1;
            this.editarImporte = false;
        },
        habilitaCamposCliente(){
            this.isNewCustomer = false;
            this.cliente = {};
        },
        editImporteField(){
            this.editarImporte = true;
            this.reg.importeRecalculado = this.calculaImporte;
        },
        addNewClient(){
            this.isNewCustomer = true;
            if(this.isNewCustomer)
                this.cliente = {}
            // this.cliente = {
            //     nombre_completo: '',
            //     dni: ''
            // }
            // this.errores = {};
            // this.nuevoPedidoMsg = '';
        },
        changeNewCustomerStatus(){
            this.isNewCustomer = true;
        },
        addNuevoPedidoPago(){
            //Guardar datos cliente
            this.$refs.pagarPedidoBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.cliente.id_cajero = this.data_usr.id_cajero //verficar si es cajero o mozo
            this.cliente.id_sucursal = this.data_usr.id_sucursal
            this.cliente.importe = !this.editarImporte? this.calculaImporte:this.reg.importeRecalculado
            this.cliente.estado_venta = 'P'
            this.cliente.id_caja = this.data_usr.id_caja
            this.cliente.isNewCustomer = this.isNewCustomer //true antiguo cliente
            this.cliente.efectivo = this.reg.tipo_pago == 0 ? this.reg.efectivo : null
            this.cliente.tipo_pago = this.reg.tipo_pago
            //this.cliente.importe = this.reg.importe
            this.cliente.id_sucursal = this.data_usr.id_sucursal
            this.cliente.cambio = this.reg.tipo_pago == 0 ? this.calculaCambio : null
            this.cliente.id_restaurant = this.$store.state.id_restaurant
            //Pasando datos al componente factura
            this.cliente_ticket.nombre_completo = this.cliente.nombre_completo
            this.cliente_ticket.dni = this.cliente.dni
//            this.detallePago.sub_total = this.cliente.importe
            this.detallePago.efectivo = this.cliente.efectivo
            this.detallePago.cambio = this.cliente.cambio
            this.productosArray_ticket = this.tablaProductosPedidos

            let i = 0
            let cad = "";
            this.tablaProductosPedidos.forEach(element => {
                if(i == this.tablaProductosPedidos.length-1){
                    cad = cad+element.id_producto+"|"+element.cantidad+"|"+element.p_unit+"|"+element.importe+"|"+element.nota
                }else{
                    cad = cad+element.id_producto+"|"+element.cantidad+"|"+element.p_unit+"|"+element.importe+"|"+element.nota+":"
                }
                i++
            });
            this.cliente.listaProductos = cad
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.post(this.$store.state.url_root+`api/auth/clientepago`, this.cliente)
            .then(response => {
                if(response.data.error == null){
                    //Guardar en venta_productos
                    if(response.data.data[0].registraproductosfunction == this.tablaProductosPedidos.length){
                        //this.$store.dispatch('indicePedidosActiveAction', response.data.vprod.id_venta_producto)
                        //this.$router.push({name: 'historial_pedidos', params: {obj: response.data.vprod}})
                        this.ventaProdObj = response.data.vprod
                        this.nroPedido_ticket = response.data.nro_pedido
                        this.limpiarPedido();
                        this.$toasted.show('Se realizo el pago del pedido correctamente', {type: 'success'})
                        this.btnClientePrint = true
                        this.$Progress.finish()
                        this.$refs.pagarPedidoBtn.className = "btn btn-primary"
                    }
                }else{
                    if(response.data.error.limite_pedidos == null){
                        if(response.data.error.apertura_caja == null){
                            if(response.data.error.efectivo_mayor == null){
                                if(response.data.error.total_pagar_mayor == null){
                                    this.errores = response.data.error;
                                }else{
                                    this.pedidoMsg = `${response.data.error.total_pagar_mayor}`
                                }
                            }else{
                                this.pedidoMsg = `${response.data.error.efectivo_mayor}`   
                            }
                        }
                        else{
                            this.nuevoPedidoMsg = response.data.error.apertura_caja
                        }
                    }else{
                        this.nuevoPedidoMsg = response.data.error.limite_pedidos
                    }
                    this.$Progress.fail()
                    this.$refs.pagarPedidoBtn.className = "btn btn-primary"
                }
            })
            .catch (error => {
                this.$toasted.show("NuevoPedido: "+error, {type: 'error'})
                this.$Progress.fail()
                this.$refs.pagarPedidoBtn.className = "btn btn-primary"
            });
        },
        chengeStatePrint(){
            if(this.$refs.statePrint.checked){
                this.esFactura = true
            }else{
                this.esFactura = false
            }
        },
        printTicket(){
            window.print()
        },
        recalcularImporte() {
            this.reg.importeRecalculado = this.calculaImporte;
            this.editarImporte = false;
        },
    },
}
</script>
<style lang="scss">
    .caja-style{
        margin: 0rem 1rem 1rem 0rem;
        //background-color: azure;
    }
    .sub-cajero{
        color: #5e5e5e;
    }
    .style-limpiar{
        float: right;
        font-size: 12px;
    }
    .caja_texto{
        width: 100%;
        border-radius: 6px;
        height: 2rem;
        border: 2px solid #a5a4a4;
        margin: 0.2rem;
    }
    .enlinea{
        display: flex;
        input{
            border-style: none;
            background-color: transparent;
            width: 100%;
        }
        button{
            border-style: none;
            background-color: transparent;
            color: #a5a4a4;
            &:focus{
                outline: 0;
                -webkit-box-shadow: 0 0 0 0.2rem transparent;
                box-shadow: 0 0 0 0.2rem transparent;
            }
        }
    }
    .style-datos-cliente{
        color: #5e5e5e;
        font-size: 15px;
    }
    .contenedor-categorias{
        display: flex;
        flex-wrap: wrap;
        .item-categoria{
            background-color: #468647;
            color: white;
            width: auto;
            padding: .1rem 0.5rem .1rem 0.5rem;
            margin: 2px;
            border-radius: 5px;
            transition: all 1s ease;
            &:hover{
                background-color: #AD5D00;
                cursor: pointer;
            }
            &:active{
                background-color: #f44336;
            }
        }
        .itemCategoriaActive{
            background-color: #f44336;
        }
    }
    .contenedor-productos{
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        max-height: 30rem;
        border: 1px solid #a5a4a4;
        overflow: auto;
        margin-top: 5px;
        .item-producto{
            width: auto;
            height: auto;
            background-color: #165872;
            margin: 5px;
            padding: 3px;
            text-align: center;
            transition: all 1s ease;
            &:hover{
                cursor: pointer;
                img{
                    border: 2px solid black;
                }
                background-color: #ff9800;
                .precio_producto{
                    color: black;
                }
            }
            &:active{
                img{
                    border: 2px solid black;
                }
                background-color: #ff9800;
                .precio_producto{
                    color: black;
                }
            }
            img{
                border: 2px solid #ff9800;
            }
            .precio_producto{
                color: #ff9800;
                font-weight: bold;
            }
            .nombre_producto{
                color: white;
            }
        }
    }
    .alineacion-botones{
        button{
            margin: 3px 3px 3px 0px;
        }
    }
    .li-horizontal {
        display: flex;
        align-items: center;
        gap: 0.5rem;
    }
</style>