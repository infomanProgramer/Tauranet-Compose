<template>
    <div id="cuerpo">
      <MenuLeft class="menu-izquierdo"></MenuLeft>
      <router-view class="contenido-principal"></router-view>
       <!-- <keep-alive>
        <router-view :key="$route.fullPath" class="contenido-principal"></router-view>
      </keep-alive> -->
    </div>
</template>
<script>
  import MenuLeft from '@/views/Menu/MenuLeft'
  export default{
    components: {
      MenuLeft
    }
  }
</script>
<style lang="scss">
  #cuerpo{
    display: flex;
  }
  .menu-izquierdo{
    min-width: 15rem!important;
  }
  .contenido-principal{
    width: 100%;
    overflow-x: hidden;
  }
  .inputSearchText{
        max-width: 20rem;
        height: 2rem;
        padding: 3px;
        margin-bottom: 0.5rem;
        border-style: none;
        border-bottom: 1px solid #5E5E5E;
        float: right;
  }
  .head-table{
    background-color: ghostwhite;
    color: black;
  }
  .new-btn-primary{// No se esta utilizando
    background-color: #3a85ab;
    border-color: #3a85ab;
  }
  .btnEliminarImagen{
        position: absolute;
        color: red;
        right: 5px;
        top: 5px;
    }
</style>