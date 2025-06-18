<template>
    <div>
        <div class="printableArea" v-if="!esFactura">
            <table class="table sin-bordes table-condensed">
                <tbody>
                    <tr class="encabezado-factura">
                        <td colspan="2"><h5>PEDIDO # {{nroPedido_computed}}</h5></td>
                    </tr>
                    <tr>
                        <td><span>Señor(es):</span></td>
                        <td>{{cliente_computed.nombre_completo}}</td>
                    </tr>
                    <tr>
                        <td><span>{{getIdentificacion}}:</span></td>
                        <td>{{cliente_computed.dni}}</td>
                    </tr>
                </tbody>
            </table>
            <table class="table table-bordered table-condensed">
                <tbody>
                    <tr class="encabezado-factura">
                        <td>Cant</td>
                        <td>Prod</td>
                        <td>Nota</td>
                    </tr>
                    <tr v-for="item in productos_computed" v-bind:key="item.id_producto_vendido">
                        <td>{{item.cantidad}}</td>
                        <td>{{item.detalle}}</td>
                        <td>{{item.nota}}</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="printableArea" v-else>
            <table class="table table-condensed sin-bordes table-cliente">
                <tbody>
                    <tr>
                        <td colspan="2"><h4>{{getDataRestaurante.restaurant}}</h4></td>
                    </tr>
                    <tr>
                        <td colspan="2"><h6>{{getDataRestaurante.sucursal}}</h6></td>
                    </tr>
                    <tr>
                        <td colspan="2" class="center-text">{{getDataRestaurante.direccion}}</td>
                    </tr>
                    <tr v-if="getDataRestaurante.telefono != null">
                        <td colspan="2" class="center-text">Telef. {{getDataRestaurante.telefono}}</td>
                    </tr>
                    <tr v-if="getDataRestaurante.celular != null">
                        <td colspan="2" class="center-text">Celular. {{getDataRestaurante.celular}}</td>
                    </tr>
                    <tr>
                        <td colspan="2" class="center-text">{{getDataRestaurante.pais}} - {{getDataRestaurante.ciudad}}</td>
                    </tr>
                </tbody>
            </table>
            <table class="table table-condensed sin-bordes table-cliente">
                <tbody>
                    <tr>
                        <td><span>Señor(es):</span></td>
                        <td>{{cliente_computed.nombre_completo}}</td>
                    </tr>
                    <tr>
                        <td><span>{{getIdentificacion}}:</span></td>
                        <td>{{cliente_computed.dni}}</td>
                    </tr>
                </tbody>
            </table>
            <!-- nro del telefono, nit direccion -->
            <table class="table sin-bordes table-condensed table-cliente">
                <tbody>
                    <tr class="encabezado-factura">
                        <td>Cant</td>
                        <td>Prod</td>
                        <td>P.Unit</td>
                        <td>Importe</td>
                    </tr>
                    <tr v-for="item in productos_computed" v-bind:key="item.id_producto_vendido">
                        <td>{{item.cantidad}}</td>
                        <td>{{item.detalle}}</td>
                        <td>{{item.p_unit}}</td>
                        <td>{{item.importe}}</td>
                    </tr>
                </tbody>
            </table>
            <table class="table table-condensed sin-bordes table-cliente">
                <tbody>
                    <!-- <tr>
                        <td>Total</td>
                        <td>{{detallePago_computed.sub_total}}</td>
                    </tr> -->
                    <tr>
                        <td>Total a pagar: {{tipoMoneda}}</td>
                        <td>{{detallePago_computed.total}}</td>
                    </tr>
                    <tr>
                        <td>Efectivo: {{tipoMoneda}}</td>
                        <td>{{detallePago_computed.efectivo}}</td>
                    </tr>
                    <tr>
                        <td>Cambio: {{tipoMoneda}}</td>
                        <td>{{detallePago_computed.cambio}}</td>
                    </tr>
                </tbody>
            </table>
            <table class="table table-condensed sin-bordes table-cliente">
                <tbody>
                    <tr>
                        <td colspan="2" class="center-text">Pedido: {{nroPedido_computed}}</td>
                    </tr>
                    <tr>
                        <td colspan="2" class="center-text">{{getDataRestaurante.caja}}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</template>
<script>
const axios = require("axios");
export default{
    props: {
        cliente: {
            type: Object,
            required: true
        },
        productosArray: {
            type: Array,
            required: true
        },
        nro_pedido: {
            type: Number,
            required: true
        },
        esFactura: {
            type: Boolean,
            required: true
        },
        detallePago: {
            type: Object,
            default: {}
        }
    },
    name: 'facturaCocina',
    computed: {
        cliente_computed() {
            if(this.cliente.nombre_completo == null){
                this.cliente.nombre_completo = 'GENERAL'
            }
            if(this.cliente.dni == null){
                this.cliente.dni = 'GENERAL'
            }
            return this.cliente 
        },
        productos_computed(){
            return this.productosArray
        },
        nroPedido_computed(){
            return this.nro_pedido
        },
        detallePago_computed(){
            return this.detallePago
        },
        getIdentificacion(){
            return this.$store.state.restauranteData.identificacion
        },
        getDataRestaurante(){
            return this.$store.state.restauranteData
        },
        tipoMoneda() {
            return this.$store.state.restauranteData.tipo_moneda
        },
    },
}
</script>
<style lang="scss">
    .printableArea{
        visibility: hidden;
        width: 302px;
        height: 10px;
    }
    @media print{
        body *{
             visibility: hidden;
             height: 10px;
            //  width: 302px;
        }
        .printableArea, .printableArea *{
            visibility: visible;
        }
        .printableArea{
            position: absolute;
            left: 0;
            top: 0;
            font-family: 'Courier New', Courier, monospace;
            padding: 5px 5px 5px 5px;
            table{
                margin-top: 0px;
                margin-bottom: 0px;
            }
            .table-cliente{
                border-bottom: 2px dashed #AFAFAF;
            }
            .center-text{
                text-align: center;
            }
            .sin-bordes>tbody>tr>td{
                border-color: transparent;
            }
            h5{
                text-align: center;
                font-weight: bold;
            }
            h4{
                margin-bottom: 1rem;
                font-weight: bold;
            }
            h6, h4{
                text-align: center;
            }
            span{
                font-weight: bold
            }
            .encabezado-factura>td{
                font-weight: bold;
            }
        }
    }
</style>