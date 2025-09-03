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
                        <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevoPersonal" @click="cleanInfoEmployee()"><i class="fas fa-plus"></i> Nuevo</button>
                    </div>
                </div>
            </div>
            <form class="col-md-12" @submit.prevent="getAllEmployees()">
            <div class="row">
                    <div class="col-md-3">
                        <div class="form-group">
                        <label for="">
                                Restaurante
                                <select class="form-control" v-model="IdRestauranteSelectedFromForm" @change="getSucursalByRestaurant(1)">
                                    <option value="-1" selected>Seleccionar...</option>
                                    <option v-for="s in listOfAllRestaurantes" v-bind:key="s.id_restaurant" :value="s.id_restaurant">{{s.nombre}}</option>
                                </select>
                        </label>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="form-group">
                        <label for="">
                                Sucursal
                                <select class="form-control" v-model="IdSucursalSelectedFromForm">
                                    <option value="-1" selected>Seleccionar...</option>
                                    <option v-for="s in listOfSucursalesByRestauranteFromForm" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                                </select>
                        </label>
                        </div>
                    </div>
                    <div class="col-md-3 d-flex align-items-center">
                        <button type="submit" class="btn btn-primary float-right"><i class="fas fa-search"></i> Buscar</button>
                    </div>
                </div>
            </form>
            <div class="row">
                <div class="col-md-12">
                    <BoxMessage :message="nuevoPersonalMsg" :cod="'su'" icono="fas fa-check"></BoxMessage>
                    <div class="table-responsive">
                        <table-component
                            :data="listOfAllEmployees"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombre_restaurante" label="Restaurante"></table-column>  
                            <table-column show="nombre_sucursal" label="Sucursal"></table-column>  
                            <table-column show="nombre_caja" label="Caja"></table-column>   
                            <table-column show="nombre_usuario" label="Usuario"></table-column>
                            <table-column show="nombre_completo" label="Empleado"></table-column>
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
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaPersonal" @click="getInfoEmployeeById(row.id_usuario)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                            <table-column label="Eliminar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-danger" @click="deleteEmployeeById(row.id_usuario, row.nombre_usuario)"><i class="fas fa-trash-alt"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="getAllEmployees"></Pagination>
                </div>
            </div>
            <!-- Ventanas modales -->
            <form @submit.prevent="addNewEmployee()">
                <Modal titulo="Registro de empleado" idModal="modalNuevoPersonal" icono="fas fa-user-plus">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Ap. Paterno</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.paterno" placeholder="Ap. Paterno">
                                        <ListErrors :errores="errores.paterno"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Ap. Materno</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.materno" placeholder="Ap. Materno">
                                        <ListErrors :errores="errores.materno"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Primer Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.primer_nombre" placeholder="Primer Nombre">
                                        <ListErrors :errores="errores.primer_nombre"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Segundo Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.segundo_nombre" placeholder="Segundo Nombre">
                                        <ListErrors :errores="errores.segundo_nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Contraseña</label>
                                        <input type="password" class="form-control input-style" v-model="employeeInfo.password" placeholder="Contraseña">
                                        <ListErrors :errores="errores.password"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Confirmar contraseña</label>
                                        <input type="password" class="form-control input-style" v-model="employeeInfo.password_confirmation" placeholder="Confirmar contraseña">
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Usuario</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.nombre_usuario" placeholder="Usuario">
                                        <ListErrors :errores="errores.nombre_usuario"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Restaurante</label>
                                        <select class="form-control input-style" v-model="employeeInfo.id_restaurant" @change="getSucursalByRestaurant(2)">
                                            <option value="-1" selected>Restaurante...</option>
                                            <option v-for="s in listOfAllRestaurantes" v-bind:key="s.id_restaurant" :value="s.id_restaurant">{{s.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_restaurant"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sucursal</label>
                                        <select class="form-control input-style" v-model="employeeInfo.id_sucursal" @change="getCajaBySucursal(employeeInfo.id_sucursal, 2)">
                                            <option value="-1" selected>Sucursal...</option>
                                            <option v-for="s in listOfSucursalesByRestauranteFromModal" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_sucursal"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Caja</label>
                                        <select class="form-control input-style" v-model="employeeInfo.id_caja">
                                            <option value="-1" selected>Caja...</option>
                                            <option v-for="c in listOfCajasBySucursalFromModal" v-bind:key="c.id_caja" :value="c.id_caja">{{c.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_caja"></ListErrors>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="cleanInfoEmployee">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="nuevoPersonalBtn">Guardar</button>
                    </template>
                </Modal>
            </form>
            <form @submit.prevent="updateInfoEmployee(employeeInfo.id_usuario)">
                <Modal titulo="Edita empleado" idModal="modalEditaPersonal" icono="fas fa-user-edit">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Ap. Paterno</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.paterno">
                                        <ListErrors :errores="errores.paterno"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Ap. Materno</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.materno">
                                        <ListErrors :errores="errores.materno"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Primer Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.primer_nombre">
                                        <ListErrors :errores="errores.primer_nombre"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Segundo Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.segundo_nombre">
                                        <ListErrors :errores="errores.segundo_nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Usuario</label>
                                        <input type="text" class="form-control input-style" v-model="employeeInfo.nombre_usuario">
                                        <ListErrors :errores="errores.nombre_usuario"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Restaurante</label>
                                        <select class="form-control input-style" v-model="employeeInfo.id_restaurant" @change="getSucursalByRestaurant(2)">
                                            <option value="-1" selected>Restaurante...</option>
                                            <option v-for="s in listOfAllRestaurantes" v-bind:key="s.id_restaurant" :value="s.id_restaurant">{{s.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_restaurant"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                        <label for="" class="label-style">* Estado</label>
                                </div>
                                <div class="col-md-6">
                                    <input type="checkbox" class="form-check-input" v-model="employeeInfo.estado" ref="estadoEmpleado">
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sucursal</label>
                                        <select class="form-control input-style" v-model="employeeInfo.id_sucursal" @change="getCajaBySucursal(employeeInfo.id_sucursal, 2)">
                                            <option value="-1" selected>Sucursal...</option>
                                            <option v-for="s in listOfSucursalesByRestauranteFromModal" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_sucursal"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Caja</label>
                                        <select class="form-control input-style" v-model="employeeInfo.id_caja">
                                            <option value="-1" selected>Caja...</option>
                                            <option v-for="c in listOfCajasBySucursalFromModal" v-bind:key="c.id_caja" :value="c.id_caja">{{c.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_caja"></ListErrors>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="cleanInfoEmployee">Cerrar</button>
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
        this.getAllEmployees();
        this.getAllSucursales();//Carga combo sucursales
        this.cargaComboCajas();
        this.getAllRestaurantes();
        this.$Progress.start();
        this.getDataUser(3).then(response => {
            this.userSystemInfo = response.data
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    data() {
        return {
            listOfAllSucursals: [],
            listOfAllEmployees: [],
            listOfAllCajas: [],
            pagination: {},
            employeeInfo:{
                id_restaurant: -1,
                id_sucursal: -1,
                id_caja: -1,
                tipo_usuario: 1   //tipo cajero 
            },
            listOfSucursalesByRestauranteFromForm: [],
            listOfSucursalesByRestauranteFromModal: [],
            listOfCajasBySucursalFromForm: [],
            listOfCajasBySucursalFromModal: [],
            IdRestauranteSelectedFromForm: -1,
            userSystemInfo: {},
            errores: {},
            nro_page: 5,
            nuevoPersonalMsg: '',
            datosRepetidos: '',
            IdSucursalSelectedFromForm: -1,
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
            listOfAllRestaurantes: [],
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
        getCajaBySucursal(id_sucursal, tipo){
            this.employeeInfo.id_caja = -1;
            if(tipo == 1){
                this.listOfCajasBySucursalFromForm = this.listOfAllCajas.filter(c => c.id_sucursal === Number(id_sucursal));
            }else{
                this.listOfCajasBySucursalFromModal = this.listOfAllCajas.filter(c => c.id_sucursal === Number(id_sucursal));
            }
        },
        getSucursalByRestaurant(tipo){
            this.listOfSucursalesByRestauranteFromModal = [];
            this.listOfCajasBySucursalFromModal = [];
            this.IdSucursalSelectedFromForm = -1;
            this.sucursalSelectedModal = -1;
            this.employeeInfo.id_sucursal = -1;
            this.employeeInfo.id_caja = -1;
            if(tipo == 1){
                this.listOfSucursalesByRestauranteFromForm = this.listOfAllSucursals.filter(s => s.id_restaurant === Number(this.IdRestauranteSelectedFromForm));
            }else{
                this.listOfSucursalesByRestauranteFromModal = this.listOfAllSucursals.filter(s => s.id_restaurant === Number(this.employeeInfo.id_restaurant));
            }
        },
        getAllRestaurantes(){
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/restaurantall`)
            .then(response => {
                this.listOfAllRestaurantes = response.data.data;
            })
            .catch (error => {
                alert("GestorEmpleados.vue: "+error)
            });
        },

        getAllSucursales(){
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/sucursalcombo`)
            .then(response => {
                this.listOfAllSucursals = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.getAllEmployees()
        },
        getInfoEmployeeById(idPersonal){
            this.$Progress.start();
            this.cleanInfoEmployee();
            this.employeeInfo.id_administrador = this.userSystemInfo.id_administrador;
             axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            //Cajero
            console.log(`Obtiene los datos de cajero ${idPersonal}`)
                axios.get(this.$store.state.url_root+`api/auth/cajero/${idPersonal}`)
            .then(response => {
                this.employeeInfo = response.data.data[0]
                this.$refs.estadoEmpleado.checked = this.employeeInfo.estado
                this.listOfSucursalesByRestauranteFromModal = this.listOfAllSucursals.filter(s => s.id_restaurant === Number(this.employeeInfo.id_restaurant));
                this.listOfCajasBySucursalFromModal = this.listOfAllCajas.filter(c => c.id_sucursal === Number(this.employeeInfo.id_sucursal));
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });

        },
        addNewEmployee(){
            this.$refs.nuevoPersonalBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.employeeInfo.id_superadministrador = this.userSystemInfo.id_superadministrador
            console.log("this.employeeInfo --> ", this.employeeInfo)
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            console.log(`this.employeeInfo.tipo_usuario --> ${this.employeeInfo.tipo_usuario}`);
            //Cajero
                axios.post(this.$store.state.url_root+`api/auth/cajero`, this.employeeInfo)
            .then(response => {
                if(response.data.error == null){
                    this.getAllEmployees()
                    window.$("#modalNuevoPersonal").modal('hide');
                    this.cleanInfoEmployee();
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
        },
        updateInfoEmployee(idPersonal){
            this.$refs.editaPersonalBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.employeeInfo.estado = this.$refs.estadoEmpleado.checked
            this.employeeInfo.id_superadministrador = this.userSystemInfo.id_superadministrador
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            //Cajero
            axios.put(this.$store.state.url_root+`api/auth/cajero/${idPersonal}`, this.employeeInfo)
            .then(response => {
                if(response.data.error == null){
                    this.getAllEmployees(this.$store.state.url_root+`api/auth/getallcajeros/${this.IdRestauranteSelectedFromForm}/${this.IdSucursalSelectedFromForm}?page=${this.pagination.current_page}`)
                    window.$("#modalEditaPersonal").modal('hide');
                    this.cleanInfoEmployee();
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
        },
        cleanInfoEmployee(){
            this.employeeInfo = {
                id_restaurant: -1,
                id_sucursal: -1,
                id_caja: -1,
                tipo_usuario: 1   //tipo cajero 
            },
            this.nuevoPersonalMsg = ''
            this.errores = {}
            this.datosRepetidos = ''
        },
        getAllEmployees(url){
            this.$Progress.start()
            url = url || this.$store.state.url_root+`api/auth/getallcajeros/${this.IdRestauranteSelectedFromForm}/${this.IdSucursalSelectedFromForm}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listOfAllEmployees = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        mtipoCajero(){
            this.employeeInfo.id_caja = -1;            
        },
        cargaComboCajas(){
            //this.$Progress.start()
            this.listOfAllCajas = []
            //this.employeeInfo.id_caja = -1;
            if(this.employeeInfo.tipo_usuario == 1){
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                    axios.get(this.$store.state.url_root+`api/auth/allcajas`)
                .then(response => {
                    this.listOfAllCajas = response.data.data;
                    //this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    //this.$Progress.fail()
                });
            }
        },
        deleteEmployeeById(idPersonal, nomUsuario){
            let sw = confirm(`Desea eliminar el usuario ${nomUsuario}`)
            if(sw){
                this.$Progress.start()
                //Cajero
                let url = this.$store.state.url_root+`api/auth/cajero/${idPersonal}`
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                    axios.delete(url)
                .then(response => {
                    this.getAllEmployees(this.$store.state.url_root+`api/auth/getallcajeros/${this.IdRestauranteSelectedFromForm}/${this.IdSucursalSelectedFromForm}?page=${this.pagination.current_page}`)
                    this.cleanInfoEmployee();
                    this.nuevoPersonalMsg = `El cajero <strong>${nomUsuario}</strong> se elimino correctamente`
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("GestorEmpleados.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }else{
                this.$toasted.show("GestorEmpleados.vue: No se borro nada", {type: 'error'})
            }
        }
    },
}
</script>