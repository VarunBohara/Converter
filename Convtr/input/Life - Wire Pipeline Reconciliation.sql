SELECT DISTINCT
        RDC.CHANNEL_CD, RDC.SUB_CHANNEL_CD, ew.external_wholesaler_name AS "external", SUBSTRING(internal_notes, 0, CHARINDEX('//', internal_notes)) AS "is", ppe.policy_number AS "policy #",
        /* RDP.Insured_Name AS [Insured], */
        NVL(insured_last_name, '') || ', ' || NVL(insured_first_name, '') AS insured,
        CASE
            WHEN ppe.lob_key_cd = 'TERM' THEN ppe.prod_premium
            WHEN NVL(ppe.target_premium, 0) = 0 AND NVL(ppe.prod_premium, 0) = 0 THEN (CASE
                WHEN (SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), 0, CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))::VARCHAR(4000)) = 1 THEN CAST (SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), 0, CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))) AS NUMERIC(19, 4))
                ELSE 0
            END)
            WHEN NVL(ppe.target_premium, 0) = 0 AND NVL(ppe.prod_premium, 0) <> 0 THEN NVL(ppe.prod_premium, 0)
            ELSE NVL(ppe.target_premium, 0)
        END AS target,
        CASE
            WHEN psc.status_cd_desc LIKE 'REISSUE%' THEN 'REISSUE'
            WHEN psc.status_cd_desc LIKE 'REWRITE%' THEN 'REWRITE'
            ELSE psc.status_cd_desc
        END AS status, rdp.face_amt AS "face amt", rdp.underwriter_name AS uw, ppe.csr_id AS "nba id", CONVERT (VARCHAR(300), NULL) AS "nba name", (NVL(ppe.tobacco_desc_abbrev, NVL(ipt.tobacco_desc_abbrev, '')) || '-' || (CASE
            WHEN ppe.rating2_value_desc IS NULL THEN (NVL(CASE
                WHEN ppe.rating3_type_desc LIKE '%FLAT%' THEN '-' || 'FE:' || NULL || '/' || NULL || 'yrs'
                ELSE ''
            END, ''))
            WHEN ppe.rating2_value_desc = '$1.50 / UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$1.50/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$10.00/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$12.50/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$15.00/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$2.00/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$2.50/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$3.00/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$3.50/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$5.00/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '$650.00' THEN ''
            WHEN ppe.rating2_value_desc = '$7.50/ UNIT' THEN ''
            WHEN ppe.rating2_value_desc = '0' THEN ''
            WHEN ppe.rating2_value_desc = '1' THEN ''
            WHEN ppe.rating2_value_desc = '10' THEN ''
            WHEN ppe.rating2_value_desc = '11' THEN ''
            WHEN ppe.rating2_value_desc = '12' THEN ''
            WHEN ppe.rating2_value_desc = '2' THEN ''
            WHEN ppe.rating2_value_desc = '3' THEN ''
            WHEN ppe.rating2_value_desc = '3 Times Ins. Age' THEN ''
            WHEN ppe.rating2_value_desc = '4' THEN ''
            WHEN ppe.rating2_value_desc = '5' THEN ''
            WHEN ppe.rating2_value_desc = '6' THEN ''
            WHEN ppe.rating2_value_desc = '7' THEN ''
            WHEN ppe.rating2_value_desc = '8' THEN ''
            WHEN ppe.rating2_value_desc = '9' THEN ''
            WHEN ppe.rating2_value_desc = 'A T-1-A (+25%)' THEN 'Table A'
            WHEN ppe.rating2_value_desc = 'B T-2-B (+50%)' THEN 'Table B'
            WHEN ppe.rating2_value_desc = 'C T-3-C (+75%)' THEN 'Table C'
            WHEN ppe.rating2_value_desc = 'D T-4-D (+100%)' THEN 'Table D'
            WHEN ppe.rating2_value_desc = 'E T-5-E (+125%)' THEN 'Table E'
            WHEN ppe.rating2_value_desc = 'F T-6-F (+150%)' THEN 'Table F'
            WHEN ppe.rating2_value_desc = 'G T-7-G (+175%)' THEN 'Table G'
            WHEN ppe.rating2_value_desc = 'H T-8-H (+200%)' THEN 'Table H'
            WHEN ppe.rating2_value_desc = 'I T-9-I (+225%)' THEN 'Table I'
            WHEN ppe.rating2_value_desc = 'J T-10-J (+250%)' THEN 'Table J'
            WHEN ppe.rating2_value_desc = 'K T-11-K (+275%)' THEN 'Table K'
            WHEN ppe.rating2_value_desc = 'L T-12-L (+300%)' THEN 'Table L'
            WHEN ppe.rating2_value_desc = 'M T-13-M (+325%)' THEN 'Table M'
            WHEN ppe.rating2_value_desc = 'N T-14-N (+350%)' THEN 'Table N'
            WHEN ppe.rating2_value_desc = 'O T-15-O (+375%)' THEN 'Table O'
            WHEN ppe.rating2_value_desc = 'P T-16-P (+400%)' THEN 'Table P'
            WHEN ppe.rating2_value_desc = 'Q T-17-Q (+425%)' THEN 'Table Q'
            WHEN ppe.rating2_value_desc = 'R T-18-R (+450%)' THEN 'Table R'
            WHEN ppe.rating2_value_desc = 'S T-19-S (+475%)' THEN 'Table S'
            WHEN ppe.rating2_value_desc = 'T T-20-T (+500%)' THEN 'Table T'
            WHEN ppe.rating2_value_desc = 'U T-U-3(+988%)' THEN 'Table U'
            WHEN ppe.rating2_value_desc = 'User Defined' THEN ''
            WHEN ppe.rating2_value_desc = 'V T-U(+999%)' THEN 'Table V'
            WHEN ppe.rating2_value_desc = 'W T-U-0(+999%)' THEN 'Table W'
            WHEN ppe.rating2_value_desc = 'X User Defined' THEN ''
            WHEN ppe.rating2_value_desc = 'x1.5' THEN ''
            WHEN ppe.rating2_value_desc = 'x2.0' THEN ''
            WHEN ppe.rating2_value_desc = 'x2.5' THEN ''
            WHEN ppe.rating2_value_desc = 'x3.0' THEN ''
            ELSE ''
        END)) AS "uw decision", ppe.state AS state, f.advisor_key_id, da.advisor_ssn,
        CASE
            WHEN da.full_name LIKE '%Merrill Lynch%' OR da.full_name LIKE '%Small Business Ins%' OR da.full_name LIKE '%Morgan Stanley%' THEN (CASE
                WHEN RTRIM(LTRIM(SUBSTRING(SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))))), 0, CHARINDEX('//', SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))))))))) <> '' THEN SUBSTRING(SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))))), 0, CHARINDEX('//', SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))))))
                ELSE da.full_name
            END)
            ELSE da.full_name
        END AS agent,
        /* DA.FULL_NAME AS [Agent], */
        CASE
            WHEN da.full_name LIKE '%Merrill Lynch%' OR da.full_name LIKE '%Small Business Ins%' OR da.full_name LIKE '%Morgan Stanley%' THEN (CASE
                WHEN LTRIM(RTRIM(SUBSTRING(SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))))), CHARINDEX('//', SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))))) + 2, LENGTH(SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))))))))) <> '' THEN SUBSTRING(SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))))), CHARINDEX('//', SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))))) + 2, LENGTH(SUBSTRING(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)))), CHARINDEX('//', SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))) + 2, LENGTH(SUBSTRING(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes)), CHARINDEX('//', SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))) + 2, LENGTH(SUBSTRING(internal_notes, CHARINDEX('//', internal_notes) + 2, LENGTH(internal_notes))))))))
                ELSE NVL(da.curr_city, '') || ', ' || NVL(da.curr_state, '')
            END)
            ELSE NVL(da.curr_city, '') || ', ' || NVL(da.curr_state, '')
        END AS "agent address", SUBSTRING(SUBSTRING(SUBSTRING(ppe.internal_notes, CHARINDEX('//', ppe.internal_notes) + 2, LENGTH(ppe.internal_notes)), CHARINDEX('//', SUBSTRING(ppe.internal_notes, CHARINDEX('//', ppe.internal_notes) + 2, LENGTH(ppe.internal_notes))) + 2, LENGTH(SUBSTRING(ppe.internal_notes, CHARINDEX('//', ppe.internal_notes) + 2, LENGTH(ppe.internal_notes)))), 0, CHARINDEX('//', SUBSTRING(SUBSTRING(ppe.internal_notes, CHARINDEX('//', ppe.internal_notes) + 2, LENGTH(ppe.internal_notes)), CHARINDEX('//', SUBSTRING(ppe.internal_notes, CHARINDEX('//', ppe.internal_notes) + 2, LENGTH(ppe.internal_notes))) + 2, LENGTH(SUBSTRING(ppe.internal_notes, CHARINDEX('//', ppe.internal_notes) + 2, LENGTH(ppe.internal_notes)))))) AS notes, ppe.internal_notes, CONVERT (VARCHAR(6000), NULL) AS "outstanding reqs", pr.product_plan_desc AS product, df.firm_name AS office, f.sale_dt AS "submit date", rdp.status_dt AS "status date", ppe.contact_email AS "contact email", ppe.contact_cc_email AS "contact cc email", f.channel_key_id, f.policy_key_id
        --INTO "#temp55_proc1"
        FROM vikas_dummy.rpt_dim_is_policy_pend_ext AS ppe
        JOIN vikas_dummy.fct_daily_trans_smry AS f
            ON ppe.policy_key_id = f.policy_key_id
        JOIN vikas_dummy.RPT_DIM_CHANNEL AS RDC
            ON f.channel_key_id = RDC.CHANNEL_KEY_ID
        JOIN vikas_dummy.rpt_dim_product AS pr
            ON f.product_key_id = pr.product_key_id
        LEFT OUTER JOIN vikas_dummy.ref_is_pend_status_code AS psc
            ON ppe.status_cd_key_id = psc.status_cd_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_policy AS rdp
            ON ppe.policy_key_id = rdp.policy_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_advisor AS da
            ON f.advisor_key_id = da.advisor_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_firm AS df
            ON f.firm_key_id = df.firm_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_territory_external_rel AS ter
            ON f.territory_key_id = ter.territory_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_external_wholesaler AS ew
            ON ter.external_wholesaler_key_id = ew.external_wholesaler_id
        LEFT OUTER JOIN vikas_dummy.ref_is_pend_tobacco_desc AS ipt
            ON NVL(ppe.tobacco_rating_applied, 'NS') = ipt.tobacco_desc_cd
        WHERE ((psc.status_type IN ('PND') OR (psc.status_cd_desc IN ('TRIAL CLOSED') AND NULL < 15)) AND NULL < 15 AND f.is_compensible_flg = 'Y' AND f.transaction_group_cd = 'P' AND RDC.CHANNEL_CD IN ('WRH', 'BNK') AND pr.product_sub_group_cd = 'LIFE' AND NVL(ppe.internal_notes, 'OO') NOT LIKE 'XX%' AND NVL(ppe.internal_notes, 'OO') NOT LIKE 'MGA%' AND ppe.lob_key_cd <> 'ULLTC' AND ppe.origin_cd = 'NBL' AND ppe.app_type_key_cd IN ('COM', 'CON', 'EXC', 'FRM', 'TRI'))
        ORDER BY 3 NULLS FIRST