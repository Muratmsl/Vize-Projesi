# Veri Kartı (Data Card) 

## 1. Veri Kaynağı ve Lisans
* **Kaynak:** Hugging Face Datasets (`bitext/Bitext-customer-support-llm-chatbot-training-dataset`)
* **İndirme Tarihi:** Kasım 2026
* **Lisans:** Open Source

## 2. Hacim ve Sütun Yapısı
* `data/raw/questions_raw.csv`: 600 satır (id, topic, asked_at)
* `data/raw/responses_raw.csv`: 600 satır (id, question_id, source_found, is_off_policy, generated_at)
* `data/raw/complaints_raw.csv`: ~130 satır (id, response_id, complaint_type)

## 3. Beklenen Veri Sorunları ve Temizleme Adımları (PostgreSQL Aktarımı)
* **Çelişkili Kayıtlar:** `responses` tablosunda `source_found = False` olduğu halde `is_off_policy` değeri `False` bırakılmış tutarsızlıklar mevcuttur.
* **Yetim Kayıtlar (Orphan Records):** `complaints` tablosunda `response_id = 9999` gibi `responses` tablosunda karşılığı olmayan veri hatası mevcuttur.
* **Veri Tamamlama Beyanı:** Ham verinin %80'i Hugging Face üzerindeki gerçek diyalog metinlerinden çekilmiş, kalan tarih ve bayrak alanları senaryo gereksinimine uygun olarak simüle edilmiştir.
