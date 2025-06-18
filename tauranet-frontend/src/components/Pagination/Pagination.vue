<template>
    <nav aria-label="...">
        <ul class="pagination">
            <li :class="{disabled: !pagination.first_page_url}" v-on:click="$emit('funcion', pagination.first_page_url)" class="page-item"><a class="page-link" href="#">First</a></li>
            <li :class="{disabled: !pagination.prev_page_url}" v-on:click="$emit('funcion', pagination.prev_page_url)" class="page-item"><a class="page-link" href="#">Previous</a></li>
            <li :class="{active: pagination.current_page == n}" v-on:click="$emit('funcion', pagination.path+'?page='+n)" v-for="n in pagination.last_page"  :key="n" class="page-item"><a class="page-link" href="#">{{n}}</a></li>
            <li :class="{disabled: !pagination.next_page_url}" v-on:click="$emit('funcion', pagination.next_page_url)" class="page-item"><a class="page-link" href="#">Next</a></li>
            <li :class="{disabled: !pagination.last_page_url}" v-on:click="$emit('funcion', pagination.last_page_url)" class="page-item"><a class="page-link" href="#">Last</a></li>
        </ul>
    </nav>
</template>
<script>
    export default{
        name: 'Pagination',
        props: {
            pagination: {
                type: Object,
                default: {}
            },
        }
    }
</script>
<style lang="scss">
    //  @import './src/assets/styles/custom.scss';
    // //@import '../node_modules/bootstrap/scss/bootstrap.scss';
    .disabled{
        pointer-events: none;
        cursor: not-allowed;
    }
    .pagination > li > a{
        color: #3A85AB;
    }
</style>