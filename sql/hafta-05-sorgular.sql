-- ============================================================
-- Veritabanı Yönetim Sistemleri - Vize Projesi (Hafta 5)
-- Perakende ve E-Ticaret - RAG Bilgi Asistanı x Güvenlik ve Olay Takibi
-- ============================================================

-- SIKLIK/ORAN ANALİZİ (GROUP BY, ROUND)
-- Soru 1: Konu başlıklarına göre toplam yanıt sayısı ve politika dışı (is_off_policy = true) 
-- yanıtların yüzde oranı nedir?
-- Bu sorgu, RAG asistanının en çok hangi e-ticaret konusunda uydurma/hata yapma riski taşıdığını gösterir.
SELECT 
    q.topic,
    COUNT(r.id) AS total_responses,
    COUNT(CASE WHEN r.is_off_policy = TRUE THEN 1 END) AS off_policy_count,
    ROUND(COUNT(CASE WHEN r.is_off_policy = TRUE THEN 1 END) * 100.0 / COUNT(r.id), 2) AS off_policy_percentage
FROM questions q
JOIN responses r ON q.id = r.question_id
GROUP BY q.topic
ORDER BY off_policy_percentage DESC;


-- VERİ KALİTESİ VE TUTARLILIK KONTROLÜ (COUNT FARK)
-- Soru 2: RAG sistemi ilgili kaynak dokümanı bulamadığı halde (source_found = false) 
-- politika dışı olarak işaretlenmemiş (is_off_policy = false) tutarsız yanıtların sayısı nedir?
-- Bu sorgu, kaynak dokümanı olmadan verilen iddialı yanıtların güvenlik ekibi tarafından gözden kaçırılma riskini ölçer.
SELECT 
    COUNT(*) AS no_source_not_off_policy_count
FROM responses
WHERE source_found = FALSE AND is_off_policy = FALSE;


-- YÜKSEK RİSKLİ KONU FİLTRELEME (HAVING)
-- Soru 3: Politika dışı yanıt oranı %20'nin üzerinde olan konular hangileridir?
-- Bu sorgu, güvenlik ve denetim ekibinin acil müdahale etmesi gereken yüksek riskli kategori alanlarını filtreler.
SELECT 
    q.topic,
    ROUND(COUNT(CASE WHEN r.is_off_policy = TRUE THEN 1 END) * 100.0 / COUNT(r.id), 2) AS off_policy_percentage
FROM questions q
JOIN responses r ON q.id = r.question_id
GROUP BY q.topic
HAVING (COUNT(CASE WHEN r.is_off_policy = TRUE THEN 1 END) * 100.0 / COUNT(r.id)) > 20.0;


-- ŞİKÂYET TÜRLERİNİ KATEGORİZE ETME (CASE WHEN)
-- Soru 4: Müşteri şikâyetleri 'Operational Risk' ve 'Information Security Risk' 
-- olarak gruplandığında dağılım nasıl şekillenmektedir?
-- Bu sorgu, gelen şikâyetlerin operasyonel mi yoksa asistan kaynaklı bilgi hatası mı olduğunu sınıflandırır.
SELECT 
    CASE 
        WHEN complaint_type IN ('shipping_delay', 'product_damaged') THEN 'Operational Risk'
        WHEN complaint_type IN ('bad_information', 'wrong_billing') THEN 'Information Security Risk'
        ELSE 'Other'
    END AS risk_group,
    COUNT(*) AS complaint_count
FROM complaints
GROUP BY 
    CASE 
        WHEN complaint_type IN ('shipping_delay', 'product_damaged') THEN 'Operational Risk'
        WHEN complaint_type IN ('bad_information', 'wrong_billing') THEN 'Information Security Risk'
        ELSE 'Other'
    END;


-- ZAMAN SERİSİ TREND ANALİZİ (date_trunc)
-- Soru 5: Haftalık bazda üretilen politika dışı yanıt sayısı ile müşteri şikâyetlerinin zamansal trendi nasıl değişmektedir?
-- Bu sorgu, haftalık hatalı yanıt artışlarının doğrudan müşteri şikâyetlerine yansıyıp yansımadığını korelasyon olarak inceler.
SELECT 
    date_trunc('week', r.generated_at) AS week,
    COUNT(DISTINCT r.id) AS total_responses,
    COUNT(DISTINCT CASE WHEN r.is_off_policy = TRUE THEN r.id END) AS off_policy_responses,
    COUNT(DISTINCT c.id) AS total_complaints
FROM responses r
LEFT JOIN complaints c ON r.id = c.response_id
GROUP BY date_trunc('week', r.generated_at)
ORDER BY week ASC;
