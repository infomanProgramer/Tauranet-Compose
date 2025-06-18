<template>
    <Marco titulo="Categoria Productos" icono="fas fa-table">
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
                        <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevaCategoria"><i class="fas fa-plus"></i> Nuevo</button>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <BoxMessage :message="nuevoCategoriaMsg" :cod="cod" :icono="icono"></BoxMessage>
                    <div class="table-responsive">
                        <table-component
                            :data="listaCategoriaProductos"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombre" label="Categoria"></table-column>   
                            <table-column show="descripcion" label="Descripción"></table-column>
                            <table-column label="Editar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaCategoria" @click="getDatosCategoria(row.id_categoria_producto)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                            <table-column label="Eliminar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-danger" @click="eliminaCategoria(row.id_categoria_producto, row.nombre)"><i class="fas fa-trash-alt"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="listaCategoriaProductosMethod"></Pagination>
                </div>
            </div>
            <!-- Ventanas modales -->
            <form @submit.prevent="nuevaCategoria()">
                <Modal titulo="Registro Categoria" idModal="modalNuevaCategoria" icono="fas fa-boxes">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Nombre Categoria</label>
                                        <input type="text" class="form-control input-style" v-model="categoria.nombre" placeholder="Nombre Categoria">
                                        <ListErrors :errores="errores.nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">Descripción</label>
                                        <input type="text" class="form-control input-style" v-model="categoria.descripcion" placeholder="Descripción">
                                        <ListErrors :errores="errores.descripcion"></ListErrors>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaCategoria">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="nuevoCategoriaBtn">Guardar</button>
                    </template>
                </Modal>
            </form>
            <form @submit.prevent="editaCategoria(categoria.id_categoria_producto)">
                <Modal titulo="Editar Categoria Producto" idModal="modalEditaCategoria" icono="fas fa-boxes">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Nombre Categoria</label>
                                        <input type="text" class="form-control input-style" v-model="categoria.nombre">
                                        <ListErrors :errores="errores.nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">Descripción</label>
                                        <input type="text" class="form-control input-style" v-model="categoria.descripcion">
                                        <ListErrors :errores="errores.descripcion"></ListErrors>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaCategoria">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="editaCategoriaBtn">Guardar</button>
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
    name: 'CategoriaProductos',
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
        this.listaCategoriaProductosMethod()
        this.$Progress.start()
        this.getDataUser(2).then(response => {
            this.data_usr = response.data;
            this.$Progress.finish()
        }).catch(error => {   
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    data() {
        return {
            listaCategoriaProductos: [],
            pagination: {},
            categoria:{},
            data_usr: {},
            errores: {},
            nro_page: 5,
            nuevoCategoriaMsg: '',
            datosRepetidos: '',
            cod: 'su',
            icono: 'fas fa-check'
        }
    },
    mixins: [misMixins],
    methods: {
        listaSucursalesMethod(){
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/sucursalcombo/${this.$store.state.id_restaurant}`)
            .then(response => {
                this.listaSucursales = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("CategoriaProductos.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.listaCategoriaProductosMethod()
        },
        getDatosCategoria(idCategoria){
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+`api/auth/cproducto/${idCategoria}`)
            .then(response => {
                this.categoria = response.data.data
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("CategoriaProductos.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        nuevaCategoria(){
            this.$refs.nuevoCategoriaBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.categoria.id_administrador = this.data_usr.id_administrador
            this.categoria.id_restaurant = this.$store.state.id_restaurant
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(this.$store.state.url_root+`api/auth/cproducto`, this.categoria)
            .then(response => {
                if(response.data.error == null){
                    this.listaCategoriaProductosMethod()
                    window.$("#modalNuevaCategoria").modal('hide');
                    this.limpiaCategoria();
                    this.nuevoCategoriaMsg = `La categoria <strong>${response.data.data.nombre}</strong> se creo correctamente`
                    this.$refs.nuevoCategoriaBtn.className = "btn btn-primary"
                    this.$Progress.finish()
                }else{
                    this.errores = response.data.error
                    this.$refs.nuevoCategoriaBtn.className = "btn btn-primary"
                    this.$Progress.fail()
                }
            })
            .catch (error => {
                this.$toasted.show("CategoriaProductos.vue: "+error, {type: 'error'})
                this.$refs.nuevoCategoriaBtn.className = "btn btn-primary"
                this.$Progress.fail()
            });
        },
        editaCategoria(idCategoria){
            this.$refs.editaCategoriaBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.categoria.id_administrador = this.data_usr.id_administrador
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.put(this.$store.state.url_root+`api/auth/cproducto/${idCategoria}`, this.categoria)
            .then(response => {
                if(response.data.error == null){
                    this.listaCategoriaProductosMethod(this.$store.state.url_root+`api/auth/cproducto/${this.nro_page}/restaurant/${this.$store.state.id_restaurant}?page=${this.pagination.current_page}`)
                    window.$("#modalEditaCategoria").modal('hide');
                    this.limpiaCategoria();
                    this.nuevoCategoriaMsg = `La Categoria <strong>${response.data.data.nombre}</strong> se actualizo correctamente`
                    this.$refs.editaCategoriaBtn.className = "btn btn-primary"
                    this.$Progress.finish()
                }else{
                    if(response.data.error.valores != null){
                        this.datosRepetidos = response.data.error.valores;
                    }else{
                        this.errores = response.data.error;
                    }
                    this.$refs.editaCategoriaBtn.className = "btn btn-primary"
                    this.$Progress.fail()
                }
            })
            .catch (error => {
                this.$toasted.show("CategoriaProductos.vue: "+error, {type: 'error'})
                this.$refs.editaCategoriaBtn.className = "btn btn-primary"
                this.$Progress.fail()
            });
        },
        limpiaCategoria(){
            this.categoria = {}
            this.nuevoCategoriaMsg = ''
            this.errores = {}
            this.datosRepetidos = ''
            this.cod = 'su',
            this.icono = 'fas fa-check'
        },
        listaCategoriaProductosMethod(url){
            this.$Progress.start()
            url = url || this.$store.state.url_root+`api/auth/cproducto/${this.nro_page}/restaurant/${this.$store.state.id_restaurant}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaCategoriaProductos = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("CategoriaProductos.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        eliminaCategoria(idCategoria, nomCategoria){
            let sw = confirm(`Desea eliminar la categoria ${nomCategoria}`)
            if(sw){
                this.$Progress.start()
                let url = this.$store.state.url_root+`api/auth/cproducto/${idCategoria}`
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                    axios.delete(url)
                .then(response => {
                    this.listaCategoriaProductosMethod(this.$store.state.url_root+`api/auth/cproducto/${this.nro_page}/restaurant/${this.$store.state.id_restaurant}?page=${this.pagination.current_page}`)
                    this.limpiaCategoria();
                    if(response.data.data.error != null){
                        this.nuevoCategoriaMsg = `No se puede eliminar la categoria <strong>${nomCategoria}</strong>, existen productos asignados`
                        this.cod = 'da'
                        this.icono = 'fas fa-ban'
                        this.$Progress.fail()
                    }else{
                        this.nuevoCategoriaMsg = `La categoria <strong>${nomCategoria}</strong> se elimino correctamente`
                        this.$Progress.finish()
                    } 
                })
                .catch (error => {
                    this.$toasted.show("CategoriaProductos.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }else{
                console.log("no se borro nada")
            }
        }
    },
}
</script>