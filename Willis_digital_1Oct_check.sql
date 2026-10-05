-- Willis digital items: which ones did the 1 October monthly refresh touch,
-- and what royalty rate do they carry now?
--
-- The monthly job (RLCEBKUPDM) rebuilds every linked digital item from its
-- print item:
--   eBooks    - RLREBKUPD, link file IVPEPUBITM (ORGITMNUM = print, ITMNUM = digital)
--   Downloads - RLRDIGUPD, link file IVPRELITM  (ITMNUM = print, RELITMNUM = digital,
--               RELTYPEID = 1)
-- Both write one RLPAUTOSTP row per digital item they refresh, dated the day
-- of the run. A Willis digital item showing REFRESHED_1_OCT = 'YES' now
-- carries the print item's royalty set-up.
--
-- The item list is the HL ID column from Oct_Nov_2026_Willis_titles.xlsx and
-- is matched against both the print and the digital side of each link.
-- Run with the normal library list.

-- 1. Linked Willis digital items and whether the 1 October run refreshed them
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
),
LINKS (KIND, PRINT_ITEM, DIGITAL_ITEM) AS (
    SELECT 'EBOOK', ORGITMNUM, ITMNUM FROM IVPEPUBITM
    UNION ALL
    SELECT 'DOWNLOAD', ITMNUM, RELITMNUM FROM IVPRELITM WHERE RELTYPEID = 1
)
SELECT L.KIND,
       L.PRINT_ITEM,
       L.DIGITAL_ITEM,
       I.SDESC AS DIGITAL_TITLE,
       CASE WHEN A.ITMNUM IS NULL THEN 'NO' ELSE 'YES' END AS REFRESHED_1_OCT
  FROM LINKS L
  JOIN WILLIS W
    ON W.ITMNUM IN (L.PRINT_ITEM, L.DIGITAL_ITEM)
  LEFT JOIN IVPITEMS I
    ON I.ITMNUM = L.DIGITAL_ITEM
  LEFT JOIN (SELECT DISTINCT ITMNUM
               FROM RLPAUTOSTP
              WHERE DTEADDED = '2026-10-01') A
    ON A.ITMNUM = L.DIGITAL_ITEM
 ORDER BY L.KIND, L.PRINT_ITEM, L.DIGITAL_ITEM;


-- 2. Willis product licence lines now on those digital items (WL_ROY), side by
--    side with the print item's lines they were copied from. After the 1 October
--    run the rates should match; any line where Royalties agreed a different
--    digital rate needs correcting (after the item is exempt, see below).
--    WL_ROY.RLPPROD is assumed to be the physical file behind IVLPROD2WL.
WITH LINKS (KIND, PRINT_ITEM, DIGITAL_ITEM) AS (
    SELECT 'EBOOK', ORGITMNUM, ITMNUM FROM IVPEPUBITM
    UNION ALL
    SELECT 'DOWNLOAD', ITMNUM, RELITMNUM FROM IVPRELITM WHERE RELTYPEID = 1
)
SELECT L.KIND, L.PRINT_ITEM, L.DIGITAL_ITEM,
       D.STMTID, D.CNTRID, D.PLCODE, D.TERR,
       P.DSPCRT AS PRINT_RATE_SHOWN,   P.PAYRAT AS PRINT_PAYRAT,
       D.DSPCRT AS DIGITAL_RATE_SHOWN, D.PAYRAT AS DIGITAL_PAYRAT
  FROM LINKS L
  JOIN WL_ROY.RLPPROD D
    ON D.ITMNUM = L.DIGITAL_ITEM
  LEFT JOIN WL_ROY.RLPPROD P
    ON P.ITMNUM = L.PRINT_ITEM
   AND P.STMTID = D.STMTID AND P.PLCODE = D.PLCODE
   AND P.COMP#  = D.COMP#  AND P.TERSEQ = D.TERSEQ AND P.TERR = D.TERR
 ORDER BY L.PRINT_ITEM, L.DIGITAL_ITEM, D.STMTID, D.PLCODE;


-- 3. Sanity check on RLRDIGDLT: it deletes royalty records for every row in
--    IVPRELITM, but RLRDIGUPD only rebuilds RELTYPEID = 1. Any other
--    relationship type listed here loses its royalty set-up every month.
SELECT RELTYPEID, COUNT(*) AS LINKS
  FROM IVPRELITM
 GROUP BY RELTYPEID
 ORDER BY RELTYPEID;
