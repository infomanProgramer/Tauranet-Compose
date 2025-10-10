<template>
    <div class="image-delete-producto">
        <img :src="url_image" class="img-fluid" alt="No se encontro la imagen" width="400" height="400">
        <a href="#" class="btn btn-primary" v-on:click="$emit('deleteImgProductMethod')">Eliminar</a>
    </div>
</template>
<script>
export default{
    name: 'DeleteImageProducto',
    props: ['url_image']
}
</script>
<style lang="scss">
    .image-delete-producto{
        text-align: center;
        a{
            background-color: transparent;
            border-color: transparent;
            color: transparent;
            position: relative;
            top: -3rem;
            &:focus{
                box-shadow: 0 0 0 0.2rem transparent;
            }
        }
        &:hover{
            a{
                background-color: white;
                border-color: white;
                color: black;
                opacity: 0.5;
            }
        }     
    }
</style>