<template>
    <div class="table-responsive">
        <table class="table table-bordered table-condensed">
            <thead class="head-table">
                <tr>
                    <th scope="col" v-for="rotulo in rotulos" v-bind:key="rotulo.name">{{rotulo.name}}</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="p in productosPedidos" v-bind:key="p.cod">
                    <td>{{p.id_producto}}</td>
                    <td>{{p.cantidad}}</td>
                    <td>{{p.detalle}}</td>
                    <td>{{p.p_unit}}</td>
                    <td>{{p.importe}}</td>
                    <td>{{p.nota}}</td>
                    <td class="botonTablaProducto">
                        <button class="btn btn-info" v-on:click="$emit('addNota', p)"><i class="far fa-sticky-note"></i></button>
                        <button class="btn btn-success" v-on:click="$emit('addCant', p)"><i class="fas fa-plus"></i></button>
                        <button class="btn btn-danger" v-on:click="$emit('delCant', p)"><i class="fas fa-minus"></i></button>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</template>
<script>
export default{
    name: 'TableCondensed',
    props: {
        productosPedidos: {
            type: Array
        },
        rotulos: {
            type: Array
        }
    },
    computed: {
        visibilidadColumna(val) {
            return val;
        }
    },
}
</script>
<style lang="scss">
    .table-condensed>thead>tr>th, .table-condensed>tbody>tr>th, .table-condensed>tfoot>tr>th, .table-condensed>thead>tr>td, .table-condensed>tbody>tr>td, .table-condensed>tfoot>tr>td{
        padding: 1px;
    }
    .botonTablaProducto{
        text-align: center;
        button{
            margin: 2px;
        }
    }
</style>