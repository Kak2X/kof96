
Sound_ChRegAddrTable: (4693)<corrupted stop>
  1F:4695                  ld   [de], a
  1F:4696                  inc  de
  1F:4697                  inc  d
  1F:4698                  ld   d, $17
  1F:469A                  jr   $46B5
  1F:469C                  ld   a, [de]
  1F:469D                  dec  de
  1F:469E                  inc  e
  1F:469F                  dec  e
  1F:46A0                  ld   e, $20
  1F:46A2                  ld   hl, $2322
Sound_SndHeaderPtrTable: (46A5)rst  $18
  1F:46A6                  ld   a, e
  1F:46A7                  rst  $18
  1F:46A8                  ld   a, e
  1F:46A9                  or   b
  1F:46AA                  ld   a, d
  1F:46AB                  call $2465
  1F:46AE                  ld   d, a
  1F:46AF                  rst  $18
  1F:46B0                  ld   a, b
