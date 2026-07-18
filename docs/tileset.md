# Kum + Çimen tileset'i

Kaynak: `resources/kum_cimen_tileset.tres`
Sahne: `scenes/levels/ground_layers.tscn` (iki katman: `Kum` altta, `Cimen` üstte)

Üç atlas, her biri 384×384 → 128×128'lik 3×3 = 9 kare:

| Kaynak | Dosya | Ne işe yarıyor |
|---|---|---|
| 0 | `Kum.png` | Zemin. 9 dolu kum varyantı. |
| 1 | `Grass.png` | Çimen yaması. Ortası dolu, kenarları dışa doğru soluyor. |
| 2 | `Grass_2.png` | Çimen çerçevesi (ortası boş halka). Elle yerleştirilir. |

## Arazi (terrain) kuralları

İki ayrı **terrain set** var; ayrı olmalarının sebebi ikisinin farklı
katmanlarda çalışması — aynı sette olsalardı Godot ikisi arasında geçiş
yapmaya çalışırdı.

| Set | Arazi | Mod | Kaynak |
|---|---|---|---|
| 0 | Çimen | Match Sides | `Grass.png` |
| 1 | Kum | Match Sides | `Kum.png` |

**Kum** — 9 karenin hepsine "her yanı kum" biti verildi. Godot eşleşen
kareler arasından rastgele seçtiği için, Kum arazisiyle boyayınca zemin
kendiliğinden çeşitleniyor; aynı desen tekrar etmiyor.

**Çimen** — klasik 3×3 yerleşim. Her kare, çimenin devam ettiği yönleri
işaretliyor:

```
(0,0) sağ+alt      (1,0) sol+sağ+alt      (2,0) sol+alt
(0,1) üst+sağ+alt  (1,1) dört yön (dolu)  (2,1) üst+sol+alt
(0,2) üst+sağ      (1,2) üst+sol+sağ      (2,2) üst+sol
```

## Nasıl map yapılır

1. Bölüm sahnesine `ground_layers.tscn`'i çocuk olarak ekle (ya da mevcut
   `Ground` düğümünün yanına iki `TileMapLayer` koyup tileset'i ata).
2. `Kum` katmanını seç → TileMap panelinde **Terrains** sekmesi → set 1,
   "Kum" → tüm haritayı boya. Alt zemin hazır.
3. `Cimen` katmanını seç → **Terrains** → set 0, "Çimen" → çimen istediğin
   yerleri boya. Kenarlar otomatik oturur.
4. Süs için `Grass_2` karelerini üst katmana elle serpiştir.

Katmanların `z_index`'i **0 kalmalı**. Çizim sırası ağaç sırasından geliyor:
`Kum` → `Cimen` → oyuncu/canavarlar. `Cimen`'e `z_index = 1` verilirse ağaç
sırasını ezer ve çimen oyuncunun, canavarların, toplanabilirlerin de üstüne
çıkar (bir kez bu hataya düşüldü).

## Bilinen sınır

Godot'nun "Match Sides" modu 16 komşuluk kombinasyonu tanır, elimizde ise
9 kare var. Yani her kombinasyonun birebir karşılığı yok — örneğin tek
başına duran bir çimen karesi ya da çapraz bağlantılar için tam eşleşme
bulunmuyor. Godot bu durumda en çok bite uyan kareyi seçiyor, sonuç
genellikle kabul edilebilir görünüyor ama kusursuz değil.

Kusursuz geçiş istenirse `Grass.png` 16 kareye (4×4) çıkarılmalı:
mevcut 9 kareye ek olarak tek başına duran kare, uç kareler (yalnızca bir
yönde devam eden) ve yatay/dikey koridor kareleri.

## Bölüm 1 haritası

`level_1.tscn` bu tileset'e taşındı: eski tek `Ground` katmanı yerine `Kum`
(alt) ve `Cimen` (üst, `z_index = 1`) var.

Harita elle değil, üretilerek dolduruldu:

- **Kum**: 114×72 = 8208 hücre, tüm oynanabilir alanı kaplıyor. Her hücreye
  9 kum varyantından rastgele biri konuldu ve üstüne rastgele bir döndürme
  uygulandı (8 yönün hepsi): 72 farklı görünüm.
- **Çimen**: 2567 hücre (%31 kaplama). Üst üste binen dairelerden organik
  yamalar üretildi, iki yumuşatma geçişiyle kenarları düzeltildi, sonra
  3×3 kuralına göre kenar kareleri atandı.

Çimenin **iç karesi** (1,1) tek bir çizim olduğu için üst üste geldiğinde
gözle görülür bir ızgara oluşturuyordu. İç karelerin %75'ine rastgele
yatay/dikey aynalama uygulandı; kenar karelerine dokunulmadı, çünkü onların
şekli komşuya göre anlamlı. Döndürme, hücrenin "alternatif" alanına Godot'nun
dönüşüm bayraklarıyla yazılıyor (`FLIP_H = 0x1000`, `FLIP_V = 0x2000`,
`TRANSPOSE = 0x4000`).

Çimen bilerek şu noktalardan uzak tutuldu: oyuncu başlangıcı, iki bulut
boşluğu, boss arenası ve çıkış kapısı — tehlike ve hedef alanları zemin
deseniyle karışmasın diye.

Haritayı yeniden üretmek gerekirse mantık basit: her hücre için 12 bayt
(`int16 x, y, kaynak, atlas_x, atlas_y, alternatif`), başa `uint16 0`
başlığı, tümü base64 olarak `tile_map_data` içine yazılıyor.


## Kum dokusunun dikişsizleştirilmesi

`Kum.png`'nin ilk hâlinde lekeler her karenin ortasında kümelenmişti: kenar
şeridinde %2, iç bölgede %29 doluluk. Kareler yan yana gelince o seyrek
şeritler birleşip açık renkli bir ızgara oluşturuyordu ve rastgele döndürme
bunu çözemiyordu, çünkü boşluk dört kenarda birden vardı.

Arka planın kendisi zaten düz krem olduğu için (kenar 207.7, iç 202.4
parlaklık) dokuyu yeniden çizmeye gerek kalmadı; yalnızca lekeleri yeniden
dağıtmak yetti. Kaynak karenin yoğun bölgesinden küçük pencereler alınıp
çıktı karesine rastgele, `mod 128` sararak yapıştırıldı:

- fırça izleri olduğu gibi korundu, bulanıklaştırma yok,
- yoğunluk her yerde eşit oldu, ızgara kayboldu,
- sarma sayesinde kare hem kendine hem komşusuna dikişsiz oturuyor.

Sonuç: kenar/iç farkı **+27.34 puandan −1.43'e** indi, yani sistematik fark
kalmadı. Orijinal dosya `Kum_orijinal.png` olarak duruyor.

## Çimen iç karesindeki puantiye ızgara

Kum düzeldikten sonra çimende ayrı bir ızgara kaldı: her karenin ortasında
belirgin bir öbek, yan yana gelince puantiye görüntüsü.

Ölçüm, sorunun dikişte olmadığını gösterdi: iç karenin kenarları zaten
komşularıyla uyuşuyordu (sol/sağ 108.8/108.8, üst/alt 122.3/122.5). Sorun
karenin **içindeki** geniş ölçekli gölgelenmeydi. Spektrum (kare başına dalga
sayısı → genlik):

| Bileşen | Genlik |
|---|---|
| çapraz (1,1) | **15.23** (dört köşe parlak, orta koyu) |
| dikey (0,2) | 9.87 |
| dikey (0,1) | 5.58 |
| yatay (1,0) | 5.28 |
| k ≥ 4 | 1.3 altı, ihmal edilebilir |

Kareler yan yana gelince bu gölgelenme birleşip ızgara noktalarını
oluşturuyordu.

Çözüm: kare ölçeğindeki bileşenler (|kx|,|ky| ≤ 3) doğrudan hesaplanıp
çıkarıldı. Yaprak dokusu çok daha yüksek frekansta olduğu için hiç
etkilenmedi. Bileşenler kare periyoduna tam oturduğu için sonuç kusursuz
sarmalı kalıyor.

Sonuçlar (32'lik blok ortalamalarının yayılımı):

- blok farkı **40.0 → 2.2**
- çapraz (1,1) genliği **15.23 → 0.00**
- ince detay **%108 korundu** (bulanıklaştırma yok)
- yalnızca (1,1) karesi değişti, alfa kanalı bozulmadı

Kutu bulanıklığı bu iş için yanlış araçtı: sarmalı bulanık, karenin kendi
periyodundaki dalgalanmayı tam yakalayamıyor (denendi, 39.9 → 22.9'da takıldı).

**Kalan takas:** düzleştirme iç karenin yönlü tonunu da sildi, oysa kenar
kareleri yönlü (üst/alt 121.1, sol/sağ 108.7). İç kare bunların ortalamasına
(114.9) hizalandı; iç kare ile kenar karesi arasındaki ton farkı üst/altta
1.7'den 9.0'a çıktı, sol/sağda 0.5'ten 2.9'a. Yamanın çevresinde çok hafif bir
ton basamağı kalıyor, ama tüm zemine yayılan ızgaranın gitmesi bu bedele
değiyor. Tamamen yok etmek isteyen kenar karelerini de tek tona çekmeli.

Orijinal dosya `Grass_orijinal.png` olarak duruyor.
