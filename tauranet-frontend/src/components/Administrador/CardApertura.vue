<template>
    <div class="card text-white bg-info mb-3" style="max-width: 18rem;">
        <div class="card-body">
            <h5 class="card-title date-card-font">{{fechaActual}}</h5>
            <div class="card-text-caja">
                Monto Apertura: {{montoIni}} Bs.<br>
                Monto Actual: {{montoFin}} Bs. 
            </div>
        </div>
        <div class="card-header">{{nombreCaja}}</div>
    </div>
</template>
<script>
export default{
    name: 'CardApertura',
    props: {
        montoIni: {
            type: Number,
            required: true
        },
        montoFin: {
            type: Number,
            required: true
        },
        fechaActual: {
            type: String,
            required: true
        },
        nombreCaja: {
            type: String,
            required: true
        }
    },
}
</script>
<style lang="scss">
    .date-card-font{
        font-size: .8rem;
    }
    .card-text-caja{
        font-size: 1rem;
        text-align: left;
        opacity: 0.5;
    }
</style>