<template>
    <div :class="name_property" role="alert" v-if="!message == ''" class="boxMessageAncho" v-html="tieneIcono+message"></div>
</template>
<script>
    export default{
        name: 'BoxMessage',
        props: {
            cod: {
                type: String,
            },
            message: {
                type: String,
            },
            icono: {
                type: String,
                default: ''
            },
        },
        data() {
            return {
                types: [
                    {id: 1, cod: 'pr', color: 'primary'},
                    {id: 2, cod: 'se', color: 'secondary'},
                    {id: 3, cod: 'su', color: 'success'},
                    {id: 4, cod: 'da', color: 'danger'},
                    {id: 5, cod: 'wa', color: 'warning'},
                    {id: 6, cod: 'in', color: 'info'},
                    {id: 7, cod: 'li', color: 'light'},
                    {id: 8, cod: 'dk', color: 'dark'}
                ],
                icon: ''
            }
        },
        computed: {
            name_property() {
                let property = 'alert alert-'
                this.types.forEach(element => {
                    if(element.cod === this.cod){
                        property += element.color;
                    }
                });
                return property;
            },
            tieneIcono(){
                if(this.icono != ''){
                    this.icon = `<i class="${this.icono}"></i> `
                    return this.icon
                }else{
                    return '';
                }
                
            }
        }
    }
</script>
<style lang="scss">
    .boxMessageAncho{
        width: 100%;
    }
</style>