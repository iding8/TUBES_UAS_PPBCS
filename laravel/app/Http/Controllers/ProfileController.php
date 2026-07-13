<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class ProfileController extends Controller
{
    // PUT /api/profile
    public function update(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'name'  => 'required|string|max:255',
            'email' => ['required', 'email', Rule::unique('users', 'email')->ignore($user->id)],
        ]);

        $user->update([
            'name'  => $request->name,
            'email' => $request->email,
        ]);

        return response()->json([
            'message' => 'Profil berhasil diperbarui',
            'user'    => $user,
        ]);
    }

    // PUT /api/profile/password
    public function updatePassword(Request $request)
    {
        $user = $request->user();

        $request->validate([
            'current_password' => 'required',
            'password'         => 'required|string|min:6|confirmed',
        ]);

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'message' => 'Password saat ini salah',
            ], 422);
        }

        $user->update(['password' => Hash::make($request->password)]);

        return response()->json(['message' => 'Password berhasil diubah']);
    }
}
