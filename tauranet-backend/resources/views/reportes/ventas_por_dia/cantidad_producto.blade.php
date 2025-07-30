<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Ventas</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size: 12px; }
        .header, .footer { text-align: center; margin-bottom: 20px; }
        .logo { width: 100px; margin-bottom: 10px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #ccc; padding: 6px; text-align: left; }
        th { background-color: #f2f2f2; }
        .totales { margin-top: 20px; }
        .totales p { margin: 4px 0; }
    </style>
</head>
<body>

    <div class="header">
        <img src="{{ $logo_url ?? '' }}" alt="Logo" class="logo">
        <h2 style="margin-bottom: 5px; color: #2c3e50; letter-spacing: 1px;">REPORTE DE VENTAS DIARIAS</h2>
        <h3 style="margin: 0; color: #34495e;">{{ $nom_restaurante }}</h3>
        <h4 style="margin: 0 0 10px 0; color: #7f8c8d;">{{ $sucursal }} - {{ $caja }}</h4>
        @if ($fechaIni == $fechaFin)
            <p style="font-size: 13px; color: #555;">Fecha: <strong>{{ $fechaIni }}</strong></p>
        @else
            <p style="font-size: 13px; color: #555;">Desde: <strong>{{ $fechaIni }}</strong> Hasta: <strong>{{ $fechaFin }}</strong></p>
        @endif
    </div>

    <table>
        <thead>
            <tr>
                <th>Producto</th>
                <th>Categoria</th>
                <th>Cantidad</th>
            </tr>
        </thead>
        <tbody>
            @foreach($productoCantidadPDF as $item)
                <tr>
                    <td>{{ $item->nom_producto }}</td>
                    <td>{{ $item->nom_categoria }}</td>
                    <td>{{ $item->cantidad }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>
    <!-- <div class="footer"> -->
        <!-- <p>Generado por: leslie</p> -->
    <!-- </div> -->
</body>
</html>
