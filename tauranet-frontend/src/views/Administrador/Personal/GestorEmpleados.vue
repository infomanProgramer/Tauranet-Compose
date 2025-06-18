<template>
    <Marco titulo="Gestor de Empleados" icono="fas fa-table">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <label for="">
                            Entradas
                            <select id="nroEntradas" @change="cambiaOption" ref="nroEntradas">
                                <option>5</option>
                                <option>10</option>
                                <option>20</option>
                            </select>
                    </label>
                </div>
                <div class="col-md-6">
                    <div class="form-group">               
                        <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevoPersonal"><i class="fas fa-plus"></i> Nuevo</button>
                    </div>
                </div>
            </div>
            <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                        <label for="">
                                Sucursal
                                <select class="form-control" v-model="ListaSucursal" @change="filtraPersonal()">
                                    <option value="-1" selected>Seleccionar...</option>
                                    <option v-for="s in listaSucursales" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                                </select>
                        </label>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="form-group">
                        <label for="">
                                Perfil
                                <select class="form-control" v-model="ListaPorPerfil" @change="filtraPersonal()">
                                    <option value="-1" selected>Seleccionar...</option>
                                    <option value="1">Cajero</option>
                                    <option value="0">Mozo</option>
                                    <option value="4">Cocinero</option>
                                </select>
                        </label>
                        </div>
                    </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <BoxMessage :message="nuevoPersonalMsg" :cod="'su'" icono="fas fa-check"></BoxMessage>
                    <div class="table-responsive">
                        <table-component
                            :data="listaPersonal"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombresucursal" label="Sucursal"></table-column>   
                            <table-column show="nombre_usuario" label="Usuario"></table-column>
                            <table-column show="dni" :label="getIdentificacion"></table-column>
                            <table-column show="nombre_completo" label="Empleado"></table-column>
                            <table-column show="perfil" label="Perfil"></table-column>
                            <table-column label="Estado" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <div class="form-check">
                                        <input type="checkbox" class="form-check-input" v-if="row.estado" checked disabled>
                                        <input type="checkbox" class="form-check-input" v-else disabled>
                                    </div>
                                </template>
                            </table-column>
                            <table-column label="Editar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaPersonal" @click="getDatosPersonal(row.id_usuario, row.tipo_usuario)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                            <table-column label="Eliminar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-danger" @click="eliminarPersonal(row.id_usuario, row.tipo_usuario, row.nombre_usuario)"><i class="fas fa-trash-alt"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="filtraPersonal"></Pagination>
                </div>
            </div>
            <!-- Ventanas modales -->
            <form @submit.prevent="nuevoPersonal()">
                <Modal titulo="Registro de empleado" idModal="modalNuevoPersonal" icono="fas fa-user-plus">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Ap. Paterno</label>
                                        <input type="text" class="form-control input-style" v-model="personal.paterno" placeholder="Ap. Paterno">
                                        <ListErrors :errores="errores.paterno"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Ap. Materno</label>
                                        <input type="text" class="form-control input-style" v-model="personal.materno" placeholder="Ap. Materno">
                                        <ListErrors :errores="errores.materno"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Primer Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="personal.primer_nombre" placeholder="Primer Nombre">
                                        <ListErrors :errores="errores.primer_nombre"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Segundo Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="personal.segundo_nombre" placeholder="Segundo Nombre">
                                        <ListErrors :errores="errores.segundo_nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Contraseña</label>
                                        <input type="password" class="form-control input-style" v-model="personal.password" placeholder="Contraseña">
                                        <ListErrors :errores="errores.password"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Confirmar contraseña</label>
                                        <input type="password" class="form-control input-style" v-model="personal.password_confirmation" placeholder="Confirmar contraseña">
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Usuario</label>
                                        <input type="text" class="form-control input-style" v-model="personal.nombre_usuario" placeholder="Usuario">
                                        <ListErrors :errores="errores.nombre_usuario"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sueldo</label>
                                        <input type="number" class="form-control input-style" v-model="personal.sueldo" :placeholder="'Sueldo ('+tipoMoneda+')'" min="0" step="1"/>
                                        <ListErrors :errores="errores.sueldo"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Fecha Nacimiento</label>
                                        <flat-pickr
                                                v-model="personal.fecha_nac"                                                       
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
                                        <label for="" class="label-style">Email</label>
                                        <input type="email" class="form-control input-style" v-model="personal.email" placeholder="Email">
                                        <ListErrors :errores="errores.email"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sexo</label>
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="sexo" v-model="personal.sexo" id="checkMozo" value="1" :checked=true>
                                            <label class="form-check-label" for="exampleRadios1">
                                                Masculino
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="sexo" v-model="personal.sexo" id="checkCajero" value="0">
                                            <label class="form-check-label" for="exampleRadios1">
                                                Femenino
                                            </label>
                                        </div>
                                        <ListErrors :errores="errores.sexo"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">{{getIdentificacion}}</label>
                                        <input type="text" class="form-control input-style" v-model="personal.dni" :placeholder="getIdentificacion">
                                        <ListErrors :errores="errores.dni"></ListErrors>
                                    </div>
                                    <div class="form-group">
                                        <label for="" class="label-style">* Perfil</label>
                                        <select class="form-control input-style" v-model="personal.tipo_usuario" @change="mtipoCajero()">
                                            <option value="-1" selected>Perfil...</option>
                                            <option value="1">Cajero</option>
                                            <option value="0">Mozo</option>
                                            <option value="4">Cocinero</option>
                                        </select>
                                        <ListErrors :errores="errores.tipo_usuario"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sucursal</label>
                                        <select class="form-control input-style" v-model="personal.id_sucursal" @change="cargaComboCajas(personal.id_sucursal)">
                                            <option value="-1" selected>Sucursal...</option>
                                            <option v-for="s in listaSucursales" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_sucursal"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group" v-if="personal.tipo_usuario == 1">
                                        <label for="" class="label-style">* Caja</label>
                                        <select class="form-control input-style" v-model="personal.id_caja">
                                            <option value="-1" selected>Caja...</option>
                                            <option v-for="c in listaCajas" v-bind:key="c.id_caja" :value="c.id_caja">{{c.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_caja"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Celular</label>
                                        <input type="text" class="form-control input-style" v-model="personal.celular" placeholder="Celular">
                                        <ListErrors :errores="errores.celular"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Telefono</label>
                                        <input type="text" class="form-control input-style" v-model="personal.telefono" placeholder="Telefono">
                                        <ListErrors :errores="errores.telefono"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Direcciön</label>
                                        <input type="text" class="form-control input-style" v-model="personal.direccion" placeholder="Direcciön">
                                        <ListErrors :errores="errores.direccion"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaPersonal">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="nuevoPersonalBtn">Guardar</button>
                    </template>
                </Modal>
            </form>
            <form @submit.prevent="editaPersonal(personal.id_usuario, personal.tipo_usuario)">
                <Modal titulo="Edita empleado" idModal="modalEditaPersonal" icono="fas fa-user-edit">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Ap. Paterno</label>
                                        <input type="text" class="form-control input-style" v-model="personal.paterno">
                                        <ListErrors :errores="errores.paterno"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Ap. Materno</label>
                                        <input type="text" class="form-control input-style" v-model="personal.materno">
                                        <ListErrors :errores="errores.materno"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Primer Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="personal.primer_nombre">
                                        <ListErrors :errores="errores.primer_nombre"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Segundo Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="personal.segundo_nombre">
                                        <ListErrors :errores="errores.segundo_nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Usuario</label>
                                        <input type="text" class="form-control input-style" v-model="personal.nombre_usuario">
                                        <ListErrors :errores="errores.nombre_usuario"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sueldo ({{tipoMoneda}})</label>
                                        <input type="number" class="form-control input-style" v-model="personal.sueldo" min="0" step="1"/>
                                        <ListErrors :errores="errores.sueldo"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Fecha Nacimiento</label>
                                        <flat-pickr
                                                v-model="personal.fecha_nac"                                                       
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
                                        <input type="email" class="form-control input-style" v-model="personal.email">
                                        <ListErrors :errores="errores.email"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sexo</label>
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="sexo" v-model="personal.sexo" id="checkMozo2" value="1" ref="sexoMasculino">
                                            <label class="form-check-label" for="exampleRadios1">
                                                Masculino
                                            </label>
                                        </div>
                                        <div class="form-check">
                                            <input class="form-check-input" type="radio" name="sexo" v-model="personal.sexo" id="checkCajero2" value="0" ref="sexoFemenino">
                                            <label class="form-check-label" for="exampleRadios1">
                                                Femenino
                                            </label>
                                        </div>
                                        <ListErrors :errores="errores.sexo"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">{{getIdentificacion}}</label>
                                        <input type="text" class="form-control input-style" v-model="personal.dni">
                                        <ListErrors :errores="errores.dni"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                        <label for="" class="label-style">* Estado</label>
                                </div>
                                <div class="col-md-6">
                                    <input type="checkbox" class="form-check-input" v-model="personal.estado" ref="estadoEmpleado">
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sucursal</label>
                                        <select class="form-control input-style" v-model="personal.id_sucursal" @change="cargaComboCajas(personal.id_sucursal)">
                                            <option value="-1" selected>Seleccionar...</option>
                                            <option v-for="s in listaSucursales" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_sucursal"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group" v-if="personal.tipo_usuario == 1">
                                        <label for="" class="label-style">* Caja</label>
                                        <select class="form-control input-style" v-model="personal.id_caja">
                                            <option value="-1" selected>Seleccionar...</option>
                                            <option v-for="c in listaCajas" v-bind:key="c.id_caja" :value="c.id_caja">{{c.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_caja"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Celular</label>
                                        <input type="text" class="form-control input-style" v-model="personal.celular">
                                        <ListErrors :errores="errores.celular"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Telefono</label>
                                        <input type="text" class="form-control input-style" v-model="personal.telefono">
                                        <ListErrors :errores="errores.telefono"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Dirección</label>
                                        <input type="text" class="form-control input-style" v-model="personal.direccion">
                                        <ListErrors :errores="errores.direccion"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaPersonal">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="editaPersonalBtn">Guardar</button>
                    </template>
                </Modal>
            </form>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Pagination from '@/components/Pagination/Pagination';
import Modal from '@/components/Modal/Modal';
import Marco from '@/components/Layout/Marco';
import {misMixins} from '@/mixins/misMixins.js';
import ListErrors from '@/components/Messages/ListErrors';
import BoxMessage from '@/components/Messages/BoxMessage';
import flatPickr from 'vue-flatpickr-component';
export default{
    name: 'GestorEmpleados',
    components: {
        Pagination,
        Marco,
        Modal,
        ListErrors,
        BoxMessage,
        flatPickr
    },
    created () {
        this.listaSucursalesMethod();//Carga combo sucursales
        this.filtraPersonal()
        this.$Progress.start()
        this.getDataUser(2).then(response => {
            this.data_usr = response.data
            // this.getDataRestaurante(2, this.data_usr.id_administrador).then(res => {
            //     console.log(res.data.data)
            // }).catch(err=>{
            //     this.$toasted.show(error, {type: 'error'})
            //     this.$Progress.fail()
            // })
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    data() {
        return {
            listaSucursales: [],
            listaPersonal: [],
            listaCajas: [],
            pagination: {},
            personal:{
                id_sucursal: -1,
                tipo_usuario: -1    
            },
            data_usr: {},
            errores: {},
            nro_page: 5,
            nuevoPersonalMsg: '',
            datosRepetidos: '',
            ListaSucursal: -1,
            ListaPorPerfil: -1,
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
        }
    },
    mixins: [misMixins],
    computed: {
        tipoMoneda() {
            return this.$store.state.restauranteData.tipo_moneda
        },
        getIdentificacion(){
            return this.$store.state.restauranteData.identificacion
        }
    },
    methods: {
        listaSucursalesMethod(){
            //this.$Progress.start() comentado a proposito
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/sucursalcombo/${this.$store.state.id_restaurant}`)
            .then(response => {
                this.listaSucursales = response.data.data;
                //this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                //this.$Progress.fail()
            });
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.filtraPersonal()
        },
        getDatosPersonal(idPersonal, tipoUsuario){
            this.$Progress.start()
            this.personal.id_administrador = this.data_usr.id_administrador
             axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            if(tipoUsuario == 0){
                //Mozo
                 axios.get(this.$store.state.url_root+`api/auth/mozo/${idPersonal}`)
                .then(response => {
                    this.personal = response.data.data[0]
                    if(this.personal.sexo){
                        this.$refs.sexoMasculino.checked = true;
                    }else{
                        this.$refs.sexoFemenino.checked = true;
                    }
                    this.$refs.estadoEmpleado.checked = this.personal.estado
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }else if(tipoUsuario == 1){
                //Cajero
                 axios.get(this.$store.state.url_root+`api/auth/cajero/${idPersonal}`)
                .then(response => {
                    this.personal = response.data.data[0]
                    this.cargaComboCajas(this.personal.id_sucursal)
                    if(this.personal.sexo){
                        this.$refs.sexoMasculino.checked = true;
                    }else{
                        this.$refs.sexoFemenino.checked = true;
                    }
                    this.$refs.estadoEmpleado.checked = this.personal.estado
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }if(tipoUsuario == 4){
                //Cocinero
                 axios.get(this.$store.state.url_root+`api/auth/cocinero/${idPersonal}`)
                .then(response => {
                    this.personal = response.data.data[0]
                    this.cargaComboCajas(this.personal.id_sucursal)
                    if(this.personal.sexo){
                        this.$refs.sexoMasculino.checked = true;
                    }else{
                        this.$refs.sexoFemenino.checked = true;
                    }
                    this.$refs.estadoEmpleado.checked = this.personal.estado
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }else{
                this.errores = {"tipo_usuario": ["El tipo de usuario es requerido"]};
                this.$Progress.fail()
            }
        },
        nuevoPersonal(){
            this.$refs.nuevoPersonalBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.personal.id_administrador = this.data_usr.id_administrador
             axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            if(this.personal.tipo_usuario == 0){
                //Mozo
                 axios.post(this.$store.state.url_root+`api/auth/mozo`, this.personal)
                .then(response => {
                    if(response.data.error == null){
                        this.filtraPersonal()
                        window.$("#modalNuevoPersonal").modal('hide');
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El mozo <strong>${response.data.data.nombre_usuario}</strong> se creo correctamente`
                        this.$Progress.finish()
                    }else{
                        if(response.data.error.limite_mozos == null){
                            this.errores = response.data.error
                        }else{
                            this.datosRepetidos = response.data.error.limite_mozos
                        }
                        this.$Progress.fail()
                    }
                    this.$refs.nuevoPersonalBtn.className = "btn btn-primary"
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.nuevoPersonalBtn.className = "btn btn-primary"
                });
            }else if(this.personal.tipo_usuario == 1){
                //Cajero
                 axios.post(this.$store.state.url_root+`api/auth/cajero`, this.personal)
                .then(response => {
                    if(response.data.error == null){
                        this.filtraPersonal()
                        window.$("#modalNuevoPersonal").modal('hide');
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El cajero <strong>${response.data.data.nombre_usuario}</strong> se creo correctamente`
                        this.$Progress.finish()
                    }else{
                        if(response.data.error.limite_cajeros == null){
                            this.errores = response.data.error
                        }else{
                            this.datosRepetidos = response.data.error.limite_cajeros
                        }
                        this.$Progress.fail()
                    }
                    this.$refs.nuevoPersonalBtn.className = "btn btn-primary"
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.nuevoPersonalBtn.className = "btn btn-primary"
                });
            }else if(this.personal.tipo_usuario == 4){
                //Cocinero
                 axios.post(this.$store.state.url_root+`api/auth/cocinero`, this.personal)
                .then(response => {
                    if(response.data.error == null){
                        this.filtraPersonal()
                        window.$("#modalNuevoPersonal").modal('hide');
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El cocinero <strong>${response.data.data.nombre_usuario}</strong> se creo correctamente`
                        this.$Progress.finish()
                    }else{
                        if(response.data.error.limite_cocineros == null){
                            this.errores = response.data.error
                        }else{
                            this.datosRepetidos = response.data.error.limite_cocineros
                        }
                        this.$Progress.fail()
                    }
                    this.$refs.nuevoPersonalBtn.className = "btn btn-primary"
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.nuevoPersonalBtn.className = "btn btn-primary"
                });
            }else{
                this.errores = {"tipo_usuario": ["El tipo de usuario es requerido"]};
                this.$Progress.fail()
                this.$refs.nuevoPersonalBtn.className = "btn btn-primary"
            }
        },
        editaPersonal(idPersonal, tipoUsuario){
            this.$refs.editaPersonalBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.personal.estado = this.$refs.estadoEmpleado.checked
            this.personal.id_administrador = this.data_usr.id_administrador
             axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            if(tipoUsuario == 0){
                //Mozo
                 axios.put(this.$store.state.url_root+`api/auth/mozo/${idPersonal}`, this.personal)
                .then(response => {
                    if(response.data.error == null){
                        this.filtraPersonal(this.$store.state.url_root+`api/auth/personal/${this.$store.state.id_restaurant}/page/${this.nro_page}/sucursal/${this.ListaSucursal}/perfil/${this.ListaPorPerfil}?page=${this.pagination.current_page}`)
                        window.$("#modalEditaPersonal").modal('hide');
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El mozo <strong>${response.data.data.nombre_usuario}</strong> se actualizo correctamente`
                        this.$Progress.finish()
                    }else{
                        if(response.data.error.valores != null){
                            this.datosRepetidos = response.data.error.valores;
                        }else{
                            this.errores = response.data.error;
                        }
                        this.$Progress.fail()
                    }
                    this.$refs.editaPersonalBtn.className = "btn btn-primary"
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.editaPersonalBtn.className = "btn btn-primary"
                });
            }else if(tipoUsuario == 1){
                //Cajero
                 axios.put(this.$store.state.url_root+`api/auth/cajero/${idPersonal}`, this.personal)
                .then(response => {
                    if(response.data.error == null){
                        this.filtraPersonal(this.$store.state.url_root+`api/auth/personal/${this.$store.state.id_restaurant}/page/${this.nro_page}/sucursal/${this.ListaSucursal}/perfil/${this.ListaPorPerfil}?page=${this.pagination.current_page}`)
                        window.$("#modalEditaPersonal").modal('hide');
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El cajero <strong>${response.data.data.nombre_usuario}</strong> se actualizo correctamente`
                        this.$Progress.finish()
                    }else{
                        if(response.data.error.limite_cajeros != null){
                            this.datosRepetidos = response.data.error.limite_cajeros;
                        }else{
                            if(response.data.error.valores != null){
                                this.datosRepetidos = response.data.error.valores;
                            }else{
                                this.errores = response.data.error;
                            }
                        }
                        this.$Progress.fail()
                    }
                    this.$refs.editaPersonalBtn.className = "btn btn-primary"
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.editaPersonalBtn.className = "btn btn-primary"
                });
            } if(tipoUsuario == 4){
                //Cocinero
                 axios.put(this.$store.state.url_root+`api/auth/cocinero/${idPersonal}`, this.personal)
                .then(response => {
                    if(response.data.error == null){
                        this.filtraPersonal(this.$store.state.url_root+`api/auth/personal/${this.$store.state.id_restaurant}/page/${this.nro_page}/sucursal/${this.ListaSucursal}/perfil/${this.ListaPorPerfil}?page=${this.pagination.current_page}`)
                        window.$("#modalEditaPersonal").modal('hide');
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El cocinero <strong>${response.data.data.nombre_usuario}</strong> se actualizo correctamente`
                        this.$Progress.finish()
                    }else{
                        if(response.data.error.limite_cajeros != null){
                            this.datosRepetidos = response.data.error.limite_cajeros;
                        }else{
                            if(response.data.error.valores != null){
                                this.datosRepetidos = response.data.error.valores;
                            }else{
                                this.errores = response.data.error;
                            }
                        }
                        this.$Progress.fail()
                    }
                    this.$refs.editaPersonalBtn.className = "btn btn-primary"
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.editaPersonalBtn.className = "btn btn-primary"
                });
            }else{
                this.errores = {"tipo_usuario": ["El tipo de usuario es requerido"]};
                this.$Progress.fail()
                this.$refs.editaPersonalBtn.className = "btn btn-primary"
            }
        },
        limpiaPersonal(){
            this.personal = {
                id_sucursal: -1,
                tipo_usuario: -1    
            }
            this.nuevoPersonalMsg = ''
            this.errores = {}
            this.datosRepetidos = ''
        },
        filtraPersonal(url){
            this.$Progress.start()
            url = url || this.$store.state.url_root+`api/auth/personal/${this.$store.state.id_restaurant}/page/${this.nro_page}/sucursal/${this.ListaSucursal}/perfil/${this.ListaPorPerfil}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaPersonal = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        mtipoCajero(){
            this.personal.id_caja = -1;            
        },
        cargaComboCajas(id_sucursal){
            //this.$Progress.start()
            this.listaCajas = []
            //this.personal.id_caja = -1;
            if(this.personal.tipo_usuario == 1){
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                    axios.get(this.$store.state.url_root+`api/auth/allcajas/${id_sucursal}`)
                .then(response => {
                    this.listaCajas = response.data.data;
                    //this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    //this.$Progress.fail()
                });
            }
        },
        eliminarPersonal(idPersonal, tipoUsuario, nomUsuario){
            let sw = confirm(`Desea eliminar el usuario ${nomUsuario}`)
            if(sw){
                this.$Progress.start()
                if(tipoUsuario == 0){
                    //Mozo
                    let url = this.$store.state.url_root+`api/auth/mozo/${idPersonal}`
                    axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                        axios.delete(url)
                    .then(response => {
                        this.filtraPersonal(this.$store.state.url_root+`api/auth/personal/${this.$store.state.id_restaurant}/page/${this.nro_page}/sucursal/${this.ListaSucursal}/perfil/${this.ListaPorPerfil}?page=${this.pagination.current_page}`)
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El mozo <strong>${nomUsuario}</strong> se elimino correctamente`
                        this.$Progress.finish()
                    })
                    .catch (error => {
                        this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                        this.$Progress.fail()
                    });
                }else if(tipoUsuario == 1){
                    //Cajero
                    let url = this.$store.state.url_root+`api/auth/cajero/${idPersonal}`
                    axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                        axios.delete(url)
                    .then(response => {
                        this.filtraPersonal(this.$store.state.url_root+`api/auth/personal/${this.$store.state.id_restaurant}/page/${this.nro_page}/sucursal/${this.ListaSucursal}/perfil/${this.ListaPorPerfil}?page=${this.pagination.current_page}`)
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El cajero <strong>${nomUsuario}</strong> se elimino correctamente`
                        this.$Progress.finish()
                    })
                    .catch (error => {
                        this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                        this.$Progress.fail()
                    });
                }else if(tipoUsuario == 4){
                    //Cocinero
                    let url = this.$store.state.url_root+`api/auth/cocinero/${idPersonal}`
                    axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                        axios.delete(url)
                    .then(response => {
                        this.filtraPersonal(this.$store.state.url_root+`api/auth/personal/${this.$store.state.id_restaurant}/page/${this.nro_page}/sucursal/${this.ListaSucursal}/perfil/${this.ListaPorPerfil}?page=${this.pagination.current_page}`)
                        this.limpiaPersonal();
                        this.nuevoPersonalMsg = `El cajero <strong>${nomUsuario}</strong> se elimino correctamente`
                        this.$Progress.finish()
                    })
                    .catch (error => {
                        this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                        this.$Progress.fail()
                    });
                }
            }else{
                console.log("no se borro nada")
            }
        }
    },
}
</script>