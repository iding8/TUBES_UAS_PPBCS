<?php

namespace App\Http\Controllers;

use App\Models\Dokter;
use Illuminate\Http\Request;

class DokterController extends Controller
{
    // GET /api/dokter
    public function index()
    {
        $dokter = Dokter::orderBy('nama')->get();
        return response()->json([
            'message' => 'Berhasil mengambil data dokter',
            'data'    => $dokter,
        ]);
    }

    // POST /api/dokter
    public function store(Request $request)
    {
        $request->validate([
            'nama'         => 'required|string|max:255',
            'spesialisasi' => 'required|string|max:255',
            'no_telepon'   => 'required|string|max:20',
        ]);

        $dokter = Dokter::create($request->all());

        return response()->json([
            'message' => 'Dokter berhasil ditambahkan',
            'data'    => $dokter,
        ], 201);
    }

    // GET /api/dokter/{id}
    public function show($id)
    {
        $dokter = Dokter::find($id);
        if (!$dokter) {
            return response()->json(['message' => 'Dokter tidak ditemukan'], 404);
        }
        return response()->json([
            'message' => 'Berhasil',
            'data'    => $dokter,
        ]);
    }

    // PUT /api/dokter/{id}
    public function update(Request $request, $id)
    {
        $dokter = Dokter::find($id);
        if (!$dokter) {
            return response()->json(['message' => 'Dokter tidak ditemukan'], 404);
        }

        $request->validate([
            'nama'         => 'sometimes|required|string|max:255',
            'spesialisasi' => 'sometimes|required|string|max:255',
            'no_telepon'   => 'sometimes|required|string|max:20',
        ]);

        $dokter->update($request->all());

        return response()->json([
            'message' => 'Dokter berhasil diupdate',
            'data'    => $dokter,
        ]);
    }

    // DELETE /api/dokter/{id}
    public function destroy($id)
    {
        $dokter = Dokter::find($id);
        if (!$dokter) {
            return response()->json(['message' => 'Dokter tidak ditemukan'], 404);
        }

        $dokter->delete();

        return response()->json([
            'message' => 'Dokter berhasil dihapus',
        ]);
    }
}
