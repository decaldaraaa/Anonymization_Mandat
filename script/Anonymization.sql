CREATE FUNCTION fn_Masking_NISN (@NISN VARCHAR(20))
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @MaskedNISN VARCHAR(20);
    
    IF LEN(@NISN) > 3
        SET @MaskedNISN = REPLICATE('*', LEN(@NISN) - 3) + RIGHT(@NISN, 3);
    ELSE
        SET @MaskedNISN = @NISN;
        
    RETURN @MaskedNISN;
END;
GO

CREATE PROCEDURE sp_GetDataSiswa_Aman
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        dbo.fn_Masking_NISN(NISN) AS NISN_Aman,
        
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

EXEC sp_GetDataSiswa_Aman;

SELECT * FROM Data_Siswa