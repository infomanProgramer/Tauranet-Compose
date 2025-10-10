<template>
<div class="ticket">
<div class="center section">
RESTAURANTE EL BUEN SABOR<br>
Av. Siempre Viva #123<br>
La Paz - Bolivia<br>
NIT: 1234567890123
</div>

<div class="section">
<div class="line">
    <span>Mesa: 12</span>
    <span>Mozo: Juan</span>
</div>
<div class="line">
    <span>Fecha: 04/09/2025</span>
    <span>Hora: 12:45</span>
</div>
</div>

<div class="section">
<div class="line">
    <span>2 x Pollo a la Brasa</span>
    <span>90.00</span>
</div>
<div class="line">
    <span>1 x Jugo Natural</span>
    <span>8.00</span>
</div>
<div class="line">
    <span>3 x Soda</span>
    <span>18.00</span>
</div>
</div>

<div class="section">
<div class="line">
    <span>Subtotal</span>
    <span>116.00</span>
</div>
<div class="line">
    <span>Servicio 10%</span>
    <span>11.60</span>
</div>
<div class="line">
    <strong>TOTAL Bs.</strong>
    <strong>127.60</strong>
</div>
</div>

<div class="center section">
¡Gracias por su preferencia!<br>
Síguenos en Instagram: @elbuen_sabor
</div>
</div>
</template>

<script>
import moment from 'moment';

export default {
    name: 'ComandaCliente',
    props: {
        pedido: {
            type: Object,
            required: true
        },
        cliente: {
            type: Object,
            default: () => ({
                nombre_completo: '',
                dni: ''
            })
        },
        productos: {
            type: Array,
            default: () => []
        },
        observaciones: {
            type: String,
            default: ''
        }
    },
    data() {
        return {
            fechaActual: moment().format('DD/MM/YYYY'),
            horaActual: moment().format('HH:mm')
        };
    },
    computed: {
        cliente_computed() {
            return this.cliente || { nombre_completo: 'MOSTRADOR', dni: '' };
        },
        productos_computed() {
            return this.productos || [];
        },
        nroPedido_computed() {
            return this.pedido?.nro_pedido || '--';
        },
        getIdentificacion() {
            return this.cliente?.tipo_identificacion === 'RUC' ? 'RUC' : 'DNI';
        },
        getDataRestaurante() {
            return this.$store.getters['configuracion/restaurante'] || {};
        }
    },
    mounted() {
        // Actualizar la hora cada minuto
        this.interval = setInterval(() => {
            this.horaActual = moment().format('HH:mm');
        }, 60000);
    },
    beforeDestroy() {
        if (this.interval) {
            clearInterval(this.interval);
        }
    }
};
</script>

<style scoped>
 @media print {
    body {
      width: 72mm;                  /* ancho útil de impresión */
      font-family: "Courier New", monospace;
      font-size: 12pt;              /* simula Fuente A */
      margin: 0;
    }
    .ticket, .comanda {
      width: 100%;
    }
    .center {
      text-align: center;
    }
    .line {
      display: flex;
      justify-content: space-between;
      border-bottom: 1px dashed #000;
      padding: 2px 0;
    }
    .section {
      margin-bottom: 5px;
    }
  }
</style>
