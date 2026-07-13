<?php

namespace App\Http\Controllers;

use App\Models\Dokter;
use Illuminate\Http\Request;

class DokterController extends Controller
{
    // GET /api/dokter?search=&spesialisasi=&per_page=
    public function index(Request $request)
    {
        $query = Dokter::query()->orderBy('nama');

        if ($search = $request->query('search')) {
            $query->where('nama', 'like', "%{$search}%");
        }

        if ($spesialisasi = $request->query('spesialisasi')) {
            $query->where('spesialisasi', $spesialisasi);
        }

        $perPage = (int) $request->query('per_page', 50);
        $dokter = $query->paginate($perPage);

        return response()->json([
            'message'       => 'Berhasil mengambil data dokter',
            'data'          => $dokter->items(),
            'current_page'  => $dokter->currentPage(),
            'last_page'     => $dokter->lastPage(),
            'total'         => $dokter->total(),
            'spesialisasi_list' => Dokter::select('spesialisasi')->distinct()->orderBy('spesialisasi')->pluck('spesialisasi'),
        ]);
    }

    // POST /api/dokter
    public function store(Request $request)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['message' => 'Hanya admin yang bisa menambah dokter'], 403);
        }

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
        if (!$request->user()->isAdmin()) {
            return response()->json(['message' => 'Hanya admin yang bisa mengubah data dokter'], 403);
        }

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
    public function destroy(Request $request, $id)
    {
        if (!$request->user()->isAdmin()) {
            return response()->json(['message' => 'Hanya admin yang bisa menghapus dokter'], 403);
        }

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
