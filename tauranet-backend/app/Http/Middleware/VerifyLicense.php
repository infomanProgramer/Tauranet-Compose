<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Helpers\LicenseHelper;

class VerifyLicense
{
    public function handle(Request $request, Closure $next)
    {
        // Permitir acceder a la página de error sin verificar licencia para evitar bucles
        if ($request->is('license-error')) {
            return $next($request);
        }

        $license = LicenseHelper::verifyLicense();

        if (!$license['valid']) {
            return redirect()->route('license.error', ['m' => $license['message']]);
        }

        return $next($request);
    }
}
