erDiagram
    QUESTIONS ||--|| RESPONSES : "üretir"
    RESPONSES ||--o| COMPLAINTS : "yol_acar"

    QUESTIONS {
        int id PK
        varchar topic
        timestamp asked_at
    }

    RESPONSES {
        int id PK
        int question_id FK
        boolean source_found
        boolean is_off_policy
        timestamp generated_at
    }

    COMPLAINTS {
        int id PK
        int response_id FK
        varchar complaint_type
    }

    İlişki Açıklamaları:

->Bir question, tam bir response'a sahiptir; bir response, tam bir question'a aittir.

->Bir response, sıfır veya bir complaint'e sahiptir; bir complaint, tam bir response'a aittir.

Tablo Adı	Neden Ayrıldı / Ayrılmadı? (Fonksiyonel Bağımlılık)	Hangi Normal Form?	Somut Örnek (Proje 40 Verilerinden)
questions	Sorunun içeriği (topic) ve sorulma zamanı (asked_at) doğrudan soru kimliğine (id) bağlıdır. Yanıt detaylarıyla (örn. is_off_policy) aynı tabloda tutulursa her yanıt üretildiğinde soru bilgileri tekrar edeceği için ayrı bir tabloda modellenmiştir.	1NF (Birinci Normal Form)	Tüm sütunlar atomik (bölünemez) değerler içerir; örneğin topic alanında virgülle ayrılmış çoklu kategoriler yerine tekil bir değer (payment veya return) tutulur.
responses	Bir soruya karşılık gelen yanıtın durumu (source_found, is_off_policy, generated_at) yalnızca yanıtın kendi id'sine bağlıdır. Soru metni/konusu tekrarlanmaz, yalnızca question_id (FK) ile bağlanır.	2NF (İkinci Normal Form)	Kısmi bağımlılık (partial dependency) yoktur; tablonun birincil anahtarı tekil bir sütundur (id) ve tüm sütunlar bu anahtara tam olarak bağımlıdır.
complaints	Şikâyetler her yanıtta oluşmaz (örneğin 600 yanıttan yalnızca 135 tanesi şikâyet almıştır). Eğer şikâyet bilgileri responses tablosunda tutulsaydı, şikâyet almayan satırlarda gereksiz boş (NULL) alanlar oluşacaktı. Bu nedenle ayrı bir tabloda tutulmuştur.	3NF (Üçüncü Normal Form)	Geçişli bağımlılıklar (transitive dependency) arındırılmıştır; complaints tablosundaki complaint_type bilgisi doğrudan şikâyet id'sine bağlıdır, başka bir tablo üzerinden dolaylı olarak bağımlı değildir.