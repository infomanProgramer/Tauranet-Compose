<template>
    <Marco titulo="Estadísticas" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <div class="row">
                <EmpleadoPedido></EmpleadoPedido>
            </div>
            <div class="row">
                <ProductoCantidad></ProductoCantidad>
            </div>
            <div class="row">
                <ProductoImporte></ProductoImporte>
            </div>
            <div class="row">
                <FechaPedido></FechaPedido>
            </div>
            <div class="row">
                <FechaImporte></FechaImporte>
            </div>
        </div>
    </Marco>
</template>
<script>
import Marco from '@/components/Layout/Marco';
import {misMixins} from '@/mixins/misMixins.js';
import EmpleadoPedido from '@/components/Administrador/GraphTable/EmpleadoPedido'
import ProductoCantidad from '@/components/Administrador/GraphTable/ProductoCantidad'
import ProductoImporte from '@/components/Administrador/GraphTable/ProductoImporte'
import FechaPedido from '@/components/Administrador/GraphTable/FechaPedido'
import FechaImporte from '@/components/Administrador/GraphTable/FechaImporte'
export default{
    name: 'Estadisticas',
    components: {
        Marco,
        EmpleadoPedido,
        ProductoCantidad,
        ProductoImporte,
        FechaPedido,
        FechaImporte
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
        }
    },
    mixins: [misMixins],
}
</script>