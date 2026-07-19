FONTLAR
=======

GodOfThunder.ttf
  Kaynak : https://www.fontspace.com/god-of-thunder-font-f43822
  Lisans : Freeware, Non-Commercial (ticari kullanim YOK)

NorthEternal.otf
  Kaynak : https://www.fontspace.com/north-eternal-font-f161966
  Lisans : Freeware, Non-Commercial (ticari kullanim YOK)

BerkshireSwash-Regular.ttf
  Kaynak : Google Fonts
  Lisans : SIL Open Font License 1.1 (bkz. BerkshireSwash-OFL.txt)
           Ticari kullanim SERBEST.

!! DIKKAT: GodOfThunder ve NorthEternal yalnizca ticari olmayan kullanim icin
   serbest. Oyun bir gun satilacak ya da parayla dagitilacaksa bu iki fontun
   degistirilmesi veya ticari lisanslarinin alinmasi gerekir.
   BerkshireSwash bu kisitlamaya tabi degil.


TURKCE KARAKTER DURUMU
======================

Iki fontun da cmap tablosunda Turkce'ye ozgu harflerin cogu yok; Godot bunlari
taban harf + birlesen aksan olarak sentezliyor. Sonuc iki fontta ayni degil:

GodOfThunder  ->  GUVENLI. c g i o s u ve buyuk halleri dogru ve fontun
                  stiliyle tutarli ciziliyor. Her yerde kullanilabilir.

NorthEternal  ->  GUVENLI DEGIL. Su harfler bozuk ciziyor:
                    S/s  : sedil kopuk bir virgul gibi duruyor ("CIKIS,")
                    I    : noktasi yana kayiyor
                    G/g  : fontun stiline uymayan bir isaret aliyor
                  Bu yuzden yalnizca bu harflerin gecmedigi metinde
                  kullanilmali. Su an sadece ana menudeki "ASTARIOS"
                  logosunda kullaniliyor; o metin tamamen ASCII oldugu icin
                  guvenli.

BerkshireSwash ->  GUVENLI. Turkce'ye ozgu harflerin hepsi (cCgGiIoOsSuU ve
                  aksanli a/i/u) fontun kendi cmap tablosunda gercek glif
                  olarak var; sentezleme yapilmiyor.
                  Diyalog repliklerinde kullaniliyor.

NorthEternal'i baska bir yere uygularken metinde s/S, i/I, g/G var mi diye
mutlaka bakin.
