<template>
    <ul v-if="errores" class="ListErrors-text">
        <li v-for="error in errores" :key="error.id">
            * {{ error }}
        </li>
    </ul>
</template>
<script>
    export default{
        neme: 'ListErrors',
        props: {
            errores: {
                type: Array
            }
        }
    }
</script>
<style lang="scss">
    .ListErrors-text{
        list-style: none;
        color: red;
        font-size: 0.8rem;
        padding-left: 0%;
    }
</style>