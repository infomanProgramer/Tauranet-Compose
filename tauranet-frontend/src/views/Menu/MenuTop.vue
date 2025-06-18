<template>
    <div>
        <nav class="navbar navbar-expand-lg navbar-light bg-light" id="menu-superior">
            <a class="navbar-brand" href="#">
                <img alt="Tauranet logo" src="../../assets/logo-tauranet.svg" width="170"/>
            </a>
            <!--<div class="collapse navbar-collapse lista" id="navbarSupportedContent">-->
            <div class="lista">
                <ul class="navbar-nav">
                    <li class="nav-item">
                        <a class="nav-link" href="#">Idioma</a>
                    </li>
                    <li class="nav-item dropdown">
                        <a class="nav-link dropdown-toggle" href="#" id="navbarDropdown" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                            <DataUser :dataReturn="['nombre_usuario']"></DataUser>
                        </a>
                        <div class="dropdown-menu dropdown-menu-right" aria-labelledby="navbarDropdown">
                            <a class="dropdown-item" href="#">Configuración</a>
                            <router-link :to="{name: 'logout'}" class="dropdown-item">Cerrar sesión</router-link>
                        </div>
                    </li>
                </ul>
            </div>
        </nav>
    </div>
</template>
<script>
    import DataUser from '@/components/Auth/DataUser'
    export default{
        components: {
            DataUser,
        },
        computed: {
            loggedIn() {
                return this.$store.getters.loggedIn; 
            }
        },
    }
</script>
<style lang="scss">
    .lista{
        flex-grow: 1;
        display: flex;
        justify-content: flex-end;
    }
</style>