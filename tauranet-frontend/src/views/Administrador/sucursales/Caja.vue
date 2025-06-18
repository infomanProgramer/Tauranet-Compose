<template>
    <Marco titulo="Cajas" icono="fas fa-table">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <label for="">
                            Entradas
                            <select id="nroEntradas" @change="cambiaOption" ref="nroEntradas">
                                <option>3</option>
                                <option>6</option>
                                <option>10</option>
                            </select>
                    </label>
                </div>
                <div class="col-md-6">               
                    <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevoCaja"><i class="fas fa-plus"></i> Nuevo</button>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <label for="">
                            Sucursal
                            <select id="nroEntradas" @change="mostrarPorSucursal" ref="refListaSucursal">
                                <option value="-1" selected>Seleccionar...</option>
                                <option v-for="s in listaSucursales" v-bind:key="s.id_sucursal" :value="s.id_sucursal">{{s.nombre}}</option>
                            </select>
                    </label>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <BoxMessage :message="nuevaCajaMsg" :cod="cod" :icono="icono"></BoxMessage>
                    <div class="table-responsive">
                        <table-component
                            :data="listaCajas"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="nombreSucursal" label="Sucursal"></table-column>
                            <table-column show="nombre" label="Caja"></table-column>
                            <table-column label="Editar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaCaja" @click="getDatosCaja(row.id_caja)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                            <table-column label="Eliminar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-danger" @click="eliminarCaja(row.id_caja, row.nombre)"><i class="fas fa-trash-alt"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="mostrarPorSucursalPagination"></Pagination>
                </div>
            </div>
            <!-- Ventanas modales -->
            <form @submit.prevent="nuevoCaja">
                <Modal titulo="Registro Caja" idModal="modalNuevoCaja" icono="fas fa-plus">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="Caja.nombre" placeholder="Nombre">
                                        <ListErrors :errores="errores.nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sucursal</label>
                                        <select id="hol" class="form-control input-style" v-model="Caja.id_sucursal">
                                            <option value="-1" selected>Sucursal...</option>
                                            <option v-for="lista in listaSucursales" v-bind:key="lista.id_sucursal" :value="lista.id_sucursal">{{lista.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_sucursal"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">Descripción</label>
                                        <input type="text" class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="Caja.descripcion" placeholder="Descripción">
                                        <ListErrors :errores="errores.descripcion"></ListErrors>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaCaja">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="nuevaCajaBtn">Guardar</button>
                    </template>
                </Modal>
            </form>
            <form @submit.prevent="editaCaja(Caja.id_caja)">
                <Modal titulo="Edita Caja" idModal="modalEditaCaja" icono="fas fa-edit">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Nombre</label>
                                        <input type="text" class="form-control input-style" v-model="Caja.nombre">
                                        <ListErrors :errores="errores.nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Sucursal</label>
                                        <select id="hol" class="form-control input-style" v-model="Caja.id_sucursal">
                                            <option value="-1" selected>Sucursal...</option>
                                            <option v-for="lista in listaSucursales" v-bind:key="lista.id_sucursal" :value="lista.id_sucursal">{{lista.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_sucursal"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">Descripción</label>
                                        <input type="text" class="form-control input-style" id="exampleFormControlTextarea1" rows="3" v-model="Caja.descripcion">
                                        <ListErrors :errores="errores.descripcion"></ListErrors>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaCaja">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="editaCajaBtn">Guardar</button>
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
export default{
    name: 'Caja',
    components: {
        Pagination,
        Marco,
        Modal,
        ListErrors,
        BoxMessage
    },
    created () {
        this.listaSucursalesMethod();
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
            listaSucursales: [],
            listaCajas: [],
            pagination: {},
            Caja: {
                id_sucursal: -1
            },
            data_usr: {},
            errores: {},
            nro_page: 3,
            nuevaCajaMsg: '',
            datosRepetidos: '',
            cod: 'su',
            icono: 'fas fa-check'
        }
    },
    mixins: [misMixins],
    methods: {
        listaSucursalesMethod() {
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/sucursalcombo/${this.$store.state.id_restaurant}`)
            .then(response => {
                this.listaSucursales = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Caja.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        mostrarPorSucursal(){
            this.$Progress.start()
            this.listaCajas = []
            let url = this.$store.state.url_root+`api/auth/caja/sucursal/${this.$refs.refListaSucursal.value}/page/${this.nro_page}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaCajas = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Caja.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        mostrarPorSucursalPagination(url){
            this.$Progress.start()
            this.listaCajas = []
            url = url || this.$store.state.url_root+`api/auth/caja/sucursal/${this.$refs.refListaSucursal.value}/page/${this.nro_page}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaCajas = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Caja.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.mostrarPorSucursalPagination()
        },
        getDatosCaja(id){
            this.$Progress.start()
            this.limpiaCaja();
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(this.$store.state.url_root+"api/auth/caja/"+id)
            .then(response => {
                this.Caja = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Caja.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        nuevoCaja(){
            this.$refs.nuevaCajaBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.Caja.id_administrador = this.data_usr.id_administrador
             axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.post(this.$store.state.url_root+`api/auth/caja`, this.Caja)
            .then(response => {
                if(response.data.error == null){
                    this.mostrarPorSucursal();
                    window.$("#modalNuevoCaja").modal('hide');
                    this.limpiaCaja();
                    this.nuevaCajaMsg = `La caja <strong>${response.data.data.nombre}</strong> se creo correctamente`
                    this.$Progress.finish()
                    this.$refs.nuevaCajaBtn.className = "btn btn-primary"
                }else{
                    if(response.data.error.limite_cajas == null){
                        this.errores = response.data.error
                    }else{
                        this.datosRepetidos = response.data.error.limite_cajas
                    }
                    this.$refs.nuevaCajaBtn.className = "btn btn-primary"
                    this.$Progress.fail()
                }
            })
            .catch (error => {
                this.$toasted.show("Caja.vue: "+error, {type: 'error'})
                this.$refs.nuevaCajaBtn.className = "btn btn-primary"
                this.$Progress.fail()
            });
        },
        editaCaja(id){
            this.$Progress.start()
            this.$refs.editaCajaBtn.className = "btn btn-primary disabled"
            this.Caja.id_administrador = this.data_usr.id_administrador
             axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.put(this.$store.state.url_root+`api/auth/caja/${id}`, this.Caja)
            .then(response => {
                if(response.data.error == null){
                    this.mostrarPorSucursalPagination(this.$store.state.url_root+`api/auth/caja/sucursal/${this.$refs.refListaSucursal.value}/page/${this.nro_page}?page=${this.pagination.current_page}`);
                    window.$("#modalEditaCaja").modal('hide');
                    this.limpiaCaja();
                    this.nuevaCajaMsg = `La caja <strong>${response.data.data.nombre}</strong> se actualizo correctamente`
                    this.$refs.editaCajaBtn.className = "btn btn-primary"
                    this.$Progress.finish()
                }else{
                    if(response.data.error.valores != null){
                        this.datosRepetidos = response.data.error.valores;
                    }else{
                        this.errores = response.data.error;
                    }
                    this.$refs.editaCajaBtn.className = "btn btn-primary"
                    this.$Progress.fail()
                }
            })
            .catch (error => {
                this.$toasted.show("Caja.vue: "+error, {type: 'error'})
                this.$refs.editaCajaBtn.className = "btn btn-primary"
                this.$Progress.fail()
            });
        },
        limpiaCaja(){
            this.Caja = {id_sucursal: -1}
            this.nuevaCajaMsg = ''
            this.errores = {},
            this.datosRepetidos = '';
            this.cod = 'su',
            this.icono = 'fas fa-check'
        },
        eliminarCaja(idCaja, nombreCaja){
            this.$Progress.start()
            let sw = confirm(`Desea eliminar la caja ${nombreCaja}`)
            if(sw){
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.delete(this.$store.state.url_root+`api/auth/caja/${idCaja}`)
                .then(response => {
                    this.mostrarPorSucursalPagination(this.$store.state.url_root+`api/auth/caja/sucursal/${this.$refs.refListaSucursal.value}/page/${this.nro_page}?page=${this.pagination.current_page}`);
                    this.limpiaCaja();
                    if(response.data.data.error != null){
                        this.nuevaCajaMsg = `No se puede eliminar la caja <strong>${nombreCaja}</strong>, existen cajeros asignados`
                        this.cod = 'da'
                        this.icono = 'fas fa-ban'
                        this.$Progress.fail()
                    }else{
                        this.nuevaCajaMsg = `La caja <strong>${nombreCaja}</strong> se elimino correctamente`
                    }
                }).catch(error => {
                    this.$toasted.show('Caja.vue: '+error, {type: 'error'})
                    this.$Progress.fail()
                })
            }
        }
    },
}
</script>