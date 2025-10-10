<template>
    <Marco titulo="Sucursales" icono="fas fa-table">
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
                    <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevoSucursal"><i class="fas fa-plus"></i> Nuevo</button>
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
                    <BoxMessage :message="nuevoSucursalMsg" :cod="'su'" icono="fas fa-check"></BoxMessage>
                    <div class="table-responsive">
                        <table-component
                            :data="listaSucursales"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombreRestaurante" label="Restaurante"></table-column>
                            <table-column show="nombre" label="Sucursal"></table-column>
                            <table-column show="descripcion" label="Descripción"></table-column>
                            <table-column show="direccion" label="Dirección"></table-column>
                            <table-column label="Acciones" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaSucursal" @click="getDatosSucursal(row.id_sucursal)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="datosSucursal"></Pagination>
                </div>
            </div>
            <!-- Ventanas Modales -->
            <div class="row">
                <!-- Modal Nuevo Sucursal         -->
                <form @submit.prevent="nuevoSucursal">
                    <Modal titulo="Registro Sucursal" idModal="modalNuevoSucursal" icono="fas fa-plus">
                        <template v-slot:body>
                            <div class="container-fluid">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="Sucursal.nombre" placeholder="Nombre">
                                            <ListErrors :errores="errores.nombre"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <select class="form-control input-style" v-model="Sucursal.id_restaurant">
                                                <option value="-1" selected>Restaurante...</option>
                                                <option v-for="restaurante in Restaurantes" v-bind:key="restaurante.id_restaurant" :value="restaurante.id_restaurant">{{restaurante.nombre}}</option>
                                            </select>
                                            <ListErrors :errores="errores.id_restaurant"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="Sucursal.descripcion" placeholder="Descripción">
                                            <ListErrors :errores="errores.descripcion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </template>
                        <template v-slot:footer>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaSucursal">Cerrar</button>
                            <button type="submit" class="btn btn-primary" ref="nuevaSucursalBtn">Guardar</button>
                        </template>
                    </Modal>
                </form>
                <!-- Modal edita datos restaurante -->
                <form @submit.prevent="editaSucursal(Sucursal.id_sucursal)">
                    <Modal titulo="Edita Sucursal" idModal="modalEditaSucursal" icono="fas fa-edit">
                        <template v-slot:body>
                            <div class="container-fluid">
                                <div class="row">
                                    <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label for="" class="label-style">Nombre</label>
                                            <input type="text" class="form-control input-style" v-model="Sucursal.nombre">
                                            <ListErrors :errores="errores.nombre"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label for="" class="label-style">Restaurante</label>
                                            <select class="form-control input-style" v-model="Sucursal.id_restaurant">
                                                <option value="-1">Seleccionar...</option>
                                                <option v-for="restaurante in Restaurantes" v-bind:key="restaurante.id_restaurant" :value="restaurante.id_restaurant">{{restaurante.nombre}}</option>
                                            </select>
                                            <ListErrors :errores="errores.id_restaurant"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label for="" class="label-style">Descripción</label>   
                                            <textarea class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="Sucursal.descripcion"></textarea>
                                            <ListErrors :errores="errores.descripcion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </template>
                        <template v-slot:footer>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaSucursal">Cerrar</button>
                            <button type="submit" class="btn btn-primary" ref="editaSucursalBtn">Guardar</button>
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
import {misMixins} from '@/mixins/misMixins.js';
export default{
    name: 'Sucursales',
    components: {
        Modal,
        BoxMessage,
        ListErrors,
        Pagination,
        Marco
    },
    mixins: [misMixins],
    created () {
        this.datosSucursal();
        this.getAllRestaurantes();//Combo de restaurantes
        this.getDataUser(3).then(response => {
            this.data_usr = response.data;
        }).catch(error => {
            console.log(error)
        });
    },
    data() {
        return {
            listaSucursales: [],
            Sucursal: {
                nombre: null,
                descripcion: null,
                direccion: null,
                id_restaurant: -1,
            },
            Restaurantes: [],
            nuevoSucursalMsg: '',
            datosRepetidos: '',
            errores: {},
            restaurantEstado: null,
            pagination: {},
            nro_page: 3,
            sucursalesActivos: 0,
            data_usr: {}
        }
    },
    methods: {
        datosSucursal(url) {
            this.listaSucursales = [];
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            url = url || this.$store.state.url_root+`api/auth/sucursal/all/${this.nro_page}`;
            axios.get(url)
            .then(response => {
                this.listaSucursales = response.data.data.data;
                this.pagination = response.data.data;
            })
            .catch (error => {
                alert("restaurantes.vue: "+error)
            });
        },
        limpiaSucursal(){
            this.restaurant = {};
            this.Sucursal = {
                nombre: null,
                descripcion: null,
                direccion: null,
                id_restaurant: -1,
                id_superadministrador: null,
                estado: null
            },
            this.nuevoSucursalMsg = '';
            this.datosRepetidos = '';
            this.errores = {};
            this.$refs.selectMostrarPorRestaurante.value = -1;
        },
        nuevoSucursal(){
            this.errores = {}
            this.$refs.nuevaSucursalBtn.className = "btn btn-primary disabled"
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            this.Sucursal.id_superadministrador = this.data_usr.id_superadministrador;
            axios.post(this.$store.state.url_root+"api/auth/sucursal", this.Sucursal)
            .then(response => {
                if(response.data.error == null){
                    this.datosSucursal();
                    window.$("#modalNuevoSucursal").modal('hide');
                    this.limpiaSucursal();
                    this.nuevoSucursalMsg = `La sucursal <strong>${response.data.data.nombre}</strong> se creo correctamente`
                    this.$refs.nuevaSucursalBtn.className = "btn btn-primary"
                }else{
                    this.errores = response.data.error
                    this.$refs.nuevaSucursalBtn.className = "btn btn-primary"
                }
            })
            .catch (error => {
                alert("Sucursales.vue: "+error)
            });
        },
        getDatosSucursal(id){
            this.limpiaSucursal();
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+"api/auth/sucursal/"+id)
            .then(response => {
                this.Sucursal = response.data.data;
            })
            .catch (error => {
                alert("Sucursales.vue: "+error)
            });
        },
        editaSucursal(id){
            this.errores = {}
            this.$refs.editaSucursalBtn.className = "btn btn-primary disabled"
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            this.Sucursal.id_superadministrador = this.data_usr.id_superadministrador;
            axios.put(this.$store.state.url_root+"api/auth/sucursal/"+id, this.Sucursal)
            .then(response => {
                if(response.data.error == null){
                    this.datosSucursal(this.$store.state.url_root+`api/auth/sucursal/all/${this.nro_page}?page=${this.pagination.current_page}`);
                    window.$("#modalEditaSucursal").modal('hide');
                    this.limpiaSucursal();
                    this.nuevoSucursalMsg = `La sucursal <strong>${response.data.data.nombre}</strong> se actualizo correctamente`
                    this.$refs.editaSucursalBtn.className = "btn btn-primary"
                }else{
                    if(response.data.error.valores != null){
                        this.datosRepetidos = response.data.error.valores;
                    }else{
                        this.errores = response.data.error;
                    }
                    this.$refs.editaSucursalBtn.className = "btn btn-primary"
                }
            })
            .catch (error => {
                alert("Sucursales.vue: "+error)
            });
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.datosSucursal();
        },
        getAllRestaurantes(){
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/restaurantall`)
            .then(response => {
                this.Restaurantes = response.data.data;
            })
            .catch (error => {
                alert("Sucursales.vue: "+error)
            });
        },
        mostrarPorRestaurante(){
            this.listaSucursales = [];
            if(this.$refs.selectMostrarPorRestaurante.value != -1){
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/sucursal/restaurant/${this.nro_page}/${this.$refs.selectMostrarPorRestaurante.value}`)
                .then(response => {
                    this.listaSucursales = response.data.data.data;
                    this.pagination = response.data.data;
                })
                .catch (error => {
                    alert("Sucursales.vue: "+error)
                });
            }
            else{
                this.datosSucursal();
            }   
        }
    },
}
</script>
<style lang="scss">
    .styleInputMostrarActivos{
        float: right;
    }
</style>
