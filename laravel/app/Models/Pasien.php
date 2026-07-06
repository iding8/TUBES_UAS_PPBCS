<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pasien extends Model
{
    protected $table = 'pasien';

    protected $fillable = [
        'nama',
        'tanggal_lahir',
        'jenis_kelamin',
        'alamat',
        'no_telepon',
    ];

    public function jadwal()
    {
        return $this->hasMany(JadwalPemeriksaan::class, 'pasien_id');
    }

    public function antrian()
    {
        return $this->hasMany(Antrian::class, 'pasien_id');
    }

    public function rekamMedis()
    {
        return $this->hasMany(RekamMedis::class, 'pasien_id');
    }
}
