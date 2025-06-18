<template>
  <div id="app">
    <router-view></router-view>
    <vue-progress-bar></vue-progress-bar>
  </div>
</template>
<style lang="scss">
  @import './src/assets/styles/custom.scss';
  @import '../node_modules/bootstrap/scss/bootstrap.scss';
  #app{
    background-color: #D3D3D3;
  }
</style>