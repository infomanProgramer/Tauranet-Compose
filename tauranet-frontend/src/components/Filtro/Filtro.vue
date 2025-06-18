<template>
    <div>
        <div class="form-group">
            <label for=""><strong>Buscar por:</strong></label>
            <div class="form-check" v-for="item in filterArray" :key="item.ide">
                <input class="form-check-input" type="radio" name="radio" ref="item.modelName" @click="changeInputText(item.id)">
                <label class="form-check-label" for="exampleRadios1">
                    {{item.labelName}}
                </label>
            </div>
        </div>
        <div v-for="item in arraySw" :key="item.ide">
            <div id="styleSearchInput" v-if="item.sw">
                <input type="text" v-if="item.sw" v-model="item.search" :placeholder="item.textPlaceHolder" ref="search" :name="'nombre'+item.ide" @change="$emit('variableFilter', item)">
                <button type="submit" v-if="item.sw" class="btn btn-primary" @click="$emit('variableFilter', item)"><i class="fas fa-search"></i></button>
            </div>
        </div>
    </div>
</template>
<script>
    export default{
        name: 'Filtro',
        props: {
            filterArray: {
                type: Array,
                required: true
            },
        },
        data() {
            return {
                arraySw: [],
                variableFiltro: ''
            }
        },
        created () {
            if(this.filterArray.length>0){
                this.arraySw.push({ide: 0, sw: false, search: '', textPlaceHolder: this.filterArray[0].placeholderText});
                for(let i = 1; i<=this.filterArray.length-1; i++){
                    this.arraySw.push({ide: i, sw: false, search: '', textPlaceHolder: this.filterArray[i].placeholderText});
                }
            }
        },
        methods: {
            changeInputText(k) {
                for(var i = 0; i<=this.arraySw.length-1; i++){
                    if(k==i && i!=0){
                        this.arraySw[i].sw = true;
                        this.variableFiltro = this.arraySw[i].search
                    }else{
                        this.arraySw[i].sw = false;
                        this.arraySw[i].search = '';
                    }
                }
            }
        },
    }
</script>
<style lang="scss">
    #styleSearchInput{
        border: 1px solid #ced4da;
        display: flex;
        width: auto;
        padding: 0.25rem;
        border-radius: 0.5rem;
        >input{
            border-style: none;
            width: 100%;
            &:focus{
                outline: none;
            }
        }
        >button{
            border-radius: 0 0.5rem 0.5rem 0; 
        }
        &:focus{
            outline: -webkit-focus-ring-color auto 1px;
        }
    }
</style>