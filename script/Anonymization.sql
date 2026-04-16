-- 1. Pindah ke database Mandat
USE Mandat;
GO

-- 2. Buat LOGIN baru di level server (Ganti nama jika ingin yang lain)
CREATE LOGIN user_mandat 
WITH PASSWORD = 'MAVIAXX22', 
     DEFAULT_DATABASE = Mandat;
GO

-- 3. Buat USER di dalam database Mandat untuk login tersebut
CREATE USER user_mandat FOR LOGIN user_mandat;
GO

-- 4. Berikan akses sebagai owner agar bebas melakukan ETL di Pentaho
ALTER ROLE db_owner ADD MEMBER user_mandat;
GO

ALTER TABLE Data_Siswa 
ALTER COLUMN Nama_Lengkap VARCHAR(50);

CREATE FUNCTION fn_Masking_NISN (@NISN VARCHAR(20))
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @MaskedNISN VARCHAR(20);
    
    -- Jika panjang NISN lebih dari 3, mask sisanya dengan '*'
    IF LEN(@NISN) > 3
        SET @MaskedNISN = REPLICATE('*', LEN(@NISN) - 3) + RIGHT(@NISN, 3);
    ELSE
        SET @MaskedNISN = @NISN; -- Jaga-jaga jika data kosong/terlalu pendek
        
    RETURN @MaskedNISN;
END;
GO

CREATE FUNCTION fn_Masking_Nama (@Nama VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN
    DECLARE @MaskedNama VARCHAR(100);
    
    -- Menampilkan huruf pertama saja, sisanya diubah jadi '*'
    IF LEN(@Nama) > 1
        SET @MaskedNama = LEFT(@Nama, 1) + REPLICATE('*', LEN(@Nama) - 1);
    ELSE
        SET @MaskedNama = @Nama;
        
    RETURN @MaskedNama;
END;
GO

CREATE PROCEDURE sp_GetDataSiswa_Aman
AS
BEGIN
    -- Mencegah pesan jumlah baris (opsional, untuk performa)
    SET NOCOUNT ON;

    SELECT 
        -- Menggunakan fungsi masking untuk data sensitif
        dbo.fn_Masking_NISN(NISN) AS NISN_Aman,
        
        -- Kolom yang sudah di-noise (dari tahap sebelumnya) atau aman
		Nama_Lengkap,
        Penghasilan_Keluarga_Bulan,
        Jarak_Ke_Sekolah_KM,
        Jenis_Kelamin,
        Kelas,
        Jurusan,
        Kelayakan_Bansos
    FROM 
        Data_Siswa;
END;
GO

DROP FUNCTION fn_masking_nama

DROP PROCEDURE sp_GetDataSiswa_Aman
DROP FUNCTION fn_masking_nama

EXEC sp_GetDataSiswa_Aman;