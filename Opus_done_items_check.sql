-- Digitised items completed on Opus (Done_items_CPC-59_CPC-185.xlsx):
-- are their digital items linked, and do they carry the right royalty rates?
--
-- HL ID in the spreadsheet is the print item. WILLIS = 'Y' for the rows
-- highlighted blue. Willis digital items should carry WILLISUK at 50% of
-- gross receipts (PAYRTF 'G', PAYRAT 0.50000); every other line follows print.

-- 1. One row per print item / digital item, with a STATUS to act on.
WITH DONE (PRINT_ITEM, WILLIS, JIRA) AS (
VALUES
       (48187081, 'N', 'CPC-68'),
       (48183715, 'N', 'CPC-70'),
       (48185242, 'N', 'CPC-71'),
       (16541361, 'N', 'CPC-74'),
       (16449882, 'N', 'CPC-75'),
       (48181165, 'N', 'CPC-76'),
       (14041655, 'N', 'CPC-77'),
       (14042180, 'N', 'CPC-78'),
       (16353851, 'N', 'CPC-85'),
       (16673086, 'N', 'CPC-88'),
       (50586318, 'N', 'CPC-89'),
       (50560932, 'N', 'CPC-90'),
       (50486275, 'N', 'CPC-92'),
       (16673060, 'N', 'CPC-96'),
       (14014885, 'N', 'CPC-101'),
       (50015170, 'N', 'CPC-105'),
       (50565775, 'N', 'CPC-106'),
       (50601623, 'N', 'CPC-113'),
       (50586321, 'N', 'CPC-117'),
       (50485467, 'N', 'CPC-119'),
       (5013560, 'N', 'CPC-120'),
       (50486285, 'N', 'CPC-121'),
       (50561288, 'N', 'CPC-122'),
       (48183169, 'N', 'CPC-123'),
       (50485759, 'N', 'CPC-125'),
       (14029207, 'N', 'CPC-127'),
       (50560227, 'N', 'CPC-128'),
       (14025513, 'N', 'CPC-135'),
       (50012480, 'N', 'CPC-144'),
       (14064308, 'N', 'CPC-146'),
       (50564795, 'N', 'CPC-148'),
       (14078537, 'N', 'CPC-152'),
       (50499301, 'N', 'CPC-154'),
       (48181077, 'N', 'CPC-163'),
       (50491443, 'N', 'CPC-164'),
       (50020310, 'N', 'CPC-166'),
       (50486270, 'N', 'CPC-167'),
       (50486425, 'N', 'CPC-168'),
       (50483859, 'N', 'CPC-169'),
       (14008963, 'N', 'CPC-175'),
       (50586372, 'N', 'CPC-176'),
       (50491240, 'N', 'CPC-177'),
       (50013920, 'N', 'CPC-178'),
       (50486689, 'N', 'CPC-179'),
       (50586129, 'N', 'CPC-180'),
       (14076767, 'Y', 'CPC-181'),
       (14076768, 'Y', 'CPC-182'),
       (14076819, 'Y', 'CPC-183'),
       (288507, 'Y', 'CPC-186'),
       (288508, 'Y', 'CPC-187'),
       (288509, 'Y', 'CPC-188'),
       (288510, 'Y', 'CPC-189'),
       (1787264, 'Y', 'CPC-190'),
       (910974, 'Y', 'CPC-192'),
       (1872231, 'Y', 'CPC-193'),
       (406230, 'Y', 'CPC-194'),
       (14076834, 'Y', 'CPC-198'),
       (14076762, 'Y', 'CPC-199'),
       (14076747, 'Y', 'CPC-200'),
       (412076, 'Y', 'CPC-205'),
       (14076748, 'Y', 'CPC-206'),
       (14076763, 'Y', 'CPC-207'),
       (14076764, 'Y', 'CPC-208'),
       (14076777, 'Y', 'CPC-210'),
       (14076791, 'Y', 'CPC-215'),
       (14076797, 'Y', 'CPC-216'),
       (50601267, 'N', 'n/a'),
       (14078636, 'N', 'n/a'),
       (50098100, 'N', 'n/a'),
       (50098070, 'N', 'n/a'),
       (50480825, 'N', 'n/a'),
       (50480356, 'N', 'n/a')
),
LINKS (KIND, PRINT_ITEM, DIGITAL_ITEM) AS (
    SELECT 'EBOOK', ORGITMNUM, ITMNUM FROM OBJECT.IVPEPUBITM
    UNION ALL
    SELECT 'DOWNLOAD', ITMNUM, RELITMNUM FROM OBJECT.IVPRELITM WHERE RELTYPEID = 1
),
X AS (
    SELECT D.JIRA, D.WILLIS, D.PRINT_ITEM, L.KIND, L.DIGITAL_ITEM,
           COUNT(P.ITMNUM) AS ALL_LINES,
           SUM(CASE WHEN P.STMTID = 'WILLISUK' THEN 1 ELSE 0 END) AS WILLISUK_LINES,
           SUM(CASE WHEN P.STMTID = 'WILLISUK' AND P.PAYRTF = 'G'
                     AND P.PAYRAT = 0.50000 THEN 1 ELSE 0 END) AS WILLISUK_50G
      FROM DONE D
      LEFT JOIN LINKS L ON L.PRINT_ITEM = D.PRINT_ITEM
      LEFT JOIN OBJECT.IVLPROD2 P ON P.ITMNUM = L.DIGITAL_ITEM
     GROUP BY D.JIRA, D.WILLIS, D.PRINT_ITEM, L.KIND, L.DIGITAL_ITEM
)
SELECT JIRA, WILLIS, PRINT_ITEM, KIND, DIGITAL_ITEM,
       ALL_LINES, WILLISUK_LINES, WILLISUK_50G,
       CASE WHEN DIGITAL_ITEM IS NULL         THEN 'NO DIGITAL ITEM LINKED'
            WHEN ALL_LINES = 0                THEN 'NO ROYALTY LINES'
            WHEN WILLISUK_LINES <> WILLISUK_50G THEN 'WILLISUK NOT 50% G'
            WHEN WILLIS = 'Y' AND WILLISUK_LINES = 0 THEN 'WILLIS - NO WILLISUK LINE'
            ELSE 'OK' END AS STATUS
  FROM X
 ORDER BY CASE WHEN DIGITAL_ITEM IS NULL OR ALL_LINES = 0
                 OR WILLISUK_LINES <> WILLISUK_50G
                 OR (WILLIS = 'Y' AND WILLISUK_LINES = 0) THEN 0 ELSE 1 END,
          WILLIS DESC, JIRA, KIND;

-- 2. Non-Willis items: who their digital items pay and at what rate, so
--    Royalties can say which payees need a digital rate in RLPDGTRAT.
WITH DONE (PRINT_ITEM, WILLIS, JIRA) AS (
VALUES
       (48187081, 'N', 'CPC-68'),
       (48183715, 'N', 'CPC-70'),
       (48185242, 'N', 'CPC-71'),
       (16541361, 'N', 'CPC-74'),
       (16449882, 'N', 'CPC-75'),
       (48181165, 'N', 'CPC-76'),
       (14041655, 'N', 'CPC-77'),
       (14042180, 'N', 'CPC-78'),
       (16353851, 'N', 'CPC-85'),
       (16673086, 'N', 'CPC-88'),
       (50586318, 'N', 'CPC-89'),
       (50560932, 'N', 'CPC-90'),
       (50486275, 'N', 'CPC-92'),
       (16673060, 'N', 'CPC-96'),
       (14014885, 'N', 'CPC-101'),
       (50015170, 'N', 'CPC-105'),
       (50565775, 'N', 'CPC-106'),
       (50601623, 'N', 'CPC-113'),
       (50586321, 'N', 'CPC-117'),
       (50485467, 'N', 'CPC-119'),
       (5013560, 'N', 'CPC-120'),
       (50486285, 'N', 'CPC-121'),
       (50561288, 'N', 'CPC-122'),
       (48183169, 'N', 'CPC-123'),
       (50485759, 'N', 'CPC-125'),
       (14029207, 'N', 'CPC-127'),
       (50560227, 'N', 'CPC-128'),
       (14025513, 'N', 'CPC-135'),
       (50012480, 'N', 'CPC-144'),
       (14064308, 'N', 'CPC-146'),
       (50564795, 'N', 'CPC-148'),
       (14078537, 'N', 'CPC-152'),
       (50499301, 'N', 'CPC-154'),
       (48181077, 'N', 'CPC-163'),
       (50491443, 'N', 'CPC-164'),
       (50020310, 'N', 'CPC-166'),
       (50486270, 'N', 'CPC-167'),
       (50486425, 'N', 'CPC-168'),
       (50483859, 'N', 'CPC-169'),
       (14008963, 'N', 'CPC-175'),
       (50586372, 'N', 'CPC-176'),
       (50491240, 'N', 'CPC-177'),
       (50013920, 'N', 'CPC-178'),
       (50486689, 'N', 'CPC-179'),
       (50586129, 'N', 'CPC-180'),
       (14076767, 'Y', 'CPC-181'),
       (14076768, 'Y', 'CPC-182'),
       (14076819, 'Y', 'CPC-183'),
       (288507, 'Y', 'CPC-186'),
       (288508, 'Y', 'CPC-187'),
       (288509, 'Y', 'CPC-188'),
       (288510, 'Y', 'CPC-189'),
       (1787264, 'Y', 'CPC-190'),
       (910974, 'Y', 'CPC-192'),
       (1872231, 'Y', 'CPC-193'),
       (406230, 'Y', 'CPC-194'),
       (14076834, 'Y', 'CPC-198'),
       (14076762, 'Y', 'CPC-199'),
       (14076747, 'Y', 'CPC-200'),
       (412076, 'Y', 'CPC-205'),
       (14076748, 'Y', 'CPC-206'),
       (14076763, 'Y', 'CPC-207'),
       (14076764, 'Y', 'CPC-208'),
       (14076777, 'Y', 'CPC-210'),
       (14076791, 'Y', 'CPC-215'),
       (14076797, 'Y', 'CPC-216'),
       (50601267, 'N', 'n/a'),
       (14078636, 'N', 'n/a'),
       (50098100, 'N', 'n/a'),
       (50098070, 'N', 'n/a'),
       (50480825, 'N', 'n/a'),
       (50480356, 'N', 'n/a')
),
LINKS (PRINT_ITEM, DIGITAL_ITEM) AS (
    SELECT ORGITMNUM, ITMNUM FROM OBJECT.IVPEPUBITM
    UNION
    SELECT ITMNUM, RELITMNUM FROM OBJECT.IVPRELITM WHERE RELTYPEID = 1
)
SELECT P.STMTID, P.PLCODE, P.PAYRTF, P.DSPCRT,
       COUNT(DISTINCT D.PRINT_ITEM) AS TITLES,
       COUNT(*) AS LINES
  FROM DONE D
  JOIN LINKS L ON L.PRINT_ITEM = D.PRINT_ITEM
  JOIN OBJECT.IVLPROD2 P ON P.ITMNUM = L.DIGITAL_ITEM
 WHERE D.WILLIS = 'N'
 GROUP BY P.STMTID, P.PLCODE, P.PAYRTF, P.DSPCRT
 ORDER BY P.STMTID, P.PLCODE;
