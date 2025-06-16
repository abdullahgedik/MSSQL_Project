-- authors tablosundaki eksik ve hatalı verilerin tespiti ve düzeltilmesi.
-- Eksik Değerlerin Tespiti:
-- Telefon veya adres bilgisi olmayan yazarlar
SELECT * FROM authors
WHERE phone IS NULL OR address IS NULL;
-- Hatalı Formatların Tespiti:
-- Hatalı telefon formatı: XXX XXX-XXXX olmalı (örneğin 415 555-1212)
SELECT * FROM authors
WHERE phone NOT LIKE '[0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]';

-- Hatalı Verilerin Güncellenmesi:
-- Eksik telefon numaralarına varsayılan değer atanması
UPDATE authors
SET phone = '000 000-0000'
WHERE phone IS NULL;

-- Veri Dönüştürme (Data Transformation)
-- Örnek Senaryo: titles tablosundaki fiyatların döviz kuru dönüşümü ile normalize edilmesi.
-- USD → TRY dönüşümü (örneğin kur: 32.5)
SELECT title_id, title, price, price * 32.5 AS price_in_try
FROM titles
WHERE price IS NOT NULL;

-- Yeni sütunla güncelleme:
ALTER TABLE titles ADD price_try MONEY;

UPDATE titles
SET price_try = price * 32.5
WHERE price IS NOT NULL;

-- Veri Yükleme (Data Loading)
-- Örnek Senaryo: Temizlenen verilerin authors_cleaned adlı hedef tabloya aktarılması.
-- Temiz tabloyu oluştur:
SELECT * INTO authors_cleaned FROM authors WHERE 1 = 0;

-- Temizlenmiş veriyi yükle:
INSERT INTO authors_cleaned
SELECT * FROM authors
WHERE phone IS NOT NULL AND address IS NOT NULL;

-- Temizleme sonrası veri kalitesine dair temel rapor
-- Eksik veri oranı:
SELECT 
  COUNT(*) AS total_records,
  SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS missing_phone,
  SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) AS missing_address
FROM authors;
-- Uyumlu format oranı:
SELECT 
  COUNT(*) AS total_authors,
  SUM(CASE 
    WHEN phone LIKE '[0-9][0-9][0-9] [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]' 
    THEN 1 ELSE 0 END) AS valid_phone_count
FROM authors;
