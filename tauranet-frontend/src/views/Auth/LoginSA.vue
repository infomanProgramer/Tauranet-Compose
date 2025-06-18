<template>
    <div class="container-fluid fondo-login">
        <div class="row d-flex h-100">
            <div class="col-md-4"></div>
            <div class="col-md-4 align-self-center"><AutenticacionSuperAdmin></AutenticacionSuperAdmin></div>
            <div class="col-md-4"></div> 
        </div>
    </div>
</template>
<script>
    import AutenticacionSuperAdmin from '@/components/Auth/AutenticacionSuperAdmin'
    export default{
        name: 'LoginSA',
        components: {
            AutenticacionSuperAdmin
        }
    }
</script>