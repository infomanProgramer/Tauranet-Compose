<template>
    <div class="row">
        <div class="col-md-12 encabezado">
            <h3 v-text="titleEncabezado"></h3>
        </div>
    </div>
</template>
<script>
export default{
    name: 'Encabezado',
    props: {
        titleEncabezado: {
            type: String,
            default: ''
        },
    },
}
</script>
import { scrypt } from "crypto";

<style lang="scss">
    .encabezado{
        border-bottom: 2px solid coral;
        margin-bottom: 0.5rem
    }
</style>