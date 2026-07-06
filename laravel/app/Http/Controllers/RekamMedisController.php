<?php

namespace App\Http\Controllers;

use App\Models\RekamMedis;
use Illuminate\Http\Request;

class RekamMedisController extends Controller
{
    // GET /api/rekam-medis
    public function index()
    {
        $rekamMedis = RekamMedis::with(['pasien', 'dokter'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil data rekam medis',
            'data'    => $rekamMedis,
        ]);
    }

    // POST /api/rekam-medis
    public function store(Request $request)
    {
        $request->validate([
            'pasien_id' => 'required|exists:pasien,id',
            'dokter_id' => 'required|exists:dokter,id',
            'tanggal'   => 'required|string',
            'diagnosis' => 'required|string',
            'resep'     => 'required|string',
            'catatan'   => 'nullable|string',
        ]);

        $rekamMedis = RekamMedis::create($request->all());
        $rekamMedis->load(['pasien', 'dokter']);

        return response()->json([
            'message' => 'Rekam medis berhasil ditambahkan',
            'data'    => $rekamMedis,
        ], 201);
    }

    // GET /api/rekam-medis/{id}
    public function show($id)
    {
        $rekamMedis = RekamMedis::with(['pasien', 'dokter'])->find($id);
        if (!$rekamMedis) {
            return response()->json(['message' => 'Rekam medis tidak ditemukan'], 404);
        }
        return response()->json([
            'message' => 'Berhasil',
            'data'    => $rekamMedis,
        ]);
    }

    // PUT /api/rekam-medis/{id}
    public function update(Request $request, $id)
    {
        $rekamMedis = RekamMedis::find($id);
        if (!$rekamMedis) {
            return response()->json(['message' => 'Rekam medis tidak ditemukan'], 404);
        }

        $rekamMedis->update($request->all());

        return response()->json([
            'message' => 'Rekam medis berhasil diupdate',
            'data'    => $rekamMedis,
        ]);
    }

    // DELETE /api/rekam-medis/{id}
    public function destroy($id)
    {
        $rekamMedis = RekamMedis::find($id);
        if (!$rekamMedis) {
            return response()->json(['message' => 'Rekam medis tidak ditemukan'], 404);
        }

        $rekamMedis->delete();

        return response()->json(['message' => 'Rekam medis berhasil dihapus']);
    }
}
