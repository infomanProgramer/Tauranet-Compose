<template>
    <Marco titulo="Productos" icono="fas fa-table">
        <div class="container">
            <div class="row">
                <div class="col-md-6">
                    <label for="">
                            Entradas
                            <select id="nroEntradas" @change="cambiaOption" ref="nroEntradas">
                                <option>10</option>
                                <option>20</option>
                                <option>40</option>
                            </select>
                    </label>
                </div>
                <div class="col-md-6">
                    <div class="form-group">               
                        <button type="button" class="btn btn-primary float-right" data-toggle="modal" data-target="#modalNuevoProducto"><i class="fas fa-plus"></i> Nuevo</button>
                    </div>
                </div>
            </div>
            <div class="row">
                    <div class="col-md-6">
                        <div class="form-group">
                        <label for="">
                                Categoría
                                <select class="form-control" v-model="comboCategorias" @change="listaProductosMethod()">
                                    <option value="-1" selected>Seleccionar...</option>
                                    <option v-for="s in listaCategoria" v-bind:key="s.id_categoria_producto" :value="s.id_categoria_producto">{{s.nombre}}</option>
                                </select>
                        </label>
                        </div>
                    </div>
                    <div class="col-md-6">
                    </div>
            </div>
            <div class="row">
                <div class="col-md-12">
                    <BoxMessage :message="nuevoProductoMsg" :cod="'su'" icono="fas fa-check"></BoxMessage>
                    <div class="table-responsive">
                        <table-component
                            :data="listaProductos"
                            tableClass="table"
                            theadClass="head-table"
                            filterPlaceholder="Buscar..."
                            filter-input-class="inputSearchText"
                            :show-caption="false"
                            :show-loading="true"
                            >
                            <table-column show="categoriaProducto" label="Categoría"></table-column>   
                            <table-column show="nombre" label="Producto"></table-column>
                            <table-column show="precio" :label="'Precio ('+tipoMoneda+')'" :filterable="false"></table-column>
                            <table-column label="Imagen">
                                <template slot-scope="row">
                                    <!-- Imagen -->
                                    <img v-if="row.producto_image != null" :src="ruta_publica+'imgProductos/'+row.producto_image" class="img-fluid" alt="No se encontro la imagen" width="80" height="80">
                                    <span v-else>Sin imagen</span>
                                </template>
                            </table-column>
                            <table-column label="Editar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-info" data-toggle="modal" data-target="#modalEditaProducto" @click="getDatosProducto(row.id_producto)"><i class="fas fa-edit"></i></button>
                                </template>
                            </table-column>
                            <table-column label="Eliminar" :sortable="false" :filterable="false">
                                <template slot-scope="row">
                                    <button type="button" class="btn btn-danger" @click="eliminarProducto(row.id_producto, row.nombre)"><i class="fas fa-trash-alt"></i></button>
                                </template>
                            </table-column>
                        </table-component>
                    </div>
                </div>
            </div>
            <!-- Pagination -->
            <div class="row">
                <div class="col-md-12 table-responsive">
                    <Pagination :pagination="pagination" v-on:funcion="listaProductosMethod"></Pagination>
                </div>
            </div>
            <!-- Ventanas modales -->
            <!-- Nuevo Producto -->
            <form @submit.prevent="nuevoProducto()">
                <Modal titulo="Registro de producto" idModal="modalNuevoProducto" icono="fab fa-product-hunt">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Nombre Producto</label>
                                        <input type="text" class="form-control input-style" v-model="producto.nombre" placeholder="Nombre Producto">
                                        <ListErrors :errores="errores.nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Categoría</label>
                                        <select id="hol" class="form-control input-style" v-model="producto.id_categoria_producto">
                                            <option value="-1" selected>Categoría...</option>
                                            <option v-for="lista in listaCategoria" v-bind:key="lista.id_categoria_producto" :value="lista.id_categoria_producto">{{lista.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_categoria_producto"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Precio ({{tipoMoneda}})</label>
                                        <input type="text" class="form-control input-style" v-model="producto.precio" :placeholder="'Precio ('+tipoMoneda+')'">
                                        <ListErrors :errores="errores.precio"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">Descripción</label>
                                        <input type="text" class="form-control input-style" v-model="producto.descripcion" placeholder="Descripción">
                                        <ListErrors :errores="errores.descripcion"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                   <croppa v-model="myCroppa"
                                    :file-size-limit="maxImageSize"
                                    :placeholder-font-size="10"
                                    placeholder="Escoger una imagen (5 Mb como maximo)"
                                    :zoom-speed="10"
                                    :reverse-scroll-to-zoom="true"
                                    :prevent-white-space="true"
                                    :show-loading="true"
                                    @file-size-exceed="handleCroppaFileSizeExceed"
                                    @file-type-mismatch="onFileTypeMismatch"
                                   ></croppa>
                                   <ListErrors :errores="errores.foto_producto"></ListErrors>
                                </div>
                                <div class="col-md-6">
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaProducto">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="nuevoProductoBtn">Guardar</button>
                    </template>
                </Modal>
            </form>
            <!-- Editar Producto-->
            <form @submit.prevent="editaProducto(producto.id_producto)">
                <Modal titulo="Edita Producto" idModal="modalEditaProducto" icono="fab fa-product-hunt">
                    <template v-slot:body>
                        <div class="container-fluid">
                            <div class="row">
                                <BoxMessage :message="datosRepetidos" :cod="'da'" icono="fas fa-exclamation-circle"></BoxMessage>
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Nombre Producto</label>
                                        <input type="text" class="form-control input-style" v-model="producto.nombre">
                                        <ListErrors :errores="errores.nombre"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Categoría</label>
                                        <select id="hol" class="form-control input-style" v-model="producto.id_categoria_producto">
                                            <option value="-1" selected>Categoría...</option>
                                            <option v-for="lista in listaCategoria" v-bind:key="lista.id_categoria_producto" :value="lista.id_categoria_producto">{{lista.nombre}}</option>
                                        </select>
                                        <ListErrors :errores="errores.id_categoria_producto"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">* Precio ({{tipoMoneda}})</label>
                                        <input type="text" class="form-control input-style" v-model="producto.precio" >
                                        <ListErrors :errores="errores.precio"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-12">
                                    <div class="form-group">
                                        <label for="" class="label-style">Descripción</label>
                                        <input type="text" class="form-control input-style" v-model="producto.descripcion">
                                        <ListErrors :errores="errores.descripcion"></ListErrors>
                                    </div>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <!-- Edita imagen -->
                                    <DeleteImageProduct :url_image="ruta_publica+'imgProductos/'+producto.producto_image" v-on:deleteImgProductMethod="deleteImgProductMethod()" v-if="producto.producto_image!=null"></DeleteImageProduct>
                                    <div v-show="producto.producto_image==null">
                                        <croppa v-model="myCroppaUpdate"
                                            :file-size-limit="maxImageSize"
                                            :placeholder-font-size="10"
                                            placeholder="Escoger una imagen (5 Mb como maximo)"
                                            :zoom-speed="10"
                                            :reverse-scroll-to-zoom="true"
                                            :prevent-white-space="true"
                                            :show-loading="true"
                                            @file-size-exceed="handleCroppaFileSizeExceed"
                                            @file-type-mismatch="onFileTypeMismatch"
                                        ></croppa>
                                    </div>
                                    <ListErrors :errores="errores.foto_producto"></ListErrors>
                                </div>
                                <div class="col-md-6">
                                </div>
                            </div>
                        </div>
                    </template>
                    <template v-slot:footer>
                        <button type="button" class="btn btn-secondary" data-dismiss="modal" @click="limpiaProducto">Cerrar</button>
                        <button type="submit" class="btn btn-primary" ref="editaProductoBtn">Guardar</button>
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
import DeleteImageProduct from '@/components/Files/DeleteImageProduct'
import flatPickr from 'vue-flatpickr-component';
export default{
    name: 'Productos',
    components: {
        Pagination,
        Marco,
        Modal,
        ListErrors,
        BoxMessage,
        flatPickr,
        DeleteImageProduct
    },
    created () {
        this.listaProductosMethod();//Carga combo sucursales
        this.comboCategoria();
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
            listaCategoria: [],
            listaProductos: [],
            pagination: {},
            producto:{
                id_categoria_producto: -1,
                producto_image: null  
            },
            data_usr: {},
            errores: {},
            nro_page: 10,
            nuevoProductoMsg: '',
            datosRepetidos: '',
            comboCategorias: -1,
            myCroppa: {},
            myCroppaUpdate: {},
            rotation: 0,
            scale: 1,
            ruta_publica: this.$store.state.url_root,
            maxImageSize: 5242880 //5Mb
        }
    },
    mixins: [misMixins],
    computed: {
        tipoMoneda() {
            return this.$store.state.restauranteData.tipo_moneda
        }
    },
    methods: {
        comboCategoria(){
            this.$Progress.start()
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/cproducto/restaurant/${this.$store.state.id_restaurant}`)
            .then(response => {
                this.listaCategoria = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        listaProductosMethod(url){
            this.$Progress.start()
            url = url || this.$store.state.url_root+`api/auth/producto/${this.nro_page}/restaurant/${this.$store.state.id_restaurant}/categoria/${this.comboCategorias}`
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(url)
            .then(response => {
                this.listaProductos = response.data.data.data;
                this.pagination = response.data.data;
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        cambiaOption(){
            this.nro_page = this.$refs.nroEntradas.value
            this.listaProductosMethod()
        },
        getDatosProducto(idPersonal){
            this.$Progress.start()
            this.producto.id_administrador = this.data_usr.id_administrador
            axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.get(this.$store.state.url_root+`api/auth/producto/${idPersonal}`)
            .then(response => {
                this.producto = response.data.data
                this.$Progress.finish()
            })
            .catch (error => {
                this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                this.$Progress.fail()
            });
        },
        nuevoProducto(){
            //Guardado de los datos del producto
            this.$refs.nuevoProductoBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            let type = 'image/jpeg'
            let compressionRate = 0.5
            this.myCroppa.generateBlob((blob) => {
                this.producto.id_administrador = this.data_usr.id_administrador
                this.producto.image = blob
                let formData = new FormData();
                for(let item in this.producto){
                    if(this.producto.hasOwnProperty(item)){
                        formData.append(item, this.producto[item]);
                    }
                }
                // for(let val of formData.values()){
                //     console.log(val)
                // }
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.defaults.headers.common["Content-Type"] = "multipart/form-data";
                axios.post(this.$store.state.url_root+`api/auth/producto`, formData)
                .then(response => {
                    if(response.data.error == null){
                        this.listaProductosMethod()
                        window.$("#modalNuevoProducto").modal('hide');
                        this.limpiaProducto();
                        this.nuevoProductoMsg = `El producto <strong>${response.data.data.nombre}</strong> se creo correctamente`
                        this.$Progress.finish()
                        this.$refs.nuevoProductoBtn.className = "btn btn-primary"
                    }else{
                        this.errores = response.data.error
                        this.$Progress.fail()
                        this.$refs.nuevoProductoBtn.className = "btn btn-primary"
                    }
                })
                .catch (error => {
                    this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.nuevoProductoBtn.className = "btn btn-primary"
                });
            }, type, compressionRate)
        },
        editaProducto(idProducto){
            this.$refs.editaProductoBtn.className = "btn btn-primary disabled"
            this.$Progress.start()
            let type = 'image/jpeg'
            let compressionRate = 0.5
            this.myCroppaUpdate.generateBlob((blob) => {
                this.producto.id_administrador = this.data_usr.id_administrador
                if(this.producto.producto_image==null){
                    this.producto.image = blob
                }
                let formData = new FormData();
                for(let item in this.producto){
                    if(this.producto.hasOwnProperty(item)){
                        formData.append(item, this.producto[item]);
                    }
                }
                //formData.append('_method', 'PUT')
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.defaults.headers.common["Content-Type"] = "multipart/form-data";
                axios.post(this.$store.state.url_root+`api/auth/productoupdate/${idProducto}`, formData)
                .then(response => {
                    if(response.data.error == null){
                        this.listaProductosMethod(this.$store.state.url_root+`api/auth/producto/${this.nro_page}/restaurant/${this.$store.state.id_restaurant}/categoria/${this.comboCategorias}?page=${this.pagination.current_page}`)
                        window.$("#modalEditaProducto").modal('hide');
                        this.limpiaProducto();
                        this.nuevoProductoMsg = `El producto <strong>${response.data.data.nombre}</strong> se actualizo correctamente`
                        this.$Progress.finish()
                        this.$refs.editaProductoBtn.className = "btn btn-primary"
                    }else{
                        if(response.data.error.valores != null){
                            this.datosRepetidos = response.data.error.valores;
                        }else{
                            this.errores = response.data.error;
                        }
                        this.$Progress.fail()
                        this.$refs.editaProductoBtn.className = "btn btn-primary"
                    }
                })
                .catch (error => {
                    this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                    this.$refs.nuevoProductoBtn.className = "btn btn-primary"
                });
            }, type, compressionRate)
        },
        limpiaProducto(){
            this.producto = {
                id_categoria_producto: -1,
                producto_image: null    
            },
            this.nuevoProductoMsg = ''
            this.errores = {}
            this.datosRepetidos = ''
            this.myCroppaUpdate.remove();
            this.myCroppa.remove();
        },
        mtipoCajero(){
            this.producto.id_caja = -1;            
        },
        eliminarProducto(idProducto, nomProducto){
            let sw = confirm(`Desea eliminar el usuario ${nomProducto}`)
            if(sw){
                this.$Progress.start()
                let url = this.$store.state.url_root+`api/auth/producto/${idProducto}`
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                    axios.delete(url)
                .then(response => {
                    this.listaProductosMethod(this.$store.state.url_root+`api/auth/producto/${this.nro_page}/restaurant/${this.$store.state.id_restaurant}/categoria/${this.comboCategorias}?page=${this.pagination.current_page}`)
                    this.limpiaProducto();
                    this.nuevoProductoMsg = `El producto <strong>${nomProducto}</strong> se elimino correctamente`
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }else{
                console.log("no se borro nada")
            }
        },
        deleteImgProductMethod(){
            let sw = confirm('Desea eliminar la imagen')
            if(sw){
                this.$Progress.start()
                axios.defaults.headers.common["Authorization"] = "Bearer " + this.$store.state.token;
                axios.delete(this.$store.state.url_root+"api/auth/delimage/"+this.producto.id_producto)
                .then(response => {
                    this.producto = response.data.data
                    this.listaProductosMethod(this.$store.state.url_root+`api/auth/producto/${this.nro_page}/restaurant/${this.$store.state.id_restaurant}/categoria/${this.comboCategorias}?page=${this.pagination.current_page}`)
                    this.$Progress.finish()
                })
                .catch (error => {
                    this.$toasted.show("Productos.vue: "+error, {type: 'error'})
                    this.$Progress.fail()
                });
            }
        },
        handleCroppaFileSizeExceed(){
            this.errores = {"foto_producto": ["Supero el tamaño maximo (5 Mb) de la imagen"]}
        },
        onFileTypeMismatch(){
            this.errores = {"foto_producto": ["La imagen debe ser de tipo PNG o JPEG"]}
        }
    },
}
</script>