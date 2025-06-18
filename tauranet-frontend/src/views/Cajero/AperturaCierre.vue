<template>
    <Marco titulo="Apertura/Cierre de caja" icono="fas fa-table">
        <div class="container-fluid">
            <div class="row">
                <div class="col-md-3">
                    <BoxMessage :message="nuevoHistorialMsg" :cod="'su'" icono="fas fa-check"></BoxMessage>
                    <button type="button" class="btn btn-primary" data-toggle="modal" data-target="#modalAperturaCaja"><i class="fas fa-plus"></i> Apertura</button>
                </div>
                <div class="col-md-9">
                    <div class="row">
                        <div class="col-md-12">
                            <label for="">
                                    Entradas
                                    <select id="nroEntradas" @change="cambiaOption" ref="nroEntradas">
                                        <option>3</option>
                                        <option>6</option>
                                        <option>10</option>
                                    </select>
                            </label>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 table-responsive">
                            <table-component
                                :data="listaHistorial"
                                tableClass="table"
                                theadClass="head-table"
                                filterPlaceholder="Buscar..."
                                filter-input-class="inputSearchText"
                                :show-caption=false
                                >
                                <table-column show="fecha" label="Fecha"></table-column>
                                <table-column show="monto_inicial" :label="'Monto Apertura ('+tipoMoneda+')'"></table-column>
                                <table-column show="monto" :label="'Monto Actual ('+tipoMoneda+')'"></table-column>
                                <table-column label="Cerrar" :sortable="false" :filterable="false">
                                    <template slot-scope="row">
                                        <button type="button" class="btn btn-danger" :class="{disabled: !row.estado}" @click="cerrarCaja(row.id_historial_caja, row.fecha)"><i class="fas fa-window-close"></i></button>
                                    </template>
                                </table-column>
                                <table-column label="Actualizar" :sortable="false" :filterable="false">
                                    <template slot-scope="row">
                                        <button type="button" class="btn btn-success" :class="{disabled: !row.estado}" @click="sincronizarCaja(row.id_historial_caja, row.monto_inicial)"><i class="fas fa-sync-alt"></i></button>
                                    </template>
                                </table-column>
                            </table-component>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 table-responsive">
                            <Pagination :pagination="pagination" v-on:funcion="getAllAperturaCierre"></Pagination>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Ventanas Modales -->
            <form @submit.prevent="nuevoHistorial">
                <Modal titulo="Apertura de Caja" :icono="'fas fa-folder-plus'" idModal="modalAperturaCaja">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label for="" class="label-style">Monto Inicial ({{tipoMoneda}})</label>
                                        <input type="text" class="form-control input-style" v-model="historial.monto_inicial">
                                        <ListErrors :errores="errores.monto_inicial"></ListErrors>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label for="" class="label-style">Fecha</label>
                                    <flat-pickr
                                            v-model="historial.fecha"                                                       
                                            class="form-control input-style"
                                            :config="config"
                                            >
                                    </flat-pickr>
                                    <ListErrors :errores="errores.fecha"></ListErrors>
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaHistorial">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="nuevoAperturaBtn">Guardar</button>
                    </template>
                </Modal>
            </form>
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Marco from '@/components/Layout/Marco';
import Pagination from '@/components/Pagination/Pagination';
import Modal from '@/components/Modal/Modal';
import BoxMessage from '@/components/Messages/BoxMessage';
import ListErrors from '@/components/Messages/ListErrors';
import {misMixins} from '@/mixins/misMixins.js';
import flatPickr from 'vue-flatpickr-component';
import 'flatpickr/dist/flatpickr.css';
import {Hindi} from 'flatpickr/dist/l10n/hi';
export default{
    name: 'AperturaCierre',
    components: {
        Marco,
        BoxMessage,
        Modal,
        flatPickr,
        ListErrors,
        Pagination
    },
    data() {
        return {
            nro_page: 3,
            pagination: {},
            data_usr: {},
            listaHistorial: [],
            errores: {},
            historial: {},
            nuevoHistorialMsg: '',
            datosRepetidos: '',
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
            cajaHistorialArray: []
        }
    },
    mixins: [misMixins],
    computed: {
        tipoMoneda() {
            return this.$store.state.restauranteData.tipo_moneda
        }
    },
    created () {
        this.$Progress.start()
        this.getDataUser(1).then(response => {
            this.data_usr = response.data;
            this.getAllAperturaCierre();
            this.$Progress.finish()
        }).catch(error => {
            this.$toasted.show(error, {type: 'error'})
            this.$Progress.fail()
        });
    },
    methods: {
        getAllAperturaCierre(url) {
            this.$Progress.start()
            url = url || this.$store.state.url_root+`api/auth/historialcaja/caja/${this.data_usr.id_caja}/page/${this.nro_page}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.listaHistorial = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("AperturaCierre.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        limpiaHistorial(){
            this.historial = {}
            this.errores = {}
            this.datosRepetidos = ''
            //this.nuevoHistorialMsg = ''
        },
        nuevoHistorial(){
            this.$refs.nuevoAperturaBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            this.historial.id_cajero = this.data_usr.id_cajero;
            this.historial.estado = true;
            this.historial.id_caja = this.data_usr.id_caja;
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.post(this.$store.state.url_root+`api/auth/historialcaja/${this.data_usr.id_caja}`, this.historial)
            .then(response => {
                if(response.data.error == null){
                    this.getAllAperturaCierre()
                    this.nuevoHistorialMsg = `Se aperturo la caja en fecha ${this.historial.fecha}`
                    this.limpiaHistorial();
                    window.$("#modalAperturaCaja").modal('hide');
                    this.$Progress.finish()
                    this.$refs.nuevoAperturaBtn.className = "btn btn-primary"
                }else{
                    if(response.data.error.valores != null){
                        this.datosRepetidos = response.data.error.valores;
                    }else{
                        this.errores = response.data.error;
                    }
                    this.$Progress.fail()
                    this.$refs.nuevoAperturaBtn.className = "btn btn-primary"
                }
            })
            .catch(error => {
                this.$toasted.show("AperturaCierre.vue: "+error, {type: 'error'})
                this.$Progress.fail()
                this.$refs.nuevoAperturaBtn.className = "btn btn-primary"
            })
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.getAllAperturaCierre()
        },
        cerrarCaja(id, fecha){
            let sw = confirm(`Esta seguro que desea cerrar la caja de fecha ${fecha}`)
            if(sw){
                this.$Progress.start()
                this.historial.id_cajero = this.data_usr.id_cajero;
                this.historial.estado = false;
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                    axios.put(this.$store.state.url_root+`api/auth/historialcaja/${id}`, this.historial)
                .then(response => {
                    this.getAllAperturaCierre(this.$store.state.url_root+`api/auth/historialcaja/caja/${this.data_usr.id_caja}/page/${this.nro_page}?page=${this.pagination.current_page}`)
                    this.nuevoHistorialMsg = `Se cerro la caja de fecha ${fecha}`
                    this.limpiaHistorial();
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("AperturaCaja.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }
        },
        sincronizarCaja(idHistorialCaja, monto_inicial){
            this.$Progress.start()
            let url = this.$store.state.url_root+`api/auth/calculamonto/${idHistorialCaja}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.cajaHistorialArray = response.data.data
                let suma = 0
                this.cajaHistorialArray.forEach(element => {
                    suma = Number(suma) + Number(element.efectivo) - Number(element.cambio)
                });
                let objeto = {}
                objeto.monto_final = Number(monto_inicial) + Number(suma)
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.put(this.$store.state.url_root+`api/auth/updatemonto/${idHistorialCaja}`, objeto)
                .then(response => {
                     this.getAllAperturaCierre();
                     this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("AperturaCaja.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            })
            .catch (error => {
                this.$toasted.show("AperturaCaja.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        }
    },
}
</script>