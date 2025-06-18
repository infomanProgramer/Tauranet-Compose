import Vue from "vue";
import Router from "vue-router";
import Main from "./views/Main";
import Login from "./views/Auth/Login";
import Logout from "./components/Auth/Logout";
import Sucursal from "./views/Administrador/sucursales/Sucursal";
import Sucursales from "./views/Superadmin/Sucursales";
import Caja from "./views/Administrador/sucursales/Caja";
import LoginSA from "./views/Auth/LoginSA";
import Restaurant from "./views/Superadmin/Restaurant";
import Administrador from "./views/Superadmin/Administrador";
import GestorEmpleados from "./views/Administrador/Personal/GestorEmpleados";
import CategoriaProductos from "./views/Administrador/Productos/CategoriaProductos";
import Productos from "./views/Administrador/Productos/Productos";
import NuevoPedido from "./views/Cajero/NuevoPedido";
import AperturaCierre from "./views/Cajero/AperturaCierre";
import HistorialPedidos from "./views/Cajero/HistorialPedidos";
import TipoMoneda from "./views/Administrador/Config/TipoMoneda";
import facturaCocina from "./components/Invoices/facturaCocina";
import Password from "./views/Config/Password";
import ConfigDni from "./views/Administrador/Config/ConfigDni";
import Hoy from "./views/Administrador/Reportes/Hoy";
import CajaReport from "./views/Administrador/Reportes/CajaReport";
import DetalleVentas from "./views/Administrador/Reportes/DetalleVentas";
import Estadisticas from "./views/Administrador/Reportes/Estadisticas";
import CocinaPedidos from "./views/Cocinero/CocinaPedidos";

Vue.use(Router);

export default new Router({
  mode: "history",
  base: process.env.BASE_URL,
  routes: [
    {
      path: "/",
      name: "login",
      component: Login
    },
    {
      path: "/superadmin",
      name: "superadmin",
      component: LoginSA
    },
    {
      path: "/logout",
      name: "logout",
      component: Logout,
      meta: {
        requiresAuth: true,
        requiresAllUsers: true
      }
    },
    {
      name: "facturacocina",
      path: "/facturacocina",
      component: facturaCocina,
      meta: {
        requiresAuth: true
      }
    },
    {
      path: "/main",
      name: "main",
      component: Main,
      meta: {
        requiresAuth: true
      },
      children: [
        //Rutas Administrador
        {
          name: "configdni",
          path: "configdni",
          component: ConfigDni,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "tipomoneda",
          path: "tipomoneda",
          component: TipoMoneda,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "sucursal",
          path: "sucursal",
          component: Sucursal,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "caja",
          path: "caja",
          component: Caja,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "gestorempleados",
          path: "gestorempleados",
          component: GestorEmpleados,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "categoriproductos",
          path: "categoriproductos",
          component: CategoriaProductos,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "productos",
          path: "productos",
          component: Productos,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "hoy",
          path: "hoy",
          component: Hoy,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "detalleventas",
          path: "detalleventas",
          component: DetalleVentas,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "estadisticas",
          path: "estadisticas",
          component: Estadisticas,
          meta: {
            requiresRolAdministrador: true
          }
        },
        {
          name: "cajareport",
          path: "cajareport",
          component: CajaReport,
          meta: {
            requiresRolAdministrador: true
          }
        },
        //Rutas Cajero
        {
          name: "nuevopedido",
          path: "nuevopedido",
          component: NuevoPedido,
          meta: {
            requiresCajeroOrMozo: true
          }
        },
        {
          name: "aperturacierre",
          path: "aperturacierre",
          component: AperturaCierre,
          meta: {
            requiresRolCajero: true
          }
        },
        {
          name: "historialpedidos",
          path: "historialpedidos",
          component: HistorialPedidos,
          meta: {
            requiresCajeroOrMozo: true
          }
        },
        {
          name: "password",
          path: "password",
          component: Password,
          meta: {
            requiresAllUsers: true
          }
        },
        //Rutas cocinero
        {
          name: "cocinapedidos",
          path: "cocinapedidos",
          component: CocinaPedidos,
          meta: {
            requiresCocinero: true
          }
        },
        //Rutas superadministrador
        {
          name: "restaurant",
          path: "restaurant",
          component: Restaurant,
          meta: {
            requiresAuth: true,
            requiresSuperAdmin: true
          }
        },
        {
          name: "sucursales",
          path: "sucursales",
          component: Sucursales,
          meta: {
            requiresAuth: true,
            requiresSuperAdmin: true
          }
        },
        {
          name: "administrador",
          path: "administrador",
          component: Administrador,
          meta: {
            requiresAuth: true,
            requiresSuperAdmin: true
          }
        }
      ]
    }
  ]
});
