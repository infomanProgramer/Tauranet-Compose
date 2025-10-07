<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

// Route::get('/{any}', function () {
//     return file_get_contents(public_path('dist/index.html'));
// })->where('any', '^(?!api).*$');

Route::get('/{any}', function () {
    return file_get_contents(public_path('index.html'));
})->where('any', '^(?!api|js|css|img|assets|favicon\.ico).*$');

// Route::get('/', function () {
//     return view('welcome');
// });

//Route::get('reporte/{id}', 'PdfController@reportePDF');



//Route::resource('superadm', 'SuperadministradorController');
//Route::resource('guardarsuperadm', 'SuperadministradorController@store');