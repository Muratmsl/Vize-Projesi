# Proje 4 - Ödev 2: Kâğıt Rapor ve Karar Analizi

**Ad Soyad:** [Murat Şamil Muslu]
**Öğrenci Numarası:** [202607131003]
**Ders / Şube:** Vize Projesi (Proje 4) - Ödev 2

---

## 1. Yaratıcı Zekâ (AI) Beyanı
Bu ödevin geliştirilme sürecinde sorgu tasarımı, ERD kurgusu, normalizasyon adımları ve rapor taslağının oluşturulmasında **Gemini (LLM)** asistan olarak kullanılmıştır. Tüm teknik kararlar, veritabanı sorgu testleri ve analizler öğrenci tarafından gerçekleştirilmiştir.

---

## 2. Bölüm 1 Analizi: Fan-out (Mükerrer Sayım) Sorunu
* **Soru 4 Bağlamındaki Durum:** Filo/görev sorgularında `INNER JOIN` kullanıldığında, birden fazla görevi bulunan varlıklar (veya robotlar/sorular) her eşleşen kayıt için tekrar sayılır. Bu durum veride **Fan-out** (katlanarak çoğalma) hatasına yol açar.
* **Operasyonel Riskler:** Yapılan testlerde `SUM(battery_level)` veya metrik hesaplamalarında `INNER JOIN` kullanılması, toplam batarya/maliyet değerlerinin gerçek değerin çok üzerine çıkmasına (şişmesine) neden olmuştur. Örneğin, tekil bazda toplanması gereken operasyonel veriler mükerrer sayıldığı için yönetimsel raporlarda yanlış bütçe, yanlış kaynak planlaması ve hatalı KPI takipleri gibi ciddi operasyonel riskler doğurur. Doğru sonuç için alt sorgular (`IN (SELECT DISTINCT...)`) veya tekil gruplama stratejileri izlenmelidir.

---

## 3. Bölüm 2 Kararı: Proje 4 Veri Modeli Tasarımında En Zor Karar
* **Kararın Alındığı Nokta:** Proje 4'ın `responses` (Yanıtlar) ve `complaints` (Şikâyetler) tabloları arasındaki ilişkinin modellenmesi aşamasında karar verilmesi gereken en zor nokta, şikâyet verilerinin doğrudan `responses` tablosuna mı sütun olarak ekleneceği, yoksa tamamen ayrı bir `complaints` tablosunda mı tutulacağı konusu olmuştur.
* **İkilem ve Gerekçe:** Tüm veriyi tek tabloda toplamak başlangıçta sorguları yazmayı kolaylaştıracak gibi görünse de, projedeki 600 yanıttan yalnızca 135 tanesinin şikâyet aldığı gerçeği göz önünde bulundurulduğunda, tek tablo yapısı veritabanında çok fazla boş (`NULL`) alan oluşmasına ve veri tekrarına (anomaliye) yol açacaktı. Bu nedenle, 3. Normal Form (3NF) ilkelerine sadık kalınarak `complaints` tablosunun ayrı bir varlık olarak tasarlanması ve `response_id` (FK) ile bağlanması seçilmiştir. Bu karar, veritabanı boyutunu optimize etmiş ve şikâyet analizlerinde (`LEFT JOIN` ile) esneklik kazandırmıştır.
