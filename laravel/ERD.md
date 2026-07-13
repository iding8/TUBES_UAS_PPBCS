# ERD Project TUBES-UAS

Berikut ERD sistem klinik dalam format Mermaid.

```mermaid
flowchart TB
    subgraph Master["Entitas Utama"]
        U["Users"]
        P["Pasien"]
        D["Dokter"]
    end

    subgraph Transaksi["Transaksi Klinik"]
        JP["Jadwal Pemeriksaan"]
        AN["Antrian"]
        RM["Rekam Medis"]
    end

    U -->|login / role| P
    U -->|login / role| D

    P -->|memiliki| JP
    D -->|ditugaskan| JP

    P -->|mendaftar| AN
    D -->|menangani| AN

    P -->|memiliki| RM
    D -->|membuat| RM

    classDef entity fill:#f8fafc,stroke:#2563eb,stroke-width:1.2px,color:#111827;
    class U,P,D,JP,AN,RM entity;
```

## Keterangan singkat
- Pasien dapat memiliki banyak jadwal pemeriksaan, antrian, dan rekam medis.
- Dokter dapat memiliki banyak jadwal pemeriksaan, antrian, dan rekam medis.
- Tabel users digunakan untuk autentikasi dan role pengguna.
