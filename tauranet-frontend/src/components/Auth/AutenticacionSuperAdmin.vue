<template>
    <div class="autenticacion-marco container-fluid">
        <div class="row">
            <div class="col-md-12 text-center">
                <a class="navbar-brand" href="#">
                    <img alt="Perfil Usuario" src="../../assets/logo-tauranet.svg" width="300" class="img-fluid"/><br>
                    <span>Sistema de Restaurante Dev</span>
                </a>
            </div>          
        </div>
        <div class="row">
            <div class="col-md-12">
                <BoxMessage :message="advertenciaLogin" :cod="'wa'"></BoxMessage>
                <form action="#" @submit.prevent="login">
                    <div class="form-group">
                        <div class="borde-input">
                            <i class="fas fa-user"></i>
                            <input type="text" class="form-control" v-model="nombre_usuario" placeholder="Usuario">
                        </div>
                        <ListErrors :errores="errores.nombre_usuario"></ListErrors>
                    </div>
                    <div class="form-group">
                        <div class="borde-input">
                            <i class="fas fa-unlock"></i>
                            <input type="password" class="form-control" v-model="password" placeholder="Contraseña">
                        </div>
                        <ListErrors :errores="errores.password"></ListErrors>
                    </div>
                    <div class="form-group d-flex justify-content-center">
                        <button type="submit" class="btn-login">Ingresar</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</template>
<script>
    import ListErrors from '@/components/Messages/ListErrors'
    import BoxMessage from '@/components/Messages/BoxMessage'
    export default{
        name: 'AutenticacionSuperAdmin',
        components: {
            ListErrors,
            BoxMessage
        },
        data() {
            return {
                nombre_usuario: '',
                password: '',
                errores: {},
                advertenciaLogin: '',
                type_user: 3
            }
        },
        methods: {
            login() {
                this.errores = {};
                if(this.type_user != null){
                    this.$store.dispatch('retrieveToken', {
                        nombre_usuario: this.nombre_usuario,
                        password: this.password,
                        type_user: this.type_user
                    }).then(response =>{
                        if(response.data.access_token != null && response.data.access_token != ''){
                            this.$router.push({name: 'restaurant'})
                        }
                        else if(response.data.error != null){
                            this.advertenciaLogin = response.data.error;
                        }
                        else{
                            this.errores = response.data.errors;
                        }
                    }).catch((error) => {
                        this.$toasted.show("Error en el servidor: "+error, {type: 'error'});
                    })
                }else{
                    this.errores.type_user = ['Debe asignar el tipo de usuario'];
                }
            }
        },
    }
</script>