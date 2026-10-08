-- Checks after running RLCEBKUPD with the new RLREBKADPR (WILLISUK 50 G).

-- 2. Item 1827066 (Willis eBook): expect
--    WILLIS   0.05000 %  '  5.000%'   (unchanged, from print)
--    WILLISUK 0.50000 G  ' 50.000%'   (digital rate)
SELECT STMTID, PLCODE, TERR, PAYRAT, PAYRTF, DSPCRT
  FROM OBJECT.IVLPROD2
 WHERE ITMNUM = 1827066
 ORDER BY STMTID;

-- 3. Every other licence line on every digital item must still match its
--    print item exactly. Expect NO rows. (WILLISUK lines are excluded because
--    they are meant to differ; the seven exempt eBooks are excluded because
--    the refresh skips them.)
WITH LINKS (KIND, PRINT_ITEM, DIGITAL_ITEM) AS (
    SELECT 'EBOOK', ORGITMNUM, ITMNUM FROM OBJECT.IVPEPUBITM
    UNION ALL
    SELECT 'DOWNLOAD', ITMNUM, RELITMNUM FROM OBJECT.IVPRELITM WHERE RELTYPEID = 1
)
SELECT L.KIND, L.PRINT_ITEM, L.DIGITAL_ITEM,
       D.STMTID, D.PLCODE, D.TERR,
       P.DSPCRT AS PRINT_RATE,   P.PAYRTF AS PRINT_BASIS,
       D.DSPCRT AS DIGITAL_RATE, D.PAYRTF AS DIGITAL_BASIS
  FROM LINKS L
  JOIN OBJECT.IVLPROD2 D
    ON D.ITMNUM = L.DIGITAL_ITEM
   AND D.STMTID <> 'WILLISUK'
  LEFT JOIN OBJECT.IVLPROD2 P
    ON P.ITMNUM = L.PRINT_ITEM
   AND P.STMTID = D.STMTID AND P.PLCODE = D.PLCODE
   AND P.COMP#  = D.COMP#  AND P.TERSEQ = D.TERSEQ AND P.TERR = D.TERR
 WHERE L.DIGITAL_ITEM NOT IN (314900, 318122, 108014, 318362,
                              319036, 333284, 318385)
   AND (P.ITMNUM IS NULL
        OR P.PAYRAT <> D.PAYRAT
        OR P.PAYRTF <> D.PAYRTF
        OR P.DSPCRT <> D.DSPCRT)
 ORDER BY L.PRINT_ITEM, L.DIGITAL_ITEM, D.STMTID;

-- 4. Accrual rate: the digital item next to its print item (1782622).
--    If the two match, the accrual was not recalculated for 50 G.
SELECT ITMNUM, SDESC, PRICE72, ROYACRRAT1, ROYACRRAT2
  FROM OBJECT.IVPITEMS
 WHERE ITMNUM IN (1827066, 1782622)
 ORDER BY ITMNUM;
