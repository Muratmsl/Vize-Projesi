-- =====================================================================
-- Ödev 2: JOIN, ERD ve Normalizasyon - Bölüm 1: Filo Soruları
-- Veritabanı: robot_fleet
-- =====================================================================

-- 1. Her robotun adı, operatör adı ve operatörün telefonu (INNER JOIN)
SELECT r.name AS robot_name, o.operator_name, o.phone
FROM robots r
INNER JOIN operators o ON r.operator_name = o.operator_name;
-- Yorum: Bu sorgu operatörü olan robotları eşleştirerek 9 satır döndürmüştür.

-- 2. Aynı liste, ama bütün robotlar görünsün (LEFT JOIN)
SELECT r.name AS robot_name, o.operator_name, o.phone
FROM robots r
LEFT JOIN operators o ON r.operator_name = o.operator_name;
-- Yorum: Bu sorgu 10 satır döndürmüştür; 1. sorgudan farklı olarak operatörü olmayan 'Mars-03' robotu da listelenmiş, operatör bilgileri NULL gelmiştir.

-- 3. Hiç görev almamış robotların adı ve modeli
SELECT r.name, r.model
FROM robots r
LEFT JOIN missions m ON r.id = m.robot_id
WHERE m.id IS NULL;
-- Yorum: Bu sorgu hiç görevi bulunmayan 4 robotun (Kartal-03 hariç diğerleri/ilgili robotlar) adını ve modelini 4 satır olarak döndürmüştür.

-- 4. Görevi olan robotların toplam batarya seviyesi (Fan-out ve JOIN'siz karşılaştırma)
-- YÖNTEM A: INNER JOIN ile (Fan-out / Mükerrer sayım hatası içeren)
SELECT SUM(r.battery_level) AS toplam_batarya_join
FROM robots r
INNER JOIN missions m ON r.id = m.robot_id;

-- YÖNTEM B: JOIN kullanmadan doğru hesaplama
SELECT SUM(battery_level) AS toplam_batarya_dogru
FROM robots
WHERE id IN (
  SELECT DISTINCT robot_id FROM missions
);
-- Yorum: JOIN kullanılan ilk sorguda robotlar birden fazla görevi olduğu için tekrar sayılmış (fan-out) ve toplam batarya şişmiştir, ikinci sorgu ise her robotu tekil alarak doğru sonucu vermiştir.

-- 5. Robot başına görev sayısı, hiç görevi olmayanlar 0 görünsün (COUNT(*) ve COUNT(m.id))
SELECT r.name, COUNT(*) AS satir_sayisi, COUNT(m.id) AS gorev_sayisi
FROM robots r
LEFT JOIN missions m ON r.id = m.robot_id
GROUP BY r.id, r.name;
-- Yorum: Bu sorgu 10 satır döndürmüştür; hiç görevi olmayan robotlarda COUNT(*) LEFT JOIN yüzünden 1 satırı sayarken, COUNT(m.id) NULL değerleri saymadığı için 0 vermiştir.
```[cite: 60]
