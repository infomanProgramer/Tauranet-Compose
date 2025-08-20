<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Response;
use DB;
use Maatwebsite\Excel\Facades\Excel;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Illuminate\Support\Facades\Log;
use PDF;
use Illuminate\Http\Request;
use DateTime;
use Illuminate\Pagination\LengthAwarePaginator;

class ReporteVentasPorRangoFechaController extends ApiController
{
     /**
     * Calcula los totales por rango de fecha
     *
     * @param int $idRestaurante
     * @param string $fechaInicio
     * @param string $fechaFin
     * @return object
     */
    private function calculoTotales($idRestaurante, $fechaInicio, $fechaFin)
    {
        return DB::table('venta_productos as vp')
        ->join('pagos as p', 'p.id_venta_producto', '=', 'vp.id_venta_producto')
        ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
        ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
        ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
        ->where('s.id_restaurant', $idRestaurante)
        ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
        ->selectRaw('
            COALESCE(COUNT(*), 0) as total_pedidos,
            COALESCE(SUM(p.importe), 0) as total_ventas,
            COALESCE((SUM(p.importe) - SUM(p.importe_base)), 0) as total_ganancia
        ')
        ->first();
    }
    public function getReportByInterval(Request $request)
    {
        Log::info('Request recibido en getReporteByInterval', ['request' => $request->all()]);
        $idRestaurante = $request->input('idRestaurante');
        $fechaInicio = $request->input('fecha_inicio');
        $fechaFin = $request->input('fecha_fin');

        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fechaInicio) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $fechaFin)) {
            return response()->json(['error' => 'El formato de las fechas debe ser YYYY-MM-DD.'], 400);
        }

        if (strtotime($fechaInicio) === false || strtotime($fechaFin) === false) {
            return response()->json(['error' => 'Las fechas proporcionadas no son válidas.'], 400);
        }

        if ($fechaInicio > $fechaFin) {
            return response()->json(['error' => 'La fecha de inicio no puede ser mayor que la fecha de fin.'], 400);
        }

        // Validar las fechas
        if (!$fechaInicio || !$fechaFin) {
            return response()->json(['error' => 'Las fechas de inicio y fin son requeridas.'], 400);
        }
        
        $ventasPorRangoFecha = DB::table(DB::raw("reporte_ventas_por_rango_fecha_detallegeneral(". $idRestaurante .",'". $fechaInicio ."', '". $fechaFin ."')"))->paginate(10);

        //Obtenemos totales por rango de fecha
        $totalesRangoFecha = $this->calculoTotales($idRestaurante, $fechaInicio, $fechaFin);

        $totalEfectivo = DB::table('venta_productos as vp')
            ->join('pagos as p', function ($join) {
                $join->on('p.id_venta_producto', '=', 'vp.id_venta_producto')
                    ->where('p.tipo_pago', '=', 0);
            })
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('s.id_restaurant', $idRestaurante)
            ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
            ->selectRaw('SUM(p.importe) as total_efectivo')
            ->first();
        
         $totalTarjeta = DB::table('venta_productos as vp')
            ->join('pagos as p', function ($join) {
                $join->on('p.id_venta_producto', '=', 'vp.id_venta_producto')
                    ->where('p.tipo_pago', '=', 1);
            })
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('s.id_restaurant', $idRestaurante)
            ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
            ->selectRaw('SUM(p.importe) as total_tarjeta')
            ->first();

        $totalQR = DB::table('venta_productos as vp')
            ->join('pagos as p', function ($join) {
                $join->on('p.id_venta_producto', '=', 'vp.id_venta_producto')
                    ->where('p.tipo_pago', '=', 2);
            })
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('s.id_restaurant', $idRestaurante)
            ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
            ->selectRaw('SUM(p.importe) as total_qr')
            ->first();

        $response = Response::json([
            'ventasPorRangoFecha' => $ventasPorRangoFecha, 
            'totalDia' => $totalesRangoFecha, 
            'totalEfectivo' => $totalEfectivo,
            'totalTarjeta' => $totalTarjeta,
            'totalQR' => $totalQR
        ], 200);
        return $response;
    }
    
    public function getReportByIntervalExcel(Request $request)
    {
        Log::info('Request recibido en getReporteByIntervalExcel', ['request' => $request->all()]);
        $idRestaurante = $request->input('idRestaurante');
        $fechaInicio = $request->input('fecha_inicio');
        $fechaFin = $request->input('fecha_fin');

        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $fechaInicio) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $fechaFin)) {
            return response()->json(['error' => 'El formato de las fechas debe ser YYYY-MM-DD.'], 400);
        }

        if (strtotime($fechaInicio) === false || strtotime($fechaFin) === false) {
            return response()->json(['error' => 'Las fechas proporcionadas no son válidas.'], 400);
        }

        if ($fechaInicio > $fechaFin) {
            return response()->json(['error' => 'La fecha de inicio no puede ser mayor que la fecha de fin.'], 400);
        }

        // Validar las fechas
        if (!$fechaInicio || !$fechaFin) {
            return response()->json(['error' => 'Las fechas de inicio y fin son requeridas.'], 400);
        }
        
        $ventasPorRangoFecha = DB::table(DB::raw("reporte_ventas_por_rango_fecha_detallegeneral(". $idRestaurante .",'". $fechaInicio ."', '". $fechaFin ."')"))->get();

        // Usar Maatwebsite\Excel para exportar
        // Crear un array de arrays para exportar
        $exportData = [];
        foreach ($ventasPorRangoFecha as $row) {
            $exportData[] = [
                'Fecha' => $row->fecha,
                'Cantidad' => $row->cantidad,
                'Total efectivo' => $row->total_efectivo,
                'Total tarjeta' => $row->total_tarjeta,
                'Total qr' => $row->total_qr,
                'Total ventas' => $row->total_ventas,
                'Total ganancias' => $row->total_ganancias
            ];
        }
        // Crear una clase exportadora anónima
        $export = new class($exportData) implements FromCollection, WithHeadings {
            private $data;
            public function __construct($data) { $this->data = $data; }
            public function collection() { return collect($this->data); }
            public function headings(): array {
                return [
                    'Fecha',
                    'Cantidad',
                    'Total efectivo',
                    'Total tarjeta',
                    'Total qr',
                    'Total ventas',
                    'Total ganancias'
                ];
            }
        };

        return Excel::download($export, 'reporte_ventas_intervalo_fechas_'.$fechaInicio.'-'.$fechaFin.'.xlsx');
    }

    public function getReportByIntervalPDF(Request $request)
    {
        $validated = $request->validate([
            'idRestaurante' => 'required|integer|exists:restaurants,id_restaurant',
            'nombre_restaurante' => 'required|string',
            'fecha_inicio' => 'required|date',
            'fecha_fin' => 'required|date',
            'sucursal' => 'required|string',
            'caja' => 'required|string',
        ]);
        if ($validated === false) {
            return response()->json(['error' => ['validacion' => ['Error de validación de datos de entrada']]], 422);
        }
        Log::info('getReportePerDayPDF - request:', $request->all());
        $idRestaurante = $request->input('idRestaurante');
        $nombre_restaurante = $request->input('nombre_restaurante');
        $fechaInicio = $request->input('fecha_inicio');
        $fechaFin = $request->input('fecha_fin');
        $sucursal = $request->input('sucursal');
        $caja = $request->input('caja');

        $listItem = DB::table(DB::raw("reporte_ventas_por_rango_fecha_detallegeneral(". $idRestaurante .",'". $fechaInicio ."', '". $fechaFin ."')"))->get();

         $exportData = [];
        foreach ($listItem as $row) {
            $exportData[] = [
                'Fecha' => $row->fecha,
                'Cantidad' => $row->cantidad,
                'Total efectivo' => $row->total_efectivo,
                'Total tarjeta' => $row->total_tarjeta,
                'Total QR' => $row->total_qr,
                'Total ventas' => $row->total_ventas,
                'Total ganancias' => $row->total_ganancias,
            ];
        }
        // Log::info('Tipo de $listItem:', ['type' => gettype($listItem), 'class' => is_object($listItem) ? get_class($listItem) : null]);
        // Log::info('Tipo de $exportData:', ['type' => gettype($exportData), 'class' => is_object($exportData) ? get_class($exportData) : null]);
        //Obtenemos totales por rango de fecha
        $totalesRangoFecha = DB::table('venta_productos as vp')
        ->join('pagos as p', 'p.id_venta_producto', '=', 'vp.id_venta_producto')
        ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
        ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
        ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
        ->where('s.id_restaurant', $idRestaurante)
        ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
        ->selectRaw('
            COUNT(*) as total_pedidos,
            SUM(p.importe) as total_ventas,
            (SUM(p.importe) - SUM(p.importe_base)) as total_ganancia
        ')
        ->first();

        $totalEfectivo = DB::table('venta_productos as vp')
            ->join('pagos as p', function ($join) {
                $join->on('p.id_venta_producto', '=', 'vp.id_venta_producto')
                    ->where('p.tipo_pago', '=', 0);
            })
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('s.id_restaurant', $idRestaurante)
            ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
            ->selectRaw('SUM(p.importe) as total_efectivo')
            ->first();
        
         $totalTarjeta = DB::table('venta_productos as vp')
            ->join('pagos as p', function ($join) {
                $join->on('p.id_venta_producto', '=', 'vp.id_venta_producto')
                    ->where('p.tipo_pago', '=', 1);
            })
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('s.id_restaurant', $idRestaurante)
            ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
            ->selectRaw('SUM(p.importe) as total_tarjeta')
            ->first();

        $totalQR = DB::table('venta_productos as vp')
            ->join('pagos as p', function ($join) {
                $join->on('p.id_venta_producto', '=', 'vp.id_venta_producto')
                    ->where('p.tipo_pago', '=', 2);
            })
            ->join('historial_caja as h', 'h.id_historial_caja', '=', 'vp.id_historial_caja')
            ->join('cajas as c', 'c.id_caja', '=', 'h.id_caja')
            ->join('sucursals as s', 's.id_sucursal', '=', 'c.id_sucursal')
            ->where('s.id_restaurant', $idRestaurante)
            ->whereBetween(DB::raw('DATE(vp.created_at)'), ["'". $fechaInicio ."'", "'". $fechaFin ."'"])
            ->selectRaw('SUM(p.importe) as total_qr')
            ->first();

        // Log::info('Tipo de $totalesRangoFecha:', ['type' => gettype($totalesRangoFecha), 'class' => is_object($totalesRangoFecha) ? get_class($totalesRangoFecha) : null]);
        // Log::info('Tipo de $totalEfectivo:', ['type' => gettype($totalEfectivo), 'class' => is_object($totalEfectivo) ? get_class($totalEfectivo) : null]);
        // Log::info('Tipo de $totalTarjeta:', ['type' => gettype($totalTarjeta), 'class' => is_object($totalTarjeta) ? get_class($totalTarjeta) : null]);
        // Log::info('Tipo de $totalQR:', ['type' => gettype($totalQR), 'class' => is_object($totalQR) ? get_class($totalQR) : null]);

        $pdf = PDF::loadView('reportes.ventas_intervalo_fecha.detalle_general', [
            'titulo_reporte' => 'REPORTE DE VENTAS POR RANGO DE FECHA',
            'nom_restaurante' => $nombre_restaurante,
            'sucursal' => $sucursal,
            'caja' => $caja,
            'listItem' => $listItem,
            'fechaIni' => $fechaInicio,
            'fechaFin' => $fechaFin,
            'totalesRangoFecha' => $totalesRangoFecha,
            'totalEfectivo' => $totalEfectivo,
            'totalTarjeta' => $totalTarjeta,
            'totalQR' => $totalQR,
        ]);

        return $pdf->download('reporteVentasPorRangoFecha'.$fechaInicio.'-'.$fechaFin.'.pdf');
    }

    public function fechaImporte(Request $request){
        Log::info('fechaImporte - request:', $request->all());
        $validated = $request->validate([
            'idRestaurante' => 'required|integer|exists:restaurants,id_restaurant',
            'fecha_inicio' => 'required|date',
            'fecha_fin' => 'required|date',
        ]);
        if ($validated === false) {
            return response()->json(['error' => ['validacion' => ['Error de validación de datos de entrada']]], 422);
        }
        $idRestaurante = $request->input('idRestaurante');
        $fechaIni = $request->input('fecha_inicio');
        $fechaFin = $request->input('fecha_fin');
        
        if($fechaIni == 'null'){
            $response = Response::json(['error' => ['ini' => ['Fecha ini es requerido']]], 200);
            return $response;
        }
        if($fechaFin == 'null'){
            $response = Response::json(['error' => ['fin' => ['Fecha fin es requerido']]], 200);
            return $response;
        }
        if($fechaIni <= $fechaFin) {
            //Chart
            $fechaImporte = DB::table(DB::raw("function_fecha_importe(" . $idRestaurante . ",'" . $fechaIni . "', '" . $fechaFin . "')"))->get();
            //Table
            $fechaImporteTable = DB::table(DB::raw("function_fecha_importe(" . $idRestaurante . ", '" . $fechaIni . "', '" . $fechaFin . "')"))->paginate(6);
            $response = Response::json(['dataChart' => $fechaImporte, 'dataTable' => $fechaImporteTable], 200);
            return $response;
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function fechaImporteExcel(Request $request){
        $validated = $request->validate([
            'idRestaurante' => 'required|integer|exists:restaurants,id_restaurant',
            'fecha_inicio' => 'required|date',
            'fecha_fin' => 'required|date'
        ]);
        if ($validated === false) {
            return response()->json(['error' => ['validacion' => ['Error de validación de datos de entrada']]], 422);
        }
        Log::info('getReportePerDayPDF - request:', $request->all());
        $idRestaurante = $request->input('idRestaurante');
        $fechaIni = $request->input('fecha_inicio');
        $fechaFin = $request->input('fecha_fin');
        
        if($fechaIni == 'null'){
            $response = Response::json(['error' => ['ini' => ['Fecha ini es requerido']]], 200);
            return $response;
        }
        if($fechaFin == 'null'){
            $response = Response::json(['error' => ['fin' => ['Fecha fin es requerido']]], 200);
            return $response;   
        }
        if($fechaIni <= $fechaFin) {
            $fechaImporte = DB::table(DB::raw("function_fecha_importe(" . $idRestaurante . ",'" . $fechaIni . "', '" . $fechaFin . "')"))->get();
            $exportData = [];
        foreach ($fechaImporte as $row) {
            $exportData[] = [
                'Fecha' => $row->fecha,
                'Importe' => $row->importe,
                'Ganancia' => $row->ganancia,
            ];
        }

        // Crear una clase exportadora anónima
        $export = new class($exportData) implements FromCollection, WithHeadings {
            private $data;
            public function __construct($data) { $this->data = $data; }
            public function collection() { return collect($this->data); }
            public function headings(): array {
                return ['Fecha', 'Importe', 'Ganancia'];
            }
        };

        return Excel::download($export, 'ventasPorRangoFechaExcel_'.$fechaIni.'_'.$fechaFin.'.xlsx');
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function fechaImportePDF(Request $request){
        $validated = $request->validate([
            'idRestaurante' => 'required|integer|exists:restaurants,id_restaurant',
            'nombre_restaurante' => 'required|string',
            'fecha_inicio' => 'required|date',
            'fecha_fin' => 'required|date',
            'sucursal' => 'required|string',
            'caja' => 'required|string',
        ]);
        if ($validated === false) {
            return response()->json(['error' => ['validacion' => ['Error de validación de datos de entrada']]], 422);
        }
        Log::info('getReportePerDayPDF - request:', $request->all());
        $idRestaurante = $request->input('idRestaurante');
        $nombre_restaurante = $request->input('nombre_restaurante');
        $fechaIni = $request->input('fecha_inicio');
        $fechaFin = $request->input('fecha_fin');
        $sucursal = $request->input('sucursal');
        $caja = $request->input('caja');
        $chartBase64 = $request->input('chartBase64', null);
        
        if($fechaIni <= $fechaFin) {
            $fechaImporte = DB::table(DB::raw("function_fecha_importe(" . $idRestaurante . ",'" . $fechaIni . "', '" . $fechaFin . "')"))->get();
            $exportData = [];

            $pdf = PDF::loadView('reportes.ventas_intervalo_fecha.fecha_importe', [
                'nom_restaurante' => $nombre_restaurante,
                'titulo_reporte' => 'VENTAS POR RANGO DE FECHA',
                'sucursal' => $sucursal,
                'caja' => $caja,
                'listItem' => $fechaImporte,
                'fechaIni' => $fechaIni,
                'fechaFin' => $fechaFin,
                'chartBase64' => $chartBase64
            ]);
    
            return $pdf->download('ventasPorRangoFechaPDF_'.$fechaIni.'_'.$fechaFin.'.pdf');
        }else{
            $response = Response::json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 200);
            return $response;
        }
    }
    public function semanaImporte(Request $request){
        Log::info('semanaImporte - request:', $request->all());
        $validated = $request->validate([
            'idRestaurante' => 'required|integer|exists:restaurants,id_restaurant',
            'fecha_inicio' => 'required|date',
            'fecha_fin' => 'required|date',
            'formato' => 'required|integer|in:1,2,3',
        ]);
        if ($validated === false) {
            return response()->json(['error' => ['validacion' => ['Error de validación de datos de entrada']]], 422);
        }
        if($request->input('fecha_inicio') > $request->input('fecha_fin')) {
            return response()->json(['error' => ['ini' => ['Fecha ini debe ser menor que Fecha fin']]], 422);
        }
        $fechaIni = $request->input('fecha_inicio');
        $fechaFin = $request->input('fecha_fin');
        $formato = $request->input('formato');
        $_fechaIni = new DateTime($fechaIni);
        $_fechaFin = new DateTime($fechaFin);
        $idRestaurante = $request->input('idRestaurante');
        $nombre_restaurante = $request->input('nombre_restaurante');
        $sucursal = $request->input('sucursal');
        $caja = $request->input('caja');
        $chartBase64 = $request->input('chartBase64', null);
        $semanas = [];
        $nroSemana = 1;
        $fechaInicioSemana = null;
        $fechaFinSemana = null;
        for($i = clone $_fechaIni; $i <= $_fechaFin; $i->modify('+1 day')){
            $fecha = $i->format('Y-m-d');
            //Extrae la fecha de inicio y fin de la semana
            if($i == $_fechaIni || $i->format('l') == 'Monday'){
                $fechaInicioSemana = $fecha;
            }
            if($i == $_fechaFin || $i->format('l') == 'Sunday'){
                $fechaFinSemana = $fecha;
            }
            //Extrae el numero de semana
            if($i->format('l') == 'Sunday'){
                $totalesRangoFecha = $this->calculoTotales($idRestaurante, $fechaInicioSemana, $fechaFinSemana);
                if($totalesRangoFecha->total_pedidos > 0){
                    $semanas[] = [
                        'nroSemana' => 'Semana '.$nroSemana, 
                        'fechaDesde' => $fechaInicioSemana, 
                        'fechaHasta' => $fechaFinSemana,
                        'total_pedidos' => $totalesRangoFecha->total_pedidos,
                        'total_ventas' => $totalesRangoFecha->total_ventas,
                        'total_ganancia' => $totalesRangoFecha->total_ganancia
                    ];
                }
                $nroSemana++;
            }
            else if($i == $_fechaFin){
                $totalesRangoFecha = $this->calculoTotales($idRestaurante, $fechaInicioSemana, $fechaFinSemana);
                if($totalesRangoFecha->total_pedidos > 0){
                    $semanas[] = [
                        'nroSemana' => 'Semana '.$nroSemana, 
                        'fechaDesde' => $fechaInicioSemana, 
                        'fechaHasta' => $fechaFinSemana,
                        'total_pedidos' => $totalesRangoFecha->total_pedidos,
                        'total_ventas' => $totalesRangoFecha->total_ventas,
                        'total_ganancia' => $totalesRangoFecha->total_ganancia
                    ];
                }
            }
        }
        if($formato == 1){//formato html

            $numElementosPorPagina = 6;
            $paginaActual = request()->get('page', 1);
            $semanasPaginator = new LengthAwarePaginator(
                array_slice($semanas, ($paginaActual - 1) * $numElementosPorPagina, $numElementosPorPagina),
                count($semanas),
                $numElementosPorPagina,
                $paginaActual,
                ['path' => request()->url(), 'query' => request()->query()]
            );

            $response = Response::json([
                'semanasArray' => $semanasPaginator,
                'dataChart' => $semanas
            ], 200);
            return $response;
        }else if($formato == 2){//formato pdf
            $pdf = PDF::loadView('reportes.ventas_intervalo_fecha.semana_importe', [
                'nom_restaurante' => $nombre_restaurante,
                'titulo_reporte' => 'VENTAS POR SEMANA',
                'sucursal' => $sucursal,
                'caja' => $caja,
                'listItem' => $semanas,
                'fechaIni' => $fechaIni,
                'fechaFin' => $fechaFin,
                'chartBase64' => $chartBase64
            ]);
    
            return $pdf->download('semanaImportePDF_'.$fechaIni.'_'.$fechaFin.'.pdf');
        }else if($formato == 3){//formato excel
            $exportData = [];
            Log::info('Reporte Excel semanaImporte');
            foreach ($semanas as $row) {
                Log::info('row: ' , $row);
                $exportData[] = [
                    'Semana' => $row['nroSemana'],
                    'Desde' => $row['fechaDesde'],
                    'Hasta' => $row['fechaHasta'],
                    'Total Pedidos' => $row['total_pedidos'],
                    'Total Ventas' => $row['total_ventas'],
                    'Total Ganancia' => $row['total_ganancia'],
                ];
            }
    
            // Crear una clase exportadora anónima
            $export = new class($exportData) implements FromCollection, WithHeadings {
                private $data;
                public function __construct($data) { $this->data = $data; }
                public function collection() { return collect($this->data); }
                public function headings(): array {
                    return ['Semana', 'Desde', 'Hasta', 'Total Pedidos', 'Total Ventas', 'Total Ganancia'];
                }
            };
    
            return Excel::download($export, 'semanaImporteExcel_'.$fechaIni.'_'.$fechaFin.'.xlsx');
        }
    }
        /**
     * Recibe un numero entre 1 y 12 y devuelve la descripción del mes
     *
     * @param int $nroMes
     * @return string
     */
    private function getMesDescripcion(int $nroMes): string
    {
        $meses = [
            1 => 'Enero',
            2 => 'Febrero',
            3 => 'Marzo',
            4 => 'Abril',
            5 => 'Mayo',
            6 => 'Junio',
            7 => 'Julio',
            8 => 'Agosto',
            9 => 'Setiembre',
            10 => 'Octubre',
            11 => 'Noviembre',
            12 => 'Diciembre',
        ];
        return $meses[$nroMes];
    }
    public function mesImporte(Request $request){
        Log::info('mesImporte - request:', $request->all());
        

        $validated = $request->validate([
            'idRestaurante' => 'required|integer|exists:restaurants,id_restaurant',
            'year' => 'required|integer',
            'formato' => 'required|integer|in:1,2,3',
        ]);
        if ($validated === false) {
            return response()->json(['error' => ['validacion' => ['Error de validación de datos de entrada']]], 422);
        }
        $year = $request->input('year');
        $formato = $request->input('formato');
        $idRestaurante = $request->input('idRestaurante');
        $nombre_restaurante = $request->input('nombre_restaurante');
        $sucursal = $request->input('sucursal');
        $caja = $request->input('caja');
        $chartBase64 = $request->input('chartBase64', null);
        $fechaInicioMes = null;
        $fechaFinMes = null;
        $meses = [];
        for($i = 1; $i <= 12; $i++){
            $fechaInicioMes = date('Y-m-01', strtotime($year.'-'.$i.'-01'));
            $fechaFinMes = date('Y-m-t', strtotime($fechaInicioMes));
            Log::info('Mes '.$i.' del año '.$year.' desde: '.$fechaInicioMes.' hasta: '.$fechaFinMes);    
            $totalesRangoFecha = $this->calculoTotales($idRestaurante, $fechaInicioMes, $fechaFinMes);
            $meses[] = [
                'mes' => $this->getMesDescripcion($i), 
                'total_pedidos' => $totalesRangoFecha->total_pedidos,
                'total_ventas' => $totalesRangoFecha->total_ventas,
                'total_ganancia' => $totalesRangoFecha->total_ganancia
            ];
        }
        Log::info('Meses: ', $meses);

        if($formato == 1){//formato html
            $numElementosPorPagina = 6;
            $paginaActual = request()->get('page', 1);
            $mesesPaginator = new LengthAwarePaginator(
                array_slice($meses, ($paginaActual - 1) * $numElementosPorPagina, $numElementosPorPagina),
                count($meses),
                $numElementosPorPagina,
                $paginaActual,
                ['path' => request()->url(), 'query' => request()->query()]
            );

            $response = Response::json([
                'mesesArray' => $mesesPaginator,
                'dataChart' => $meses
            ], 200);
            return $response;
        }else if($formato == 2){//formato pdf
            $pdf = PDF::loadView('reportes.ventas_intervalo_fecha.mes_importe', [
                'nom_restaurante' => $nombre_restaurante,
                'titulo_reporte' => 'VENTAS POR AÑO',
                'sucursal' => $sucursal,
                'caja' => $caja,
                'listItem' => $meses,
                'year' => $year,
                'chartBase64' => $chartBase64
            ]);
    
            return $pdf->download('mesImportePDF_'.$year.'.pdf');
        }else if($formato == 3){//formato excel
            $exportData = [];
            Log::info('Reporte Excel mesImporte');
            foreach ($meses as $row) {
                $exportData[] = [
                    'Mes' => $row['mes'],
                    'Total Pedidos' => $row['total_pedidos'],
                    'Total Ventas' => $row['total_ventas'],
                    'Total Ganancia' => $row['total_ganancia'],
                ];
            }
    
            // Crear una clase exportadora anónima
            $export = new class($exportData) implements FromCollection, WithHeadings {
                private $data;
                public function __construct($data) { $this->data = $data; }
                public function collection() { return collect($this->data); }
                public function headings(): array {
                    return ['Mes', 'Total Pedidos', 'Total Ventas', 'Total Ganancia'];
                }
            };
    
            return Excel::download($export, 'mesImporteExcel_'.$year.'.xlsx');
        }
    }
}
