<?php

namespace App\Http\Controllers;

use App\Models\Antrian;
use Illuminate\Http\Request;

class AntrianController extends Controller
{
    // GET /api/antrian
    public function index()
    {
        $antrian = Antrian::with(['pasien', 'dokter'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'message' => 'Berhasil mengambil data antrian',
            'data'    => $antrian,
        ]);
    }

    // POST /api/antrian
    public function store(Request $request)
    {
        $request->validate([
            'pasien_id' => 'required|exists:pasien,id',
            'dokter_id' => 'required|exists:dokter,id',
        ]);

        // Generate nomor antrian otomatis
        $today = now()->format('d/m/Y');
        $count = Antrian::whereDate('created_at', today())->count();
        $nomorAntrian = 'A' . str_pad($count + 1, 3, '0', STR_PAD_LEFT);

        $antrian = Antrian::create([
            'nomor_antrian' => $nomorAntrian,
            'pasien_id'     => $request->pasien_id,
            'dokter_id'     => $request->dokter_id,
            'tanggal'       => $today,
            'status'        => 'menunggu',
            'waktu_daftar'  => now()->format('H:i'),
        ]);

        $antrian->load(['pasien', 'dokter']);

        return response()->json([
            'message' => 'Antrian berhasil diambil',
            'data'    => $antrian,
        ], 201);
    }

    // GET /api/antrian/{id}
    public function show($id)
    {
        $antrian = Antrian::with(['pasien', 'dokter'])->find($id);
        if (!$antrian) {
            return response()->json(['message' => 'Antrian tidak ditemukan'], 404);
        }
        return response()->json([
            'message' => 'Berhasil',
            'data'    => $antrian,
        ]);
    }

    // PUT /api/antrian/{id}
    public function update(Request $request, $id)
    {
        $antrian = Antrian::find($id);
        if (!$antrian) {
            return response()->json(['message' => 'Antrian tidak ditemukan'], 404);
        }

        $antrian->update($request->all());

        return response()->json([
            'message' => 'Antrian berhasil diupdate',
            'data'    => $antrian,
        ]);
    }

    // PUT /api/antrian/{id}/status
    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:menunggu,dipanggil,selesai',
        ]);

        $antrian = Antrian::find($id);
        if (!$antrian) {
            return response()->json(['message' => 'Antrian tidak ditemukan'], 404);
        }

        $antrian->update(['status' => $request->status]);
        $antrian->load(['pasien', 'dokter']);

        return response()->json([
            'message' => 'Status antrian berhasil diupdate',
            'data'    => $antrian,
        ]);
    }

    // DELETE /api/antrian/{id}
    public function destroy($id)
    {
        $antrian = Antrian::find($id);
        if (!$antrian) {
            return response()->json(['message' => 'Antrian tidak ditemukan'], 404);
        }

        $antrian->delete();

        return response()->json(['message' => 'Antrian berhasil dihapus']);
    }
}
