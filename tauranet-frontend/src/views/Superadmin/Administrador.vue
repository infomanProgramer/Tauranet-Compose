<template>
    <Marco titulo="Administradores" icono="fas fa-table">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <label for="">
                            Entradas
                            <select id="nroEntradas" @change="cambiaOption" ref="nroEntradas">
                                <option>3</option>
                                <option>5</option>
                                <option>10</option>
                            </select>
                    </label>
                </div>
                <div class="col-md-6">
                    <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevoAdministrador"><i class="fas fa-plus"></i> Nuevo</button>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <label for="">
                        Restaurante
                        <select id="nroEntradas" @change="mostrarPorRestaurante" ref="selectMostrarPorRestaurante">
                            <option value="-1" selected>Seleccionar...</option>
                            <option v-for="restaurante in Restaurantes" v-bind:key="restaurante.id_restaurant" :value="restaurante.id_restaurant">{{restaurante.nombre}}</option>
                        </select>
                    </label>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <BoxMessage :message="nuevoAdministradorMsg" :cod="'su'" icono="fas fa-check"></BoxMessage>
                    <div class="col-md-12 table-responsive">
                        <table-component
                            :data="listaAdministradores"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombreRestaurante" label="Restaurante"></table-column>
                            <table-column show="tipo_suscripcion" label="Suscripción"></table-column>
                            <table-column label="Estado Restaurante" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <div class="form-check">
                                        <input type="checkbox" class="form-check-input" v-if="row.estado_resturante" checked disabled>
                                        <input type="checkbox" class="form-check-input" v-else disabled>
                                    </div>
                                </template>
                            </table-column>
                            <table-column show="nombre_usuario" label="Usuario"></table-column>
                            <table-column show="nombre_completo" label="Administrador"></table-column>
                            <table-column show="dni" label="DNI"></table-column>
                            <table-column label="Acciones" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaAdministrador" @click="getDatosAdministrador(row.id_administrador)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="datosAdministrador"></Pagination>
                </div>
            </div>
            <!-- Ventanas Modales -->
            <div class="row">
                <!-- Modal Nuevo Administrador         -->
                <form @submit.prevent="nuevoAdministrador" enctype="multipart/form-data" method="post">
                    <Modal titulo="Registro Administrador" idModal="modalNuevoAdministrador" icono="fas fa-user-plus">
                        <template v-slot:body>
                            <div class="container-fluid">
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.paterno" placeholder="Ap. Paterno">
                                            <ListErrors :errores="errores.paterno"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.materno" placeholder="Ap. Materno">
                                            <ListErrors :errores="errores.materno"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.primer_nombre" placeholder="Primer Nombre">
                                            <ListErrors :errores="errores.primer_nombre"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.segundo_nombre" placeholder="Segundo Nombre">
                                            <ListErrors :errores="errores.segundo_nombre"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="password" class="form-control input-style" v-model="administrador.password" placeholder="Contraseña">
                                            <ListErrors :errores="errores.password"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="password" class="form-control input-style" v-model="administrador.password_confirmation" placeholder="Confirmar contraseña">
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.nombre_usuario" placeholder="Usuario">
                                            <ListErrors :errores="errores.nombre_usuario"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.direccion" placeholder="Direcciön">
                                            <ListErrors :errores="errores.direccion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <flat-pickr
                                                    v-model="administrador.fecha_nac"                                                       
                                                    class="form-control input-style"
                                                    :config="config"
                                                    placeholder="Fecha Nacimiento"
                                                    >
                                            </flat-pickr>
                                            <ListErrors :errores="errores.fecha_nac"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="email" class="form-control input-style" v-model="administrador.email" placeholder="Email">
                                            <ListErrors :errores="errores.email"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Sexo</label>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="sexo" v-model="administrador.sexo" id="checkMozo" value="1" :checked=true>
                                                <label class="form-check-label" for="exampleRadios1">
                                                    Masculino
                                                </label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="sexo" v-model="administrador.sexo" id="checkCajero" value="0">
                                                <label class="form-check-label" for="exampleRadios1">
                                                    Femenino
                                                </label>
                                            </div>
                                            <ListErrors :errores="errores.sexo"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <select class="form-control input-style" v-model="administrador.id_restaurant">
                                                <option value="-1" selected>Restaurante...</option>
                                                <option v-for="restaurante in Restaurantes" v-bind:key="restaurante.id_restaurant" :value="restaurante.id_restaurant">{{restaurante.nombre}}</option>
                                            </select>
                                            <ListErrors :errores="errores.id_restaurant"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.dni" placeholder="DNI">
                                            <ListErrors :errores="errores.dni"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.celular" placeholder="Celular">
                                            <ListErrors :errores="errores.celular"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="administrador.telefono" placeholder="Telefono">
                                            <ListErrors :errores="errores.telefono"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Foto Perfil</label>
                                            <input type="file" :class="{disabled: fotoPerfilPreview!=null}" class="form-control-file input-style" @change="imageChanged" ref="fileImage">
                                            <ListErrors :errores="errores.nombre_fotoperfil"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6 my-auto">
                                        <div class="progress" v-if="uploadPercentage!=0">
                                            <div class="progress-bar progress-bar-striped bg-info" role="progressbar" :style="'width: '+uploadPercentage+'%'" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100">{{uploadPercentage}}%</div>
                                        </div>
                                        <a v-if="fotoPerfilPreview!=null" href="#" class="btnEliminarImagen" @click="deleteImage(fotoPerfilPreview.id_perfilimagen)"><i class="fas fa-times"></i></a>
                                        <img v-if="fotoPerfilPreview!=null" :src="ruta_publica+'imgPerfilUsuarios/'+fotoPerfilPreview.nombre" alt="sin imagen" class="img-thumbnail fotoPerfil">
                                        <input type="hidden" v-model="administrador.nombre_fotoperfil">
                                    </div>
                                </div>
                            </div>
                        </template>
                        <template v-slot:footer>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="cerrarVentanaNuevoUsuario(fotoPerfilPreview.id_perfilimagen)">Cerrar</button>
                            <button type="submit" class="btn btn-primary">Guardar</button>
                        </template>
                    </Modal>
                </form>
                <!-- Modal edita datos Administrador -->
                <form @submit.prevent="editaAdministrador(administrador.id_administrador)">
                    <Modal titulo="Edita Administrador" idModal="modalEditaAdministrador" icono="fas fa-user-edit">
                        <template v-slot:body>
                            <div class="container-fluid">
                                <div class="row">
                                    <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Ap. Paterno</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.paterno">
                                            <ListErrors :errores="errores.paterno"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Ap. Materno</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.materno">
                                            <ListErrors :errores="errores.materno"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Primer Nombre</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.primer_nombre">
                                            <ListErrors :errores="errores.primer_nombre"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Segundo Nombre</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.segundo_nombre">
                                            <ListErrors :errores="errores.segundo_nombre"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Usuario</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.nombre_usuario">
                                            <ListErrors :errores="errores.nombre_usuario"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Dirección</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.direccion">
                                            <ListErrors :errores="errores.direccion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Fecha Nacimiento</label>
                                            <!-- <input type="date" class="form-control" v-model="administrador.fecha_nac"> -->
                                            <flat-pickr
                                                    v-model="administrador.fecha_nac"                                                       
                                                    class="form-control input-style"
                                                    :config="config"
                                                    >
                                            </flat-pickr>
                                            <ListErrors :errores="errores.fecha_nac"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Email</label>
                                            <input type="email" class="form-control input-style" v-model="administrador.email">
                                            <ListErrors :errores="errores.email"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Sexo</label>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="sexo" v-model="administrador.sexo" value="1" ref="sexoMasculino">
                                                <label class="form-check-label" for="exampleRadios1">
                                                    Masculino
                                                </label>
                                            </div>
                                            <div class="form-check">
                                                <input class="form-check-input" type="radio" name="sexo" v-model="administrador.sexo" value="0" ref="sexoFemenino">
                                                <label class="form-check-label" for="exampleRadios1">
                                                    Femenino
                                                </label>
                                            </div>
                                            <ListErrors :errores="errores.sexo"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Restaurante</label>
                                            <select class="form-control input-style" v-model="administrador.id_restaurant">
                                                <option value="-1" selected>Seleccionar...</option>
                                                <option v-for="restaurante in Restaurantes" v-bind:key="restaurante.id_restaurant" :value="restaurante.id_restaurant">{{restaurante.nombre}}</option>
                                            </select>
                                            <ListErrors :errores="errores.id_restaurant"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">DNI</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.dni">
                                            <ListErrors :errores="errores.dni"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Celular</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.celular">
                                            <ListErrors :errores="errores.celular"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Telefono</label>
                                            <input type="text" class="form-control input-style" v-model="administrador.telefono">
                                            <ListErrors :errores="errores.telefono"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <div class="form-group">
                                            <label for="" class="label-style">Foto Perfil</label>
                                            <input type="file" :class="{disabled: fotoPerfilPreview!=null}" class="form-control-file input-style" @change="imageChanged" ref="fileImage">
                                            <ListErrors :errores="errores.nombre_fotoperfil"></ListErrors>
                                        </div>
                                    </div>
                                    <div class="col-md-6 my-auto">
                                        <!-- Edita imagen -->
                                        <div class="progress" v-if="uploadPercentage!=0">
                                            <div class="progress-bar progress-bar-striped bg-info" role="progressbar" :style="'width: '+uploadPercentage+'%'" aria-valuenow="50" aria-valuemin="0" aria-valuemax="100">{{uploadPercentage}}%</div>
                                        </div>
                                        <a v-if="fotoPerfilPreview!=null" href="#" class="btnEliminarImagen" @click="deleteImage(fotoPerfilPreview.id_perfilimagen)"><i class="fas fa-times"></i></a>
                                        <img v-if="fotoPerfilPreview!=null" :src="ruta_publica+'imgPerfilUsuarios/'+fotoPerfilPreview.nombre" alt="sin imagen" class="img-thumbnail fotoPerfil">
                                        <input type="hidden" v-model="administrador.nombre_fotoperfil">
                                    </div>
                                </div>
                            </div>
                        </template>
                        <template v-slot:footer>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaAdministrador">Cerrar</button>
                            <button type="submit" class="btn btn-primary">Guardar</button>
                        </template>
                    </Modal>
                </form>
            </div>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Modal from '@/components/Modal/Modal';
import BoxMessage from '@/components/Messages/BoxMessage';
import ListErrors from '@/components/Messages/ListErrors';
import Pagination from '@/components/Pagination/Pagination';
import Marco from '@/components/Layout//Marco';
import flatPickr from 'vue-flatpickr-component';
import 'flatpickr/dist/flatpickr.css';
import {Hindi} from 'flatpickr/dist/l10n/hi';
import {misMixins} from '@/mixins/misMixins.js';

export default{
    name: 'Administrador',
    components: {
        Modal,
        BoxMessage,
        ListErrors,
        Pagination,
        Marco,
        flatPickr
    },
    created () {
        this.$Progress.start()
        this.datosAdministrador();
        this.getAllRestaurantes();//Combo de restaurantes
        //Obtiene datos del usuario
        this.getDataUser(3).then(response => {
            this.data_usr = response.data;
        }).catch(error => {
            console.log(error)
        });
        this.$Progress.finish()
    },
    data() {
        return {
            listaAdministradores: [],
            administrador: {
                id_restaurant: -1,
            },
            Restaurantes: [],
            nuevoAdministradorMsg: '',
            datosRepetidos: '',
            errores: {},
            restaurantEstado: null,
            pagination: {},
            nro_page: 3,
            administradoresActivos: 0,
            ruta_publica: this.$store.state.url_root,
            fotoPerfilPreview: null,
            uploadPercentage: 0,
            // Initial value
            date: new Date(),
            config: {
                wrap: true, // set wrap to true only when using 'input-group'
                altFormat: 'j/n/Y',
                altInput: true,
                dateFormat: 'Y-m-d',
                allowInput: true,
                wrap: false,
                static: true     
            },
            data_usr: {}
        }
    },
    mixins: [misMixins],
    methods: {
        datosAdministrador(url) {
            this.$Progress.start()
            this.listaAdministradores = [];
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            url = url || this.$store.state.url_root+`api/auth/administrador/page/${this.nro_page}`;
            axios.get(url)
            .then(response => {
                this.listaAdministradores = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$Progress.fail()
                alert("restaurantes.vue: "+error)
            });
        },
        limpiaAdministrador(){
            this.administrador = {
                id_restaurant: -1
            },
            //this.nuevoAdministradorMsg = '';
            this.datosRepetidos = '';
            this.errores = {};
            this.$refs.sexoMasculino.checked = false;
            this.$refs.sexoFemenino.checked = false;
            if(this.fotoPerfilPreview != null){
                this.fotoPerfilPreview = null
            }
        },
        nuevoAdministrador(){
            this.$Progress.start()
            this.errores = {}
            this.administrador.id_superadministrador = this.data_usr.id_superadministrador;
            this.administrador.tipo_usuario = '2';
            this.administrador.nombre_fotoperfil = this.fotoPerfilPreview!=null? this.fotoPerfilPreview.nombre: null;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(this.$store.state.url_root+"api/auth/administrador", this.administrador)
            .then(response => {
                if(response.data.error == null){
                    //Cargar la imagen de perfil
                    if(this.fotoPerfilPreview != null){
                        axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                        axios.put(this.$store.state.url_root+`api/auth/imageupload/${this.fotoPerfilPreview.id_perfilimagen}/usuario/${response.data.data.id_administrador}/tipo/0`)
                        .then(response => {
                            console.log(response.data.data);
                        })
                        .catch (error => {
                            this.$Progress.fail()
                            alert("Administrador.vue: "+error)
                        });
                    }
                    this.datosAdministrador();
                    window.$("#modalNuevoAdministrador").modal('hide');
                    this.limpiaAdministrador();
                    this.nuevoAdministradorMsg = `El Administrador <strong>${response.data.data.nombre_usuario}</strong> se guardo correctamente`
                }else{
                    this.errores = response.data.error
                }
                this.$Progress.finish()
            })
            .catch (error => {
                this.$Progress.fail()
                alert("Administrador.vue: "+error)
            });
        },
        getDatosAdministrador(id){
            this.$Progress.start()
            this.limpiaAdministrador();
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+"api/auth/administrador/"+id)
            .then(response => {
                this.administrador = response.data.data;
                if(this.administrador.nombre_fotoperfil != null){
                    axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                    axios.get(this.$store.state.url_root+`api/auth/imageupload/${this.administrador.id_administrador}/tipo/0`)
                    .then(response => {
                        if(response.data.data!=0){
                            this.fotoPerfilPreview = response.data.data
                        }
                    })
                    .catch(error => {
                        alert('Administrador.vue: '+error)
                    })
                }
                if(this.administrador.sexo){
                    this.$refs.sexoMasculino.checked = true;
                }else{
                    this.$refs.sexoFemenino.checked = true;
                }
                this.$Progress.finish()
            })
            .catch (error => {
                this.$Progress.fail()
                alert("Administrador.vue: "+error)
            });
        },
        editaAdministrador(id){
            this.$Progress.start()
            this.errores = {}
            this.administrador.nombre_fotoperfil = this.fotoPerfilPreview!=null? this.fotoPerfilPreview.nombre: null;
            this.administrador.id_superadministrador = this.data_usr.id_superadministrador;
            this.administrador.tipo_usuario = '2';
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.put(this.$store.state.url_root+"api/auth/administrador/"+id, this.administrador)
            .then(response => {
                if(response.data.error == null){
                    //Cargar la imagen de perfil
                    if(this.fotoPerfilPreview != null){
                        axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                        axios.put(this.$store.state.url_root+`api/auth/imageupload/${this.fotoPerfilPreview.id_perfilimagen}/usuario/${response.data.data.id_administrador}/tipo/0`)
                        .then(response => {
                            console.log(response.data.data);
                        })
                        .catch (error => {
                            this.$Progress.fail()
                            alert("Administrador.vue: "+error)
                        });
                    }
                    this.datosAdministrador(this.$store.state.url_root+`api/auth/administrador/page/${this.nro_page}?page=${this.pagination.current_page}`);
                    window.$("#modalEditaAdministrador").modal('hide');
                    this.limpiaAdministrador();
                    this.nuevoAdministradorMsg = `El administrador <strong>${response.data.data.nombre_usuario}</strong> se actualizo correctamente`
                }else{
                    if(response.data.error.valores != null){
                        this.datosRepetidos = response.data.error.valores;
                    }else{
                        this.errores = response.data.error;
                    }
                }
                this.$Progress.finish()
            })
            .catch (error => {
                this.$Progress.fail()
                alert("Administrador.vue: "+error)
            });
        },
        cambiaEstado(){
            if(this.$refs.estadoAdministrador.checked){
                this.$refs.estadoAdministrador.value = true
            }else{
                this.$refs.estadoAdministrador.value = false
            }
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.datosAdministrador();
        },
        getAllRestaurantes(){
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/restaurantall`)
            .then(response => {
                this.Restaurantes = response.data.data;
            })
            .catch (error => {
                alert("Administrador.vue: "+error)
            });
        },
        mostrarPorRestaurante(){
            this.listaAdministradores = [];
            if(this.$refs.selectMostrarPorRestaurante.value != -1){
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/administrador/restaurant/${this.nro_page}/${this.$refs.selectMostrarPorRestaurante.value}`)
                .then(response => {
                    this.listaAdministradores = response.data.data.data;
                    this.pagination = response.data.data;
                })
                .catch (error => {
                    alert("Administrador.vue: "+error)
                });
            }
            else{
                this.datosAdministrador();
            }   
        },
        cerrarVentanaNuevoUsuario(id_imagen){
            this.deleteImage(id_imagen)
            this.limpiaAdministrador()
        },
        imageChanged(e){
            console.log(e.target.files[0])
            this.administrador.image = e.target.files[0];
            console.log(typeof e.target.files[0])
            let nomArchivoArray = this.administrador.image.name.split(".")
            let extension = nomArchivoArray[nomArchivoArray.length-1];
            if(extension == 'jpg' || extension == 'jpeg' || extension == 'png'){
                let formData = new FormData();
                formData.append('image', this.administrador.image);
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.defaults.headers.common["Content-Type"] = "multipart/form-data";
                axios.post(this.$store.state.url_root+"api/auth/imageupload", 
                    formData,
                    {
                        onUploadProgress: function( uploadEvent ) {
                            this.uploadPercentage = parseInt(Math.round((uploadEvent.loaded/uploadEvent.total)*100));
                        }.bind(this)
                    }
                )
                .then(response => {
                    if(response.data.error == null){
                        this.fotoPerfilPreview = response.data.data;
                        this.uploadPercentage = 0;
                        this.errores.nombre_fotoperfil = [];
                    }else{
                        this.errores = response.data.error
                    }
                })
                .catch (error => {
                    alert("Administrador.vue: "+error)
                });
            }
            else{
                this.errores = {"nombre_fotoperfil":["La imagen no tiene el formato correcto"]}
            }
        },
        deleteImage(id){
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.delete(this.$store.state.url_root+"api/auth/imageupload/"+id)
            .then(response => {
                this.fotoPerfilPreview = null;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$Progress.fail()
                alert("Administrador.vue: "+error)
            });
        }
    },
}
</script>
<style lang="scss">
    .fotoPerfil{
        width: inherit;
    }
</style>