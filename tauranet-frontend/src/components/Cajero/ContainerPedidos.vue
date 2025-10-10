<template>
    <div class="container-pedidos" :class="{sombra: pedidoObj.id_venta_producto == getIndicePedido}" @click="$emit('sendPedidoMethod', pedidoObj)">
        <div class="encabezado">
            PEDIDO {{pedidoObj.nro_venta}}
        </div>
        <div class="cuerpo-red" :class="{cuerpoGreen: pedidoObj.estado_venta == 0}">
            <div class="form-check">
                <label class="form-check-label" for="defaultCheck2">
                    <input class="form-check-input" type="checkbox" value="" id="defaultCheck2" disabled checked v-if="pedidoObj.estado_atendido">
                    <input class="form-check-input" type="checkbox" value="" id="defaultCheck2" disabled v-else>
                    Atendido por cocina
                </label>
            </div>
            <span>Fecha:</span> {{pedidoObj.created_at}}<br>
            <span v-if="nombreClienteComputed">Cliente: {{nombreClienteComputed}}</span><br v-if="nombreClienteComputed">
            <span v-if="dniClienteComputed">{{getIdentificacion}}: {{dniClienteComputed}}</span><br v-if="dniClienteComputed">
            <span>{{rol}}:</span> {{nombre_empleado}}<br>
            <span v-if="type_user == 0">{{pedidoObj.nombre_caja}}</span>
        </div>
    </div>
</template>
<script>
export default{
    name: 'ContainerPedidos',
    props: {
        pedidoObj: {
            type: Object,
        },
        indicadorPedido: {
            type: Boolean,
            default: false
        }
    },
    data() {
        return {
            indice: this.$store.state.indicePedidosActive,
            type_user: this.$store.state.type_user,
        }
    },
    computed: {
        rol() {
            if(this.pedidoObj.nombre_cajero == null){
                return 'Mozo'
            }else{
                return 'Cajero'
            }
        },
        nombre_empleado(){
            if(this.pedidoObj.nombre_cajero == null){
                return this.pedidoObj.nombre_mozo
            }else{
                return this.pedidoObj.nombre_cajero
            }
        },
        nombreClienteComputed(){
            if(this.pedidoObj.nombre_completo){
                return this.pedidoObj.nombre_completo
            }else{
                return null;
            }
        },
        dniClienteComputed(){
            if(this.pedidoObj.dni_cliente){
                return this.pedidoObj.dni_cliente
            }else{
                return null;
            }
        },
        getIndicePedido(){
            return this.$store.state.indicePedidosActive;
        },
        getIdentificacion(){
            return this.$store.state.restauranteData.identificacion
        }
    },
}
</script>
<style lang="scss">
    .container-pedidos{
        width: 100%;
        color: white;
        //border: 2px solid black;
        border-radius: 12px 12px 0px 0px;
        margin-bottom: 1rem;
        cursor: pointer;
        .encabezado{
            background-color: black;
            text-align: center;
            font-weight: bold;
            border-radius: 9px 9px 0px 0px;
        }
        .cuerpo-red{
            background-color: #f44336;
            text-align: left;
            padding: 0px 0px 5px 5px;
            font-size: 13px;
            span{
                font-weight: bold;
            }
        }
        .cuerpoGreen{
            background-color: #468647;
            text-align: left;
            padding: 0px 0px 5px 5px;
            font-size: 13px;
            span{
                font-weight: bold;
            }
        }
    }
    .sombra{
        -webkit-box-shadow: 0px 2px 9px 2px rgba(0,0,0,0.75);
        -moz-box-shadow: 0px 2px 9px 2px rgba(0,0,0,0.75);
        box-shadow: 0px 2px 9px 2px rgba(0,0,0,0.75);
    }
</style>