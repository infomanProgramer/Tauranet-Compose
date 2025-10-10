<template>
    <!-- Modal -->
    <div class="modal" :id="idModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLabel"><i v-if="icono!=''" :class="icono"></i> {{titulo}}</h5>
                    <!-- <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                    </button> -->
                </div>
                <div class="modal-body">
                    <slot name="body"></slot>
                </div>
                <div class="modal-footer">
                    <slot name="footer"></slot>
                </div>
            </div>
        </div>
    </div>
</template>
<script>
    export default{
        name: 'Modal',
        props: {
            titulo: {
                type: String
            },
            idModal: {
                type: String
            },
            icono:{
                type: String,
                default: ''
            }
        },
        mounted () {
            window.$(`#${this.idModal}`).modal({ backdrop: 'static', keyboard: false, show: false})
        }
    }
</script>
<style land="scss">
    .modal-header{
        background-color: #4caf50;
    }
    .modal-title{
        /*color: #636363;*/
        color: white;
        font-weight: bold;
        font-size: 1.6rem;
    }
</style>