<template>
    <div class="card text-white bg-success mb-3" style="max-width: 18rem;">
        <div class="card-body">
            <!-- <h5 class="card-title date-card-font">{{fechaActual}}</h5> -->
            <p class="card-text">{{cantVentas}}</p>
        </div>
        <div class="card-header">VENTAS</div>
    </div>
</template>
<script>
export default{
    name: 'CardVenta',
    props: {
        fechaActual: {
            type: String,
            required: true 
        },
        cantVentas: {
            type: Number,
            require: true
        }
    },
}
</script>
<style lang="scss">
    .date-card-font{
        font-size: .8rem;
    }
    .card-text{
        font-size: 2.2rem;
        text-align: right;
        opacity: 0.5;
    }
</style>