<template>
    <Marco titulo="Sucursales" icono="fas fa-table">
        <div class="container">
            <div class="row">
                <div class="col-md-12">
                    <label for="">
                            Entradas
                            <select id="nroEntradas" @change="cambiaOption" ref="nroEntradas">
                                <option>2</option>
                                <option>4</option>
                                <option>6</option>
                            </select>
                    </label>
                </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <div class="table-responsive">
                        <table-component
                            :data="listaSucursales"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption=false
                            >
                            <table-column show="id_sucursal" label="Nro."></table-column>
                            <table-column show="nombre" label="Sucursal"></table-column>
                            <table-column show="direccion" label="Dirección"></table-column>
                            <!-- <table-column show="descripcion" label="Descripción"></table-column> -->
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
        </div>
    </Marco>
</template>
<script>
const axios = require("axios");
import Pagination from '@/components/Pagination/Pagination';
import Marco from '@/components/Layout/Marco';
export default{
    name: 'Sucursal',
    components: {
        Pagination,
        Marco
    },
    created () {
        this.datosSucursal();
    },
    data() {
        return {
            listaSucursales: [],
            nro_page: 2,
            pagination: {},
        }
    },
    methods: {
        datosSucursal(url) {
            this.$Progress.start()
            this.listaSucursales = [];
            // url = url || this.$store.state.url_root+`api/auth/sucursal/restaurant/${this.nro_page}/${this.$store.state.id_restaurant}`
            url = url || this.$store.state.url_root+`api/auth/sucursal/restaurant/${this.nro_page}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
            axios.get(url)
            .then(response => {
                this.listaSucursales = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Sucursales.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.datosSucursal();
        },
    },
}
</script>