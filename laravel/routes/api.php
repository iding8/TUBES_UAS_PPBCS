<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PasienController;
use App\Http\Controllers\DokterController;
use App\Http\Controllers\JadwalController;
use App\Http\Controllers\AntrianController;
use App\Http\Controllers\RekamMedisController;

// ─── Public routes (tidak perlu token) ───
Route::post('/login',    [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// ─── Protected routes (perlu token Sanctum) ───
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Dashboard
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Profile
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::put('/profile/password', [ProfileController::class, 'updatePassword']);

    // Pasien
    Route::apiResource('pasien', PasienController::class);

    // Dokter
    Route::apiResource('dokter', DokterController::class);

    // Jadwal Pemeriksaan
    Route::apiResource('jadwal', JadwalController::class);

    // Antrian
    Route::apiResource('antrian', AntrianController::class);
    Route::put('/antrian/{id}/status', [AntrianController::class, 'updateStatus']);

    // Rekam Medis
    Route::apiResource('rekam-medis', RekamMedisController::class);
});
