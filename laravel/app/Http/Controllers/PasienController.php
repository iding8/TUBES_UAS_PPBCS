<?php

namespace App\Http\Controllers;

use App\Models\Pasien;
use Illuminate\Http\Request;

class PasienController extends Controller
{
    // GET /api/pasien
    public function index()
    {
        $pasien = Pasien::orderBy('created_at', 'desc')->get();
        return response()->json([
            'message' => 'Berhasil mengambil data pasien',
            'data'    => $pasien,
        ]);
    }

    // POST /api/pasien
    public function store(Request $request)
    {
        $request->validate([
            'nama'          => 'required|string|max:255',
            'tanggal_lahir' => 'required|string',
            'jenis_kelamin' => 'required|in:Laki-laki,Perempuan',
            'alamat'        => 'required|string',
            'no_telepon'    => 'required|string|max:20',
        ]);

        $pasien = Pasien::create($request->all());

        return response()->json([
            'message' => 'Pasien berhasil ditambahkan',
            'data'    => $pasien,
        ], 201);
    }

    // GET /api/pasien/{id}
    public function show($id)
    {
        $pasien = Pasien::find($id);
        if (!$pasien) {
            return response()->json(['message' => 'Pasien tidak ditemukan'], 404);
        }
        return response()->json([
            'message' => 'Berhasil',
            'data'    => $pasien,
        ]);
    }

    // PUT /api/pasien/{id}
    public function update(Request $request, $id)
    {
        $pasien = Pasien::find($id);
        if (!$pasien) {
            return response()->json(['message' => 'Pasien tidak ditemukan'], 404);
        }

        $request->validate([
            'nama'          => 'sometimes|required|string|max:255',
            'tanggal_lahir' => 'sometimes|required|string',
            'jenis_kelamin' => 'sometimes|required|in:Laki-laki,Perempuan',
            'alamat'        => 'sometimes|required|string',
            'no_telepon'    => 'sometimes|required|string|max:20',
        ]);

        $pasien->update($request->all());

        return response()->json([
            'message' => 'Pasien berhasil diupdate',
            'data'    => $pasien,
        ]);
    }

    // DELETE /api/pasien/{id}
    public function destroy($id)
    {
        $pasien = Pasien::find($id);
        if (!$pasien) {
            return response()->json(['message' => 'Pasien tidak ditemukan'], 404);
        }

        $pasien->delete();

        return response()->json([
            'message' => 'Pasien berhasil dihapus',
        ]);
    }
}
