<?php

namespace App\Http\Controllers;

use App\Models\Antrian;
use App\Models\Dokter;
use App\Models\JadwalPemeriksaan;
use App\Models\Pasien;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    // GET /api/dashboard
    public function index(Request $request)
    {
        $today = now()->format('d/m/Y');

        return response()->json([
            'message' => 'Berhasil mengambil statistik dashboard',
            'data' => [
                'total_pasien'      => Pasien::count(),
                'total_dokter'      => Dokter::count(),
                'antrian_menunggu'  => Antrian::where('status', 'menunggu')->count(),
                'antrian_dipanggil' => Antrian::where('status', 'dipanggil')->count(),
                'antrian_selesai_hari_ini' => Antrian::where('status', 'selesai')->where('tanggal', $today)->count(),
                'jadwal_hari_ini'   => JadwalPemeriksaan::where('tanggal', $today)->count(),
                'antrian_berikutnya' => Antrian::with(['pasien', 'dokter'])
                    ->where('status', 'menunggu')
                    ->orderBy('created_at')
                    ->first(),
            ],
        ]);
    }
}
