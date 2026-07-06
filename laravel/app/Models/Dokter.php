<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Dokter extends Model
{
    protected $table = 'dokter';

    protected $fillable = [
        'nama',
        'spesialisasi',
        'no_telepon',
    ];

    public function jadwal()
    {
        return $this->hasMany(JadwalPemeriksaan::class, 'dokter_id');
    }

    public function antrian()
    {
        return $this->hasMany(Antrian::class, 'dokter_id');
    }

    public function rekamMedis()
    {
        return $this->hasMany(RekamMedis::class, 'dokter_id');
    }
}
