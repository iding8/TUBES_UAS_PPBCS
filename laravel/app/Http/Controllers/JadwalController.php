<?php

namespace App\Http\Controllers;

use App\Models\JadwalPemeriksaan;
use Illuminate\Http\Request;

class JadwalController extends Controller
{
    // GET /api/jadwal
    public function index()
    {
        $jadwal = JadwalPemeriksaan::with(['pasien', 'dokter'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil data jadwal',
            'data'    => $jadwal,
        ]);
    }

    // POST /api/jadwal
    public function store(Request $request)
    {
        $request->validate([
            'pasien_id' => 'required|exists:pasien,id',
            'dokter_id' => 'required|exists:dokter,id',
            'tanggal'   => 'required|string',
            'waktu'     => 'required|string',
            'keluhan'   => 'required|string',
        ]);

        $jadwal = JadwalPemeriksaan::create($request->all());
        $jadwal->load(['pasien', 'dokter']);

        return response()->json([
            'message' => 'Jadwal berhasil ditambahkan',
            'data'    => $jadwal,
        ], 201);
    }

    // GET /api/jadwal/{id}
    public function show($id)
    {
        $jadwal = JadwalPemeriksaan::with(['pasien', 'dokter'])->find($id);
        if (!$jadwal) {
            return response()->json(['message' => 'Jadwal tidak ditemukan'], 404);
        }
        return response()->json([
            'message' => 'Berhasil',
            'data'    => $jadwal,
        ]);
    }

    // PUT /api/jadwal/{id}
    public function update(Request $request, $id)
    {
        $jadwal = JadwalPemeriksaan::find($id);
        if (!$jadwal) {
            return response()->json(['message' => 'Jadwal tidak ditemukan'], 404);
        }

        $jadwal->update($request->all());

        return response()->json([
            'message' => 'Jadwal berhasil diupdate',
            'data'    => $jadwal,
        ]);
    }

    // DELETE /api/jadwal/{id}
    public function destroy($id)
    {
        $jadwal = JadwalPemeriksaan::find($id);
        if (!$jadwal) {
            return response()->json(['message' => 'Jadwal tidak ditemukan'], 404);
        }

        $jadwal->delete();

        return response()->json(['message' => 'Jadwal berhasil dihapus']);
    }
}
