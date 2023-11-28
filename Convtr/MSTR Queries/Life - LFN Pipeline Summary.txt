SELECT DISTINCT
        rdc.Sub_Channel_Cd, rdc.Channel_Cd, ppe.policy_number AS "policy #", ppe.prod_premium,
        CASE
            WHEN ppe.lob_key_cd = 'TERM' THEN ppe.prod_premium
            WHEN pr.product_sub_group_cd IN ('MG') AND pr.product_cd IN ('MMA', 'MFA') THEN rdp.total_policy_val
            WHEN pr.product_sub_group_cd IN ('MG') THEN ppe.rop_threshold_premium
            WHEN ppe.target_premium = 0 THEN NVL(ppe.prod_premium, 0)
            ELSE NVL(ppe.target_premium, NVL(ppe.prod_premium, 0))
        END AS target,
        CASE
            WHEN pr.product_sub_group_cd IN ('MG') AND pr.product_cd IN ('MMA', 'MFA') THEN rdp.total_policy_val
            WHEN pr.product_sub_group_cd IN ('MG') THEN ppe.rop_threshold_premium * 0.15
            ELSE NVL(ppe.prod_premium, 0)
        END AS premium,
        CASE
            WHEN ppe.app_type_key_cd = 'TRI' THEN 'TRIAL'
            WHEN pr.product_sub_group_cd IN ('MG') THEN REPLACE(pr.product_type_desc, 'MoneyGuard', 'MG')
            ELSE ppe.lob_key_desc
        END AS lob,
        CASE
            WHEN rdc.SUB_CHANNEL_CD = 'LFA' OR (df.firm_cdw_id = 'CDW002849' AND rdc.CHANNEL_CD IN ('IPI', 'WRH', 'BNK', 'HYB')) THEN 'LFA'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('PGRP', 'MGRP') THEN 'Producer Group'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('WRH', 'BNK') THEN 'WIRE/BANK'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('EDJ') THEN 'ED Jones'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('MGA') AND pr.product_type_cd = 'TM' AND rsm.full_name LIKE '%Selectquote%' THEN 'SELECT QUOTE'
        /* Aggregator */
            WHEN rdc.SUB_CHANNEL_CD IN ('GA') AND rda.agency_cdw_id IN ('CDWE16995') AND pr.product_type_cd = 'TM' THEN 'GA Aggregator'
        /* Aggregator */
            WHEN rdc.SUB_CHANNEL_CD IN ('GA') AND rda.agency_cdw_id IN ('CDWE21155') AND pr.product_type_cd = 'TM' THEN 'GA Aggregator'
        /* Aggregator */
            WHEN rdc.SUB_CHANNEL_CD IN ('UNA') THEN 'Unassigned'
        /* WHEN RDC.SUB_CHANNEL_CD IN('LFA','GA Aggregator','GA','ABGA') THEN 'LFN Total' -- LFN */
            ELSE rdc.SUB_CHANNEL_CD
            /* Brokerage:(MGA,ABGA,GA), LFN:(ABGA,GA,LFGA) */
        END AS "dist channel", f.channel_key_id, f.policy_key_id
        --INTO "#t2_life_lfn_pipeline_summary_procedure"
        FROM vikas_dummy.rpt_dim_is_policy_pend_ext AS ppe
        JOIN vikas_dummy.fct_daily_trans_smry AS f
            ON ppe.policy_key_id = f.policy_key_id
        JOIN vikas_dummy.RPT_DIM_CHANNEL AS rdc
            ON f.channel_key_id = rdc.CHANNEL_KEY_ID
        JOIN vikas_dummy.rpt_dim_product AS pr
            ON f.product_key_id = pr.product_key_id
        LEFT OUTER JOIN vikas_dummy.ref_is_pend_status_code AS psc
            ON ppe.status_cd_key_id = psc.status_cd_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_policy AS rdp
            ON ppe.policy_key_id = rdp.policy_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_firm AS df
            ON f.firm_key_id = df.firm_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_advisor_hierarchy AS ah
            ON f.advisor_hierarchy_key_id = ah.advisor_hierarchy_key_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_advisor AS rsm
            ON ah.rsm_key = rsm.advisor_id
        LEFT OUTER JOIN vikas_dummy.rpt_dim_agency AS rda
            ON ah.agency_key_id = rda.agency_key_id
        WHERE ((psc.status_type IN ('PND') OR (psc.status_cd_desc IN ('TRIAL CLOSED') AND NULL <= 90)) AND f.is_compensible_flg = 'Y' AND f.transaction_group_cd = 'P' AND
        CASE
            WHEN rdc.Sub_Channel_Cd = 'LFA' OR (df.firm_cdw_id = 'CDW002849' AND rdc.CHANNEL_CD IN ('IPI', 'WRH', 'BNK', 'HYB')) THEN 'LFA'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('PGRP', 'MGRP') THEN 'Producer Group'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('WRH', 'BNK') THEN 'WIRE/BANK'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('EDJ') THEN 'ED Jones'
        /* Advisor */
            WHEN rdc.SUB_CHANNEL_CD IN ('MGA') AND pr.product_type_cd = 'TM' AND rsm.full_name LIKE '%Selectquote%' THEN 'SELECT QUOTE'
        /* Aggregator */
            WHEN rdc.SUB_CHANNEL_CD IN ('GA') AND rda.agency_cdw_id IN ('CDWE16995') AND pr.product_type_cd = 'TM' THEN 'ZANDER'
        /* Aggregator */
            WHEN rdc.SUB_CHANNEL_CD IN ('GA') AND rda.agency_cdw_id IN ('CDWE21155') AND pr.product_type_cd = 'TM' THEN 'POLICYGENIUS'
        /* Aggregator */
        /* WHEN RDC.SUB_CHANNEL_CD IN('LFA','GA Aggregator','GA','ABGA') THEN 'LFN Total' -- LFN */
            ELSE rdc.SUB_CHANNEL_CD
            /* Brokerage:(MGA,ABGA,GA), LFN:(ABGA,GA,LFGA) */
        END IN ('LFA', 'GA', 'ABGA', 'ZANDER', 'POLICYGENIUS') AND pr.product_sub_group_cd IN ('LIFE', 'MG') AND ppe.policy_number NOT IN ('MG10056058', 'MG10062801'));
    --OPEN cur FOR
    SELECT
        CASE
            WHEN "dist channel" IN ('LFA', 'GA', 'GA Aggregator', 'ABGA') THEN 'LFN Total'
            ELSE "dist channel"
        END AS "dist channel", NVL(lob, '') AS lob, SUM(premium) AS premium, COUNT("policy #") AS "policy count", SUM(target) AS target
        FROM "#t2_life_lfn_pipeline_summary_procedure"
        /* where [Dist Channel] in ('LFA','GA','GA Aggregator','ABGA') */
        GROUP BY
        CASE
            WHEN "dist channel" IN ('LFA', 'GA', 'GA Aggregator', 'ABGA') THEN 'LFN Total'
            ELSE "dist channel"
        END, NVL(lob, '')
    UNION
    SELECT
        NVL("dist channel", '') AS "dist channel", NVL(lob, '') AS lob, SUM(premium) AS premium, COUNT("policy #") AS "policy count", SUM(target) AS target
        FROM "#t2_life_lfn_pipeline_summary_procedure"
        GROUP BY NVL("dist channel", ''), NVL(lob, '')
        ORDER BY 1 DESC NULLS FIRST;
