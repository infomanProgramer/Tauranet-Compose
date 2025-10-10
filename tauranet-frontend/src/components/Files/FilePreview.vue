<template>
  <div class="container">
    <div class="large-12 medium-12 small-12 cell">
      <label>File Preview
        <input type="file" id="file" ref="file" accept="image/*" v-on:change="handleFileUpload()"/>
      </label>
      <img v-bind:src="imagePreview" v-show="showPreview"/>
      <button v-on:click="submitFile()">Submit</button>
    </div>
  </div>
</template>