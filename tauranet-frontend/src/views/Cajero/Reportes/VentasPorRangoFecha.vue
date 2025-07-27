<template>
    <Marco titulo="Reporte de ventas por rango de fecha" icono="fas fa-chart-bar">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-12">
                    asdfasf
                </div>
            </div>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import {misMixins} from '@/mixins/misMixins.js';
export default{
    name: 'VentasPorRangoFecha',
    components: {
        Marco
    },
    created(){
        this.$Progress.start()
        
    },
    mixins: [misMixins],
}
</script>