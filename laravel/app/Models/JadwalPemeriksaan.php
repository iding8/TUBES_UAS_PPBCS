<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class JadwalPemeriksaan extends Model
{
    protected $table = 'jadwal_pemeriksaan';

    protected $fillable = [
        'pasien_id',
        'dokter_id',
        'tanggal',
        'waktu',
        'keluhan',
    ];

    public function pasien()
    {
        return $this->belongsTo(Pasien::class, 'pasien_id');
    }

    public function dokter()
    {
        return $this->belongsTo(Dokter::class, 'dokter_id');
    }
}
