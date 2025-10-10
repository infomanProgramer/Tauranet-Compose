<template>
</template>
<script>
    export default{
        created () {
            if(this.$store.state.type_user == 3){
                this.$store.dispatch('destroyToken')
                .then(resonse => {
                    this.$router.push({name: 'superadmin'})
                })
                .catch(error => {
                    alert("Logout.vue: "+error);
                })
            }else{
                this.$store.dispatch('destroyToken')
                .then(resonse => {
                    this.$router.push({name: 'login'})
                })
                .catch(error => {
                    alert("Logout.vue: "+error);
                })
            }
        },
    }
</script>