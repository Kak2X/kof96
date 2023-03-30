# kof96

Disassembly of The King of Fighters '96 for the Game Boy, also known as:
* 熱闘 ザ・キング・オブ・ファイターズ ’９６
* Nettou King of Fighters '96
* The King of Fighters: Heat of Battle

## Building
This will build bit-perfect ROMs of the Japanese and English versions of KOF96.

To assemble, run one of the included batch scripts:
- **build-jp.cmd** for the Japanese version. To verify this, provide a ROM named "*Nettou The King of Fighters '96 (Japan) (SGB Enhanced).gb*" as "*original_jp.gb*". `sha1: 63F25BFF422A591907B83AB9F14709E938172839`
- **build-en.cmd** for the English version. To verify this, provide a ROM named "*King of Fighters, The - Heat of Battle (Europe) (SGB Enhanced).gb*" as "*original_en.gb*". `sha1: 1B5AC034B1333B3340FBDC5C128BC12ABD310043`
- **build-nojunk.cmd** for a version of the game without padding areas. Currently, it builds a Japanese-language version running on the English version's engine.

## 
Once again, thanks to lazigamer for the debug emulator used to generate the initial CDL.
## 
*it all began in 96...*