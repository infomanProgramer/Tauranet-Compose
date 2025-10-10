<template>
    <div class="container-fluid fondo-login">
        <div class="row d-flex h-100">
            <div class="col-md-4"></div>
            <div class="col-md-4 align-self-center"><Autenticacion></Autenticacion></div>
            <div class="col-md-4"></div> 
        </div>
    </div>
</template>
<script>
    import Autenticacion from '@/components/Auth/Autenticacion'
    export default{
        name: 'Login',
        components: {
            Autenticacion
        }
    }
</script>
<style lang="scss">
    .fondo-login{
        background-image: radial-gradient(#383838 10%, black 90%);
        color: white;
        height: 100vh;
        overflow: hidden;
        a{
            list-style: none;
        }
    }
</style>