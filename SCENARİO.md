# Senaryo Dokümantasyonu:(E-Ticaret RAG Bilgi Asistanı - Güvenlik ve Olay Takibi)

## 1. Problem Tanımı ve Bağlam
Bir e-ticaret platformunun müşteri destek sistemi, kullanıcılardan gelen iade, iptal ve garanti politikası sorularını bir **RAG (Retrieval-Augmented Generation) bilgi asistanı** vasıtasıyla yanıtlamaktadır. 

Ancak asistan zaman zaman sistemde bulunmayan veya geçerliliğini yitirmiş kuralları uydurmakta (halüsinasyon görmekte) ve şirket politikalarına aykırı (off-policy) yanıtlar üretmektedir. Güvenlik ve Uyum ekibi, bu hatalı/uydurma yanıtların hangi konularda yoğunlaştığını, hangi kanallardan geldiğini ve müşteri şikâyetleriyle olan doğrudan ilişkisini PostgreSQL veritabanı üzerinde izlemek ve analiz etmek istemektedir.

## 2. Hedef Kullanıcı Grubu
* **Güvenlik ve Uyum Denetçileri:** Politika ihlallerini ve uydurma yanıtları tespit eden uzmanlar.
* **Müşteri Hizmetleri Operasyon Ekibi:** Hatalı asistan yanıtları sonucu oluşan müşteri şikâyetlerini inceleyen yetkililer.
* **LLMOps / Sistem Geliştiricileri:** RAG mimarisinin veri çekme (retrieval) başarımını izleyen teknik ekip.

## 3. Tablo Adayları ve Sütun Yapıları
Sistemde izleme ve analiz için aşağıdaki 3 ana tablo yapısı kullanılacaktır:

* `questions` (Müşteri Soruları)
  - `id` (INTEGER, PK): Soru benzersiz kimliği.
  - `topic` (VARCHAR): Sorunun kategorisi (Örn: iade, kargo, ödeme, garanti).
  - `asked_at` (TIMESTAMP): Sorunun sorulduğu tarih ve saat.

* `responses` (RAG Asistan Yanıtları)
  - `id` (INTEGER, PK): Yanıt benzersiz kimliği.
  - `question_id` (INTEGER, FK): İlgili soru kimliği.
  - `source_found` (BOOLEAN): RAG sisteminin ilgili politika dokümanını/parçasını bulup bulamadığı (True/False).
  - `is_off_policy` (BOOLEAN): Yanıtın şirket politikası dışına çıkıp çıkmadığı / uydurma bilgi içerip içermediği (True/False).
  - `generated_at` (TIMESTAMP): Yanıtın üretildiği tarih ve saat.

* `complaints` (Müşteri Şikâyetleri)
  - `id` (INTEGER, PK): Şikâyet benzersiz kimliği.
  - `response_id` (INTEGER, FK): Şikâyete yol açan asistan yanıtı kimliği.
  - `complaint_type` (VARCHAR): Şikâyet türü (Örn: shipping, product, payment, bad_information).

## 4. Veri Kaynağı Adayları ve Lisanslar
- **Ana Metin/Soru-Cevap Verisi:** Hugging Face Datasets (Örn: `customer support`, `RAG QA`, `policy QA` etiketli açık lisanslı e-ticaret diyalog setleri).
- **Politika Referansı:** Açık e-ticaret yardım/iade sayfaları (kullanım koşulları veri kartında belirtilecektir).

## 5. Dönem Sonu YZ Bileşeni Notu
Dönem sonunda yanıtın kaynak dokümanlara dayanıp dayanmadığını doğrulamak için `source_found = False` olduğu halde yanıt üretilen veya `is_off_policy = True` olarak etiketlenen kayıtları ayrı bir denetim kuyruğuna (audit queue) aktaran bir SQL yapısı kurulacaktır.

> **Dikkat Edilmesi Gereken Kural:** `source_found` bayrağının `False` olması yanıtın kesinlikle yanlış olduğu anlamına gelmez. Ancak kaynak bulunamadığı halde iddialı bir yanıt verilmişse risk yüksektir.
