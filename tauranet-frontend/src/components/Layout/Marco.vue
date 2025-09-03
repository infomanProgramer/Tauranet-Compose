<template>
    <div class="marco-component">
        <div class="cabecera">
            <div class="encabezdo-style"><h3><i :class="icono"></i> {{titulo}}</h3></div>
            <div class="datos_restaurante align-self-center" v-if="data_res!={}">
                {{data_res.restaurant}} <br>
                <span class="datos_sucursal" v-if="data_res.sucursal!=null">{{data_res.sucursal}}</span> <br>
                <span class="datos_sucursal" v-if="data_res.caja!=null">{{data_res.caja}}</span>
            </div>
        </div>
        <div class="contenido-style-body">
            <slot></slot>
        </div>
    </div>
</template>
<script>
    import {misMixins} from '@/mixins/misMixins.js';
    export default{
        name: 'Marco',
        props: {
            titulo: {
                type: String,
            },
            icono: {
                type: String
            }
        },
        data(){
            return {
                data_usr: {},
                data_res: {}
            }
        },
        mixins: [misMixins],
        created () {
            this.getDataUser(this.$store.state.type_user).then(response => {
                let id = -1;
                this.data_usr = response.data;
                if(this.$store.state.type_user == 0){//mozo
                    id = this.data_usr.id_mozo
                }else if(this.$store.state.type_user == 1){//cajero
                    id = this.data_usr.id_cajero
                }else if(this.$store.state.type_user == 2){//administrador
                    id = this.data_usr.id_administrador
                }else if(this.$store.state.type_user == 3){//super administrador
                    id = this.data_usr.id_superadministrador
                }else if(this.$store.state.type_user == 4){//cocinero
                    id = this.data_usr.id_cocinero
                }
                if((this.$store.state.type_user == 0) || (this.$store.state.type_user == 1) || (this.$store.state.type_user == 2) || (this.$store.state.type_user == 4)){
                    this.getDataRestaurante(this.$store.state.type_user, id)
                    .then(response => {
                        this.data_res = response.data.data[0]
                        this.$store.dispatch('retrieveDataRestaurantAction', this.data_res)
                    }).catch(error => {
                        this.$toasted.show(error, {type: 'error'})
                    })
                }
            }).catch(error => {
                this.$toasted.show(error, {type: 'error'})
            });
        },
    }
</script>
<style lang="scss">
    .cabecera{
        display: flex;
        justify-content: space-between;
        margin-right: 2rem;
        .encabezdo-style{
            margin: 1rem 0rem .5rem 2rem;
            font-size: 1.5rem;
            color: #5E5E5E;
        }
        .datos_restaurante{
            color: #5E5E5E;
            float: right;
            font-size: .9rem;
            font-weight: bold;
            text-align: right;
            line-height: 1.1;
            .datos_sucursal{
                font-size: .8rem;
                font-weight: normal;
            }
        }
    }
    .contenido-style-body{
        background-color: white;
        margin: 0rem 2rem 2rem 2rem;
        border-radius: .5rem;
        border-top: 3px solid #f44336;
        padding: 1rem;
    }
</style>