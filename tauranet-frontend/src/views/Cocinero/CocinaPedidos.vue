<template>
    <Marco titulo="Atencion cocina" icono="fas fa-table">
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
                    <h5 class="sub-cajero">Cliente</h5>
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
                                    <th scope="col">Nota</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr v-for="prod in productosArray" v-bind:key="prod.id_producto">
                                    <td>{{prod.id_producto}}</td>
                                    <td>{{prod.cantidad}}</td>
                                    <td>{{prod.detalle}}</td>
                                    <td>{{parseFloat(prod.p_unit).toFixed(2)}}</td>
                                    <td>{{parseFloat(prod.importe).toFixed(2)}}</td>
                                    <td>{{prod.nota}}</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <div v-show="swBoton != false">
                        <button class="btn btn-primary" @click="cambiaEstadoAtendidoMethod" ref="btnAtendido">
                            <div class="form-check">
                                <label class="form-check-label" for="defaultCheck2">
                                    <input class="form-check-input" type="checkbox" value="" id="defaultCheck2" disabled checked v-if="ventaProductoObj.estado_atendido">
                                    <input class="form-check-input" type="checkbox" value="" id="defaultCheck2" disabled v-else>
                                    Atendido
                                </label>
                            </div>
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import ContainerPedidos from '@/components/Cajero/ContainerPedidos';
import {misMixins} from '@/mixins/misMixins.js';
export default{
    name: 'CocinaPedidos',
    components: {
        Marco,
        ContainerPedidos
    },
    data() {
        return {
            pedidosArray: [],
            buscaPedido: '',
            data_usr: {},
            type_user: this.$store.state.type_user,
            productosArray: [],
            nro_pedido: 0,
            ventaProductoObj: {
                total: 0,
                sub_total: 0,
                descuento: 0,
                nombre_cliente: ''
            },
            swBoton: false
        }
    },
    mixins: [misMixins],
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
    computed: {
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
        getIdentificacion(){
            return this.$store.state.restauranteData.identificacion
        }
    },
    methods: {
        getPedidosArray(){
            this.$Progress.start()
            let url = this.$store.state.url_root+`api/auth/ventaproductos/sucursal/${this.data_usr.id_sucursal}`  
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.pedidosArray = response.data.data
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("CocinaPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        showDatosPedido(obj){
            this.$Progress.start()
            this.nro_pedido = obj.nro_venta
            //this.$store.state.indicePedidosActive = nroPedido
            this.$store.dispatch('indicePedidosActiveAction', obj.id_venta_producto)
            let url = this.$store.state.url_root+`api/auth/productovendido/pedido/${obj.id_venta_producto}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.swBoton = true
                this.productosArray = response.data.data
                this.ventaProductoObj = response.data.vprod[0]
                if(this.ventaProductoObj.estado_atendido){
                    this.$refs.btnAtendido.className="btn btn-primary disabled"    
                }else{
                    this.$refs.btnAtendido.className="btn btn-primary"
                }
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("CocinaPedido.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaEstadoAtendidoMethod(){
            let sw = confirm("Confirmar atención del pedido");
            if(sw){
                this.$Progress.start()
                let url = this.$store.state.url_root+`api/auth/estadoatendido/${this.ventaProductoObj.id_venta_producto}`
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
                .then(response => {
                    this.ventaProductoObj.estado_atendido = response.data.data.estado_atendido
                    this.$refs.btnAtendido.className="btn btn-primary disabled"   
                    this.getPedidosArray()
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("CocinaPedido.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }
        }
    },
}
</script>