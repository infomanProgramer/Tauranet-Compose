<template>
    <ul class="nav flex-column" id="MenuLeft" :class="{ collapsed }" :style="collapsed ? { minWidth: '3rem', width: '3rem' } : {}">
        <li class="nav-item" id="logo-tauranet">
            <!-- Logo -->
            <a class="navbar-brand" href="#">
                <template v-if="collapsed">
                    <span style="font-weight: bold; display: flex; align-items: center; justify-content: center;">TN</span>
                </template>
                <template v-else>
                    <img alt="Perfil Usuario" src="../../assets/logo-tauranet.svg" width="120"/>
                </template>
            </a>
        </li>
        <li class="nav-item" id="datos-usuario">
            <!-- Opciones del Usuario -->
            <a data-toggle="collapse" href="#subMenuAdministrador" class="custom-menu-link-profile" :style="collapsed ? { display: 'flex', alignItems: 'center', justifyContent: 'center' } : {}" role="button" aria-expanded="false" aria-controls="collapseExample" @click="changeArrowA">
                <img id="foto-perfil" :src="fotoperfil" class="rounded-circle" alt="Cinque Terre" width="40" height="40">
                <div class="align-middle" v-if="!collapsed" style="line-height: 1.2; height: 100%; width: 100%; display: flex; flex-direction: column; justify-content: center;">
                    <strong><DataUser :dataReturn="['nombre_usuario']"></DataUser></strong>
                    <span id="rol_usuario" style="font-size: 0.85rem; color: #b0b0b0; margin-top: 2px;">{{rol}}</span>
                </div>
                <i v-show="!collapsed" class="fas fa-angle-left arrow icon-right-profile" ref="iconoSubMenuAdmin"></i>
            </a>
            <!-- Sub menu -->
            <ul class="collapse deleteStyleUL" id="subMenuAdministrador">
                <li>
                    <router-link :to="{name: 'logout'}" :style="collapsed ? { display: 'flex', alignItems: 'center', justifyContent: 'center' } : {}">
                        <i class="fas fa-sign-out-alt" style="margin-right: 8px;"></i>
                        <span v-show="!collapsed">Cerrar sesión</span>
                    </router-link>
                </li>
            </ul>
        </li>
        <li class="nav-item" v-for="item in menu" :key="item.id">
            <a data-toggle="collapse" :href="'#collapseExample'+item.id" role="button" aria-expanded="false" aria-controls="collapseExample" @click="changeArrow(item.id-1)" v-if="item.sub_menus.length>0" class="custom-menu-link" :style="collapsed ? { display: 'flex', alignItems: 'center', justifyContent: 'center' } : {}">
                <i :class="item.icon+' menu-icon icon-left'"></i>
                <span class="text-menu-item" v-show="!collapsed">{{item.name}}</span>
                <i
                    v-if="item.sub_menus.length>0"
                    class="fas fa-angle-left arrow icon-right"
                    ref="iconoSubMenu"
                    v-show="!collapsed"></i>
            </a>
            <router-link class="custom-menu-link" tag="a" v-else :to="{name: item.name_path}" active-class="activo_sub_menu" exact-active-class="activo_sub_menu" :style="collapsed ? { display: 'flex', alignItems: 'center', justifyContent: 'center' } : {}">
                <i :class="item.icon+' menu-icon icon-left'"></i>
                <span class="text-menu-item" v-show="!collapsed">{{item.name}}</span>
                <i v-show="false" class="fas fa-angle-left arrow icon-right" ref="iconoSubMenu"></i>
            </router-link>
            <!-- sub menu -->
            <ul class="collapse deleteStyleUL" :id="'collapseExample'+item.id">
                <!-- <li v-for="sub in item.sub_menus" :key="sub.id" class="nav-link" style="justify-content: left; padding-left: 1rem; height: 2.5rem;"> -->
                <li v-for="sub in item.sub_menus" :key="sub.id" class="nav-link">
                    <router-link :to="{name: sub.name_path}" active-class="activo_sub_menu" exact-active-class="activo_sub_menu" :style="collapsed ? { display: 'flex', alignItems: 'center', justifyContent: 'center' } : {}">
                        <i class="fas fa-circle" style="font-size: 0.3rem; color: #b0b0b0; margin-right: 8px;"></i>
                        <span v-show="!collapsed">{{sub.name}}</span>
                    </router-link>
                </li>
            </ul>
        </li>
        <li class="nav-item" style="display: flex; justify-content: center; padding-top: 1rem; padding-bottom: 1rem;">
            <button @click="collapsed = !collapsed" class="btn btn-sm" :title="collapsed ? 'Mostrar menú' : 'Ocultar menú'" style="background: #444; color: #fff; border: none; border-radius: 4px; width: 2rem; height: 2rem; display: flex; align-items: center; justify-content: center;">
                <i :class="collapsed ? 'fas fa-chevron-right' : 'fas fa-chevron-left'"></i>
            </button>
        </li>
    </ul>
</template>

<script>
    import DataUser from '@/components/Auth/DataUser'
    export default{
        components: {
            DataUser,
        },
        created () {
            this.datosUsuario();
            if(parseInt(this.$store.state.type_user) === 0){//mozo
                this.rol = "Mozo"
            }else if(parseInt(this.$store.state.type_user) === 1){//Cajero
                this.rol = "Cajero"
            }else if(parseInt(this.$store.state.type_user) === 2){//Administrador
                this.rol = "Administrador"
            }else if(parseInt(this.$store.state.type_user) === 3){//Super Administrador
                this.rol = "Super Administrador"
            }else if(parseInt(this.$store.state.type_user) === 4){//Cocinero
                this.rol = "Cocinero"
            }
        },
        data() {
            return {
                rol: '',
                fotoperfil: `${this.$store.state.url_root}imgPerfilUsuarios/${this.$store.state.fotoPerfil}`,
                tipo_usuario: null,
                menu: [],
                ruta_publica: this.$store.state.url_root,
                collapsed: false,
                menu_administrador: [
                    {
                        id: 1,
                        name: 'Personal',
                        icon: "fas fa-users",
                        sub_menus: [
                            {
                                id: 1,
                                name_path: 'gestorempleados',
                                name: 'Gestor de empleados',
                            },
                        ]
                    },
                    {
                        id: 2,
                        name: 'Configuracion',
                        icon: "fas fa-wrench",
                        sub_menus: [
                            {
                                id: 1,
                                name_path: 'tipomoneda',
                                name: 'Simbolo Moneda',
                            },
                            {
                                id: 2,
                                name_path: 'password',
                                name: 'Cambiar contraseña',
                            },
                            {
                                id: 3,
                                name_path: 'configdni',
                                name: 'Tipo identificación',
                            }
                        ]
                    }
                ],
                menu_mozo: [
                    {
                        id: 1,
                        name: 'Nuevo Pedido',
                        name_path: 'nuevopedido',
                        icon: 'fas fa-plus-circle',
                        sub_menus: []
                    },
                    {
                        id: 2,
                        name: 'Historial de pedidos',
                        name_path: 'historialpedidos',
                        icon: 'fas fa-history',
                        sub_menus: []
                    },
                    {
                        id: 3,
                        name: 'Configuracion',
                        icon: "fas fa-wrench",
                        sub_menus: [
                            {
                                id: 1,
                                name_path: 'password',
                                name: 'Cambiar contraseña',
                            }
                        ]
                    },
                ],
                menu_cocinero: [
                    {
                        id: 1,
                        name: 'Historial de pedidos',
                        name_path: 'cocinapedidos',
                        icon: 'fas fa-history',
                        sub_menus: []
                    },
                    {
                        id: 2,
                        name: 'Configuracion',
                        icon: "fas fa-wrench",
                        sub_menus: [
                            {
                                id: 1,
                                name_path: 'password',
                                name: 'Cambiar contraseña',
                            }
                        ]
                    },
                ],
                menu_cajero: [
                    {
                        id: 1,
                        name: 'A/C de caja',
                        name_path: 'aperturacierre',
                        icon: 'fas fa-wallet',
                        sub_menus: []
                    },
                    {
                        id: 2,
                        name: 'Nuevo Pedido',
                        name_path: 'nuevopedido',
                        icon: 'fas fa-plus-circle',
                        sub_menus: []
                    },
                    {
                        id: 3,
                        name: 'Historial de pedidos',
                        name_path: 'historialpedidos',
                        icon: 'fas fa-history',
                        sub_menus: []
                    },
                    {
                        id: 4,
                        name: 'Productos',
                        icon: "fab fa-product-hunt",
                        sub_menus: [
                            {
                                id: 1,
                                name_path: 'categoriproductos',
                                name: 'Categoria de Productos',
                            },
                            {
                                id: 2,
                                name_path: 'productos',
                                name: 'Productos',
                            },
                        ]
                    },
                    {
                        id: 5,
                        name: 'Reportes',
                        icon: "fas fa-chart-bar",
                        sub_menus: [
                            {
                                id: 1,
                                name_path: 'ventaspordia',
                                name: 'Ventas del día',
                            },
                            {
                                id: 2,
                                name_path: 'ventasporrangofecha',
                                name: 'Ventas por rango de fecha',
                            },
                            {
                                id: 3,
                                name_path: 'detalleventas',
                                name: 'Detalle Pedidos',
                            },
                            {
                                id: 4,
                                name_path: 'detalleproducto',
                                name: 'Detalle Productos',
                            },
                        ]
                    },
                    {
                        id: 6,
                        name: 'Configuracion',
                        icon: "fas fa-wrench",
                        sub_menus: [
                            {
                                id: 1,
                                name_path: 'password',
                                name: 'Cambiar contraseña',
                            }
                        ]
                    },
                ],
                menu_superadmin: [
                    {
                        id: 1,
                        name: 'Restaurantes',
                        name_path: 'restaurant',
                        icon: 'fas fa-utensils',
                        sub_menus: []
                    },
                    {
                        id: 2,
                        name: 'Sucursales',
                        name_path: 'sucursales',
                        icon: 'fas fa-building',
                        sub_menus: []
                    },
                    {
                        id: 3,
                        name: 'Caja',
                        name_path: 'caja',
                        icon: 'fas fa-building',
                        sub_menus: []
                    },
                    {
                        id: 4,
                        name: 'Personal',
                        icon: "fas fa-users",
                        name_path: 'gestorempleados',
                        sub_menus: []
                    },
                    {
                        id: 5,
                        name: 'Configuracion',
                        icon: "fas fa-wrench",
                        sub_menus: [
                            // {
                            //     id: 1,
                            //     name_path: 'tipomoneda',
                            //     name: 'Simbolo Moneda',
                            // },
                            {
                                id: 1,
                                name_path: 'password',
                                name: 'Cambiar contraseña',
                            }
                            // {
                            //     id: 3,
                            //     name_path: 'configdni',
                            //     name: 'Tipo identificación',
                            // }
                        ]
                    }
                ]
            }
        },
        methods: {
            datosUsuario() {
                this.menu = [];
                this.tipo_usuario = this.$store.state.type_user;
                if(this.tipo_usuario == 0){//Si es mozo
                    this.menu = this.menu_mozo; 
                }else if(this.tipo_usuario == 1){//Si es cajero
                    this.menu = this.menu_cajero;
                }else if(this.tipo_usuario == 2){//Si es administrador
                    this.menu = this.menu_administrador;
                }else if(this.tipo_usuario == 3){//Si es super administrador
                    this.menu = this.menu_superadmin;
                }else if(this.tipo_usuario == 4){//Si es super administrador
                    this.menu = this.menu_cocinero;
                }
            },
            changeArrow(i){
                if(this.$refs.iconoSubMenu[i].className == "fas fa-angle-left arrow icon-right"){
                    this.$refs.iconoSubMenu[i].className = "fas fa-angle-down arrow icon-right";
                }else{
                    this.$refs.iconoSubMenu[i].className = "fas fa-angle-left arrow icon-right";
                }
            },
            changeArrowA(){
                if(this.$refs.iconoSubMenuAdmin.className == "fas fa-angle-left arrow icon-right-profile"){
                    this.$refs.iconoSubMenuAdmin.className = "fas fa-angle-down arrow icon-right-profile";
                }else{
                    this.$refs.iconoSubMenuAdmin.className = "fas fa-angle-left arrow icon-right-profile";
                }
            }
        },
    }
</script>

<style lang="scss">
    #MenuLeft{
        // min-width: 15rem;
        min-height: 100vh;
        background-color: #383838;
        >li{
            #rol_usuario{
                font-size: 0.7rem;
            }
            #foto-perfil{
                background-color: white;
                margin-left: .5rem;
                margin-right: .5rem;
            }
            >a{
                width: 100%;
                color: #D3D3D3;
                >i{
                    text-align: center;
                    box-sizing: border-box;
                    width: 2rem;
                    height: 2rem;
                }
                .arrow{
                    float: right;
                }
                .menu-text{
                    margin-left: .5rem;
                }
            }
            //sub menu
            ul{
                // background-color: #5E5E5E;
                >li>a{
                    color: #D3D3D3;
                }
            }
            #subMenuAdministrador{
                background-color: transparent;
                color: #D3D3D3;
            }
        }
        #logo-tauranet{
            text-align: center;
            padding: .5rem 0rem .5rem 0rem;
        }
        #datos-usuario{
            background-color: #35465C;
        }
        .custom-menu-link{
            display: flex; 
            flex-direction: row; 
            justify-content: space-between; 
            align-items: center;
            height: 3rem; 
            text-decoration: none;
            padding-right: .7rem;
            .icon-left{
            display: flex; 
            align-items: center; 
            justify-content: center; 
            padding-left: 0.5rem;
            }
            .icon-right{
            display: flex; 
            align-items: center; 
            justify-content: right; 
            }
            .text-menu-item{
            display: flex;
            align-items: center;
            justify-content: left;
            padding-left: .5rem; 
            width: 100%;
            }
            &:hover {
            background-color: #444;
            color: #fff;
            .text-menu-item {
                color: #fff;
            }
            .icon-left, .icon-right {
                color: #fff;
            }
            }
        }
        .custom-menu-link-profile{
            display: flex;
            flex-direction: row;
            align-items: center;
            justify-content: space-between;
            //height: 100%;
            text-decoration: none;
            padding-right: 0.7rem;
            padding-top: 1rem;
            padding-bottom: 1rem;
            .icon-right-profile{
                height: 100%;
                display: flex;
                flex-direction: row;
                align-items: center;
                justify-content: right;
            }
        }
    }
    #MenuLeft.collapsed{
        min-width: 5rem !important;
        width: 5rem !important;
        overflow: hidden;
    }
    .activo_sub_menu {
        font-weight: 600;
        color: #1976d2;
        background: #737373cc;
        border-radius: 6px;
        box-shadow: 0 2px 8px rgba(25, 118, 210, 0.08);
        transition: background 0.2s, color 0.2s;
    }
    .deleteStyleUL{
        background: none;
        box-shadow: none;
        border: none;
        padding-left: 0;
        margin: 0;
        >li{
            list-style: none; 
            padding: 0; 
            margin: 0; 
            background-color: transparent; 
            height: 3rem; 
            display: flex; 
            flex-direction: row; 
            justify-content: center; 
            align-items: center;
            transition: background 0.2s;
            >a{
            text-decoration: none; 
            width: 100%; 
            height: 100%; 
            display: flex; 
            flex-direction: row; 
            justify-content: left; 
            align-items: center; 
            padding-left: .5rem;
            }
            &:hover {
            background-color: #444; // Cambia el color de fondo al pasar el mouse
            >a {
                color: #fff; // Cambia el color del texto al pasar el mouse
            }   
            }
        }
    }
</style>