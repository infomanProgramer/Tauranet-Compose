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
import CategoriaProductos from "./views/Cajero/Productos/CategoriaProductos";
import Productos from "./views/Cajero/Productos/Productos";
import NuevoPedido from "./views/Cajero/NuevoPedido";
import AperturaCierre from "./views/Cajero/AperturaCierre";
import HistorialPedidos from "./views/Cajero/HistorialPedidos";
import TipoMoneda from "./views/Administrador/Config/TipoMoneda";
import facturaCocina from "./components/Invoices/facturaCocina";
import Password from "./views/Config/Password";
import ConfigDni from "./views/Administrador/Config/ConfigDni";
import Hoy from "./views/Cajero/Reportes/Hoy";
import CajaReport from "./views/Cajero/Reportes/CajaReport";
import DetalleVentas from "./views/Cajero/Reportes/DetalleVentas";
import Estadisticas from "./views/Cajero/Reportes/Estadisticas";
import CocinaPedidos from "./views/Cocinero/CocinaPedidos";
import VentasPorDia from "./views/Cajero/Reportes/VentasPorDia";
import VentasPorRangoFecha from "./views/Cajero/Reportes/VentasPorRangoFecha";

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
          name: "categoriproductos",
          path: "categoriproductos",
          component: CategoriaProductos,
          meta: {
            requiresCajeroOrMozo: true
          }
        },
        {
          name: "productos",
          path: "productos",
          component: Productos,
          meta: {
            requiresCajeroOrMozo: true
          }
        },
        {
          name: "hoy",
          path: "hoy",
          component: Hoy,
          meta: {
            requiresRolCajero: true
          }
        },
        //Rutas Reportes
        {
          name: "ventaspordia",
          path: "ventaspordia",
          component: VentasPorDia,
          meta: {
            requiresRolCajero: true
          }
        },
        {
          name: "ventasporrangofecha",
          path: "ventasporrangofecha",
          component: VentasPorRangoFecha,
          meta: {
            requiresRolCajero: true
          }
        },
        //Fin de Rutas Reportes
        {
          name: "detalleventas",
          path: "detalleventas",
          component: DetalleVentas,
          meta: {
            requiresRolCajero: true
          }
        },
        {
          name: "estadisticas",
          path: "estadisticas",
          component: Estadisticas,
          meta: {
            requiresRolCajero: true
          }
        },
        {
          name: "cajareport",
          path: "cajareport",
          component: CajaReport,
          meta: {
            requiresRolCajero: true
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
