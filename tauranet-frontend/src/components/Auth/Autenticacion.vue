<template>
    <div class="autenticacion-marco container-fluid">
        <div class="row">
            <div class="col-md-12 text-center">
                <a class="navbar-brand" href="#">
                    <img alt="Perfil Usuario" src="../../assets/logo-tauranet.svg" width="300" class="img-fluid"/><br>
                    <span>Sistema de restaurante</span>
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
                    <div class="form-group">
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="type_user" v-model="type_user" id="checkMozo" value="0" checked>
                            <label class="form-check-label" for="exampleRadios1">
                                Mozo
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="type_user" v-model="type_user" id="checkCajero" value="1">
                            <label class="form-check-label" for="exampleRadios1">
                                Cajero
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="type_user" v-model="type_user" id="checkAdministrador" value="2">
                            <label class="form-check-label" for="exampleRadios1">
                                Administrador
                            </label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="type_user" v-model="type_user" id="checkCocinero" value="4">
                            <label class="form-check-label" for="exampleRadios1">
                                Cocinero
                            </label>
                        </div>
                        <ListErrors :errores="errores.type_user"></ListErrors>
                    </div>
                    <div class="form-group d-flex justify-content-center">
                        <button type="submit" class="btn-login" ref="botonLogin">Ingresar</button>
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
        name: 'Autenticacion',
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
                type_user: null,
                uploadPercentage: 0
            }
        },
        methods: {
            login() {
                this.$refs.botonLogin.className = "btn-login disabled-btn"
                this.$Progress.start()
                this.errores = {};
                //console.log(this.nombre_usuario, this.password, this.type_user)
                if(this.type_user != null){
                    this.$store.dispatch('retrieveToken', {
                        nombre_usuario: this.nombre_usuario,
                        password: this.password,
                        type_user: this.type_user
                    }).then(response =>{
                        if(response.data.access_token != null && response.data.access_token != ''){
                            if(this.type_user == 0){//Mozo
                                this.$router.push({name: 'nuevopedido'})
                                this.$Progress.finish()
                            }else if(this.type_user == 1){//Cajero
                                this.$router.push({name: 'nuevopedido'})
                                this.$Progress.finish()
                            }else if(this.type_user == 2){//Administrador
                                this.$router.push({name: 'sucursal'})
                                this.$Progress.finish()
                            }else if(this.type_user == 4){//Cocinero
                                console.log("cocinero autenticado")
                                this.$router.push({name: 'cocinapedidos'})
                                this.$Progress.finish()
                            }
                        }
                        else if(response.data.error != null){
                            this.advertenciaLogin = response.data.error;
                            this.$Progress.fail()
                            this.$refs.botonLogin.className = "btn-login"
                        }
                        else{
                            this.errores = response.data.errors;
                            this.$Progress.fail()
                            this.$refs.botonLogin.className = "btn-login"
                        }
                    }).catch((error) => {
                        this.$toasted.show(error, {type: 'error'})
                        this.$Progress.fail()
                        this.$refs.botonLogin.className = "btn-login"
                    })
                }else{
                    this.errores.type_user = ['Debe asignar el tipo de usuario'];
                    this.$Progress.fail()
                    this.$refs.botonLogin.className = "btn-login"
                }
            }
        },
    }
</script>
<style lang="scss">
    .autenticacion-marco{
        background-color: transparent;
        padding: 1rem;
        a{
            font-size: 20px;
            color: white;
            margin-bottom: 1rem;
            span{
                opacity: 0.5;
            }
        }
        label{
            color: #D3D3D3;
        }
        input[type="text"]{
            border-style: none;
            background-color: transparent;
            color: #D3D3D3;
            &::placeholder{
                color: #D3D3D3;
                opacity: 1;
            }
            &:focus{
                box-shadow: none;
            }
        }
        input[type="password"]{
            border-style: none;
            background-color: transparent;
            color: #D3D3D3;
            &::placeholder{
                color: #D3D3D3;
                opacity: 1;
            }
            &:focus{
                box-shadow: none;
            }
        }
        .borde-input{
            border-bottom: 2px solid #D3D3D3;
            display: flex;
            i{
                line-height: 38px;
                width: 1.5rem;
                text-align: center;
                color: #D3D3D3;
            }
        }
        .btn-login{
            border-style: none;
            background-color: transparent;
            border: 1px solid #D3D3D3;
            padding: 15px;
            border-radius: 8px;
            color: #D3D3D3;
            &:focus{
                box-shadow: none;
            }
        }
        .disabled-btn{
            background-color: #D3D3D3;
            color: black;
            opacity: 0.3;
            pointer-events: none;
            cursor: not-allowed;
        }
    }
</style>