<template>
    <Marco titulo="Restaurantes" icono="fas fa-table">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                        <label for="">
                            Activos
                            <input type="checkbox" value="" id="defaultCheck1" ref="refInputCheckbox_RestaurantesActivos" @click="eventInputCheckbox_RestaurantesActivos">
                        </label>
                </div>
                <div class="col-md-6">               
                    <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevoRestaurante"><i class="fas fa-plus"></i> Nuevo</button>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <label for="">
                            Entradas
                            <select id="nroEntradas" @change="cambiaOption" ref="nroEntradas">
                                <option>3</option>
                                <option>5</option>
                                <option>10</option>
                            </select>
                    </label>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <BoxMessage :message="nuevoRestaurante" :cod="'su'" icono="fas fa-check"></BoxMessage>
                    <div class="table-responsive">
                        <table-component
                            :data="listaRetaurantes"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombre" label="Nombre"></table-column>
                            <table-column label="Estado" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <div class="form-check">
                                        <input type="checkbox" class="form-check-input" v-if="row.estado" checked disabled>
                                        <input type="checkbox" class="form-check-input" v-else disabled>
                                    </div>
                                </template>
                            </table-column>
                            <table-column show="observacion" label="Observacion"></table-column>
                            <table-column show="tipo_suscripcion" label="Suscripción"></table-column>
                            <table-column show="nombre_usuario" label="Super Admin"></table-column>
                            <table-column label="Acciones" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaRestaurante" @click="getDatosRestaurant(row.id_restaurant)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="datosrestaurant"></Pagination>
                </div>
            </div>
            <!-- Ventanas Modales -->
            <div class="row">
                <!-- Modal Nuevo Restaurante         -->
                <form @submit.prevent="nuevoRestaurant">
                    <Modal titulo="Registro Restaurante" idModal="modalNuevoRestaurante" icono="fas fa-plus">
                        <template v-slot:body>
                            <div class="container-fluid">
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" v-model="restaurant.nombre" placeholder="Nombre">
                                            <ListErrors :errores="errores.nombre"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <input type="hidden" v-model="restaurant.estado" value="true">
                                            <input type="text" class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="restaurant.descripcion" placeholder="Descripción">
                                            <ListErrors :errores="errores.descripcion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <input type="text" class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="restaurant.observacion" placeholder="Observación">
                                            <ListErrors :errores="errores.observacion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <select class="form-control input-style" v-model="restaurant.id_suscripcion">
                                                <option value="-1" selected>Suscripción...</option>
                                                <option v-for="suscripcion in Suscripciones" v-bind:key="suscripcion.id_suscripcion" :value="suscripcion.id_suscripcion">{{suscripcion.tipo_suscripcion}}</option>
                                            </select>
                                            <ListErrors :errores="errores.id_suscripcion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </template>
                        <template v-slot:footer>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaRestaurant">Cerrar</button>
                            <button type="submit" class="btn btn-primary">Guardar</button>
                        </template>
                    </Modal>
                </form>
                <!-- Modal edita datos restaurante -->
                <form @submit.prevent="editaRestaurant(restaurant.id_restaurant)">
                    <Modal titulo="Edita Restaurante" idModal="modalEditaRestaurante" icono="fas fa-edit">
                        <template v-slot:body>
                            <div class="container-fluid">
                                <div class="row">
                                    <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label for="" class="label-style">Nombre</label>
                                            <input type="text" class="form-control input-style" v-model="restaurant.nombre">
                                            <ListErrors :errores="errores.nombre"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label for="" class="label-style">Descripción</label>
                                            <textarea class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="restaurant.descripcion"></textarea>
                                            <ListErrors :errores="errores.descripcion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label for="" class="label-style">Observación</label>
                                            <textarea class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="restaurant.observacion"></textarea>
                                            <ListErrors :errores="errores.observacion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <div class="form-group">
                                            <label for="" class="label-style">Suscripción</label>
                                            <select class="form-control input-style" v-model="restaurant.id_suscripcion">
                                                <option value="-1" selected>Seleccionar...</option>
                                                <option v-for="suscripcion in Suscripciones" v-bind:key="suscripcion.id_suscripcion" :value="suscripcion.id_suscripcion">{{suscripcion.tipo_suscripcion}}</option>
                                            </select>
                                            <ListErrors :errores="errores.id_suscripcion"></ListErrors>
                                        </div>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6 label-style">Estado</div>
                                    <div class="col-md-6">
                                        <div class="form-check">
                                            <input type="checkbox" class="form-check-input" checked v-model="restaurant.estado" @click="cambiaEstado" ref="estadoRestaurant">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </template>
                        <template v-slot:footer>
                            <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaRestaurant">Cerrar</button>
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
import {misMixins} from '@/mixins/misMixins.js';
export default{
    name: 'Restaurant',
    components: {
        Modal,
        BoxMessage,
        ListErrors,
        Pagination,
        Marco
    },
    mixins: [misMixins],
    created () {
        this.datosrestaurant();
        this.getAllSuscriciones();
        this.getDataUser(3).then(response => {
            this.data_usr = response.data;
        }).catch(error => {
            console.log(error)
        });
    },
    data() {
        return {
            listaRetaurantes: [],
            restaurant: {
                nombre: null,
                descripcion: null,
                observacion: null,
                estado: null,
                id_suscripcion: -1,
            },
            Suscripciones: [],
            nuevoRestaurante: '',
            datosRepetidos: '',
            errores: {},
            restaurantEstado: null,
            pagination: {},
            nro_page: 3,
            restaurantesActivos: 0,
            data_usr: {}
        }
    },
    computed: {
        filterdRestaurnates() {
            return this.listaRetaurantes.filter((item)=>{
                if(this.obj != null)
                {
                    if(this.obj.ide == 1){
                        return item.nombre.match(this.obj.search);
                    }else if(this.obj.ide == 2){
                        return item.descripcion.match(this.obj.search);
                    }else if(this.obj.ide == 3){
                        return item.nombre_usuario.match(this.obj.search);
                    }
                }else{
                    return item.nombre.match('');
                }
                
            });
        }
    },
    methods: {
        datosrestaurant(url) {
            this.listaRetaurantes = [];
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.defaults.headers.common["Content-Type"] = 'application/json';
            url = url || this.$store.state.url_root+`api/auth/restaurant/page/${this.nro_page}/${this.restaurantesActivos}`;
            axios.get(url)
            .then(response => {
                this.listaRetaurantes = response.data.data.data;
                this.pagination = response.data.data;
            })
            .catch (error => {
                alert("restaurantes.vue: "+error)
            });
        },
        limpiaRestaurant(){
            this.restaurant.nombre = null;
            this.restaurant.descripcion = null;
            this.restaurant.observacion = null;
            this.restaurant.id_suscripcion = -1,
            //this.restaurant.id_superadministrador = null;
            this.nuevoRestaurante = '';
            this.datosRepetidos = '';
            this.errores = {};
            this.$refs.estadoRestaurant.checked = false;
        },
        nuevoRestaurant(){
            this.errores = {}
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            this.restaurant.estado = true
            this.restaurant.id_superadministrador = this.data_usr.id_superadministrador;
            axios.post(this.$store.state.url_root+"api/auth/restaurant", this.restaurant)
            .then(response => {
                if(response.data.error == null){
                    this.datosrestaurant();
                    window.$("#modalNuevoRestaurante").modal('hide');
                    this.limpiaRestaurant();
                    this.nuevoRestaurante = `El restaurante <strong>${response.data.data.nombre}</strong> se creo correctamente`
                }else{
                    this.errores = response.data.error
                }
            })
            .catch (error => {
                alert("restaurantes.vue: "+error)
            });
        },
        getDatosRestaurant(id){
            this.limpiaRestaurant();
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+"api/auth/restaurant/"+id)
            .then(response => {
                this.restaurant = response.data.data;
                this.restaurant.id_suscripcion == null? this.restaurant.id_suscripcion = -1: this.restaurant.id_suscripcion
                this.$refs.estadoRestaurant.checked = this.restaurant.estado;
            })
            .catch (error => {
                alert("restaurantes.vue: "+error)
            });
        },
        editaRestaurant(id){
            this.errores = {}
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            this.restaurant.id_superadministrador = this.data_usr.id_superadministrador;
            axios.put(this.$store.state.url_root+"api/auth/restaurant/"+id, this.restaurant)
            .then(response => {
                if(response.data.error == null){
                    this.datosrestaurant(this.$store.state.url_root+`api/auth/restaurant/page/${this.nro_page}/${this.restaurantesActivos}?page=${this.pagination.current_page}`);
                    window.$("#modalEditaRestaurante").modal('hide');
                    this.limpiaRestaurant();
                    this.nuevoRestaurante = `El restaurante <strong>${response.data.data.nombre}</strong> se actualizo correctamente`
                }else{
                    if(response.data.error.valores != null){
                        this.datosRepetidos = response.data.error.valores;
                    }else{
                        this.errores = response.data.error;
                    }
                }
            })
            .catch (error => {
                alert("restaurantes.vue: "+error)
            });
        },
        cambiaEstado(){
            if(this.$refs.estadoRestaurant.checked){
                this.$refs.estadoRestaurant.value = true
            }else{
                this.$refs.estadoRestaurant.value = false
            }
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.datosrestaurant();
        },
        eventInputCheckbox_RestaurantesActivos(){
            if(this.$refs.refInputCheckbox_RestaurantesActivos.checked){
                this.restaurantesActivos = 1
            }else{
                this.restaurantesActivos = 0
            }
            this.datosrestaurant(this.$store.state.url_root+`api/auth/restaurant/page/${this.nro_page}/${this.restaurantesActivos}?page=${this.pagination.current_page}`);
        },
        getAllSuscriciones(){
            this.Suscripciones = [];
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/suscripcion`)
            .then(response => {
                this.Suscripciones = response.data.data;
            })
            .catch (error => {
                alert("restaurantes.vue: "+error)
            });
        }
    },
}
</script>
<style lang="scss">
    .styleInputMostrarActivos{
        float: right;
    }
</style>
