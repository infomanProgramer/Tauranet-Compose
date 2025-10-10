<template>
    <div class="card text-white bg-warning mb-3" style="max-width: 18rem;">
        <div class="card-body">
            <p class="card-text-sucursal">{{nameSucursal}}</p>
        </div>
    </div>
</template>
<script>
export default{
    name: 'CardSucursal',
    props: {
        nameSucursal: {
            type: String,
            required: true
        },
    },
}
</script>
<style lang="scss">
    .date-card-font{
        font-size: .8rem;
    }
    .card-text-sucursal{
        font-size: 2.4rem;
        text-align: left;
        opacity: 0.9;
    }
</style>