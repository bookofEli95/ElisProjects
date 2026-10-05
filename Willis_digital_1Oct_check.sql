-- Willis digital items: which ones did the 1 October monthly refresh touch?
--
-- RLREBKUPD rebuilds every eBook linked in IVPEPUBITM from its print item
-- (unless on the exempt list) and writes one RLPAUTOSTP row per item it
-- refreshes, dated the day of the run. Any linked Willis digital item that
-- shows REFRESHED_1_OCT = 'YES' now carries the print item's royalty set-up
-- and needs its digital rate re-entering.
--
-- The item list is the HL ID column from Oct_Nov_2026_Willis_titles.xlsx.
-- It is matched against both the print and the digital side of the link.
-- Run with the normal royalty library list (or qualify the three files).
-- NOTE: this covers eBooks only. Digital downloads go through RLRDIGUPD,
-- which may use a different link file.

WITH WILLIS (ITMNUM) AS (
VALUES
       (910975), (14076746), (14076748), (14076763), (14076764), (14076765), (14076777), (14076787),
       (338685), (300737), (14076789), (14076791), (14076797), (14076812), (14076815), (14076816),
       (14076820), (14076825), (14076842), (14076844), (14076773), (14076774), (14076784), (363409),
       (367028), (910976), (1105851), (1326280), (1740401), (1740402), (14076766), (14076769),
       (14076770), (14076771), (14076780), (338686), (14076795), (14076798), (14076800), (14076818),
       (14076821), (14076826), (14076831), (14076832), (14076833), (14076839), (14076846), (14076749),
       (14076796), (14076813), (288507), (288508), (288509), (288510), (1787264), (1782622),
       (910974), (1872231), (406230), (14076834), (14076762), (14076747), (14076767), (14076768),
       (14076819)
)
SELECT E.ORGITMNUM AS PRINT_ITEM,
       E.ITMNUM    AS DIGITAL_ITEM,
       I.SDESC     AS DIGITAL_TITLE,
       CASE WHEN A.ITMNUM IS NULL THEN 'NO' ELSE 'YES' END AS REFRESHED_1_OCT
  FROM IVPEPUBITM E
  JOIN WILLIS W
    ON W.ITMNUM IN (E.ORGITMNUM, E.ITMNUM)
  LEFT JOIN IVPITEMS I
    ON I.ITMNUM = E.ITMNUM
  LEFT JOIN (SELECT DISTINCT ITMNUM
               FROM RLPAUTOSTP
              WHERE DTEADDED = '2026-10-01') A
    ON A.ITMNUM = E.ITMNUM
 ORDER BY E.ORGITMNUM, E.ITMNUM;
