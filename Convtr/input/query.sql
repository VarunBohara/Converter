
with peers_position
    as (select
        a15.external_wholesale_group_cd as wholesale_group_cd, a12.external_wholesaler_key_id as ext_wholesaler_id, ntile(4) over (partition by a15.external_wholesale_group_cd order by sum(((a11.total_sale_amt / 1000) * a12.split_percentage)) desc nulls first) as quartile
        from tst_dbo.fct_daily_trans_smry as a11
        join tst_dbo.rpt_territory_external_rel as a12
            on (a11.territory_key_id = a12.territory_key_id)
        join tst_dbo.dim_day as a13
            on (a11.date_key_id = a13.date_key_id)
        join tst_dbo.dim_week as a14
            on (a13.week_key_id = a14.week_key_id)
        join tst_dbo.rpt_dim_external_wholesaler as a15
            on (a12.external_wholesaler_key_id = a15.external_wholesaler_id)
        where (a11.transaction_group_cd in ('f') and a11.is_compensible_flg in ('y') and a15.external_wholesale_group_cd in ('ann03', 'ann17', 'ann18', 'ann19', 'ann20') and a15.external_wholesaler_name not like 'tba%' and ((dateadd(week, datediff(week, 0, a14.week_of_year_begin_date), - 1)) in (select
            dateadd(week, datediff(week, 0, c21.week_of_year_begin_date), - 1)
            from tst_dbo.dim_week as c21
            cross join tst_dbo.vw_curr_business_day as c23
            where dateadd(week, datediff(week, 0, c21.week_of_year_begin_date), - 1) between dateadd(day, null, dateadd(week, - 13, c23.sale_dt)) and dateadd(day, null, dateadd(week, - 2, c23.sale_dt)))))
        group by a15.external_wholesale_group_cd, a12.external_wholesaler_key_id), peers_top
    as (select
        external_wholesaler_key_id
        from peers_position
        where quartile = 1)
    select
        a11.activity_key_id as activity_key_id, a111.divisional_sales_manager_id as divisional_sales_manager_id, max(a111.divisional_sales_manager_name) as divisional_sales_manager_name, a111.divisional_sales_manager_logon_id as dsm_logon_id, a12.external_wholesaler_key_id as ext_wholesaler_id, max(a111.external_wholesaler_name) as ext_wholesaler_name, a111.external_wholesaler_logon_id as ew_logon_id, dateadd(week, datediff(week, 0, a14.week_of_year_begin_date), - 1) as week_num_overall,
        case
            when ((dateadd(week, datediff(week, 0, a14.week_of_year_begin_date), - 1)) in (select
                dateadd(week, datediff(week, 0, c21.week_of_year_begin_date), - 1)
                from tst_dbo.dim_week as c21
                cross join tst_dbo.vw_curr_business_day as c23
                where dateadd(week, datediff(week, 0, c21.week_of_year_begin_date), - 1) between dateadd(day, null, dateadd(week, - 8, c23.sale_dt)) and dateadd(day, null, dateadd(week, - 1, c23.sale_dt)))) then 1
            else 0
        end as flag_8_weeks, max('week starts ' || left(a14.week_business_desc, 10)) as custcol_66, max(left(a14.week_business_desc, 10)) as week_business_desc, a11.deleted_flg as deleted_flag, a111.external_wholesale_group_cd as wholesale_group_cd, max(a113.wholesale_group_desc) as wholesale_group_desc,
        case
            when a19.product_sub_group_cd = 'dcms' then 'rps'
            else a19.product_sub_group_cd
        end as product_sub_group, max(a112.product_sub_group_desc) as product_sub_group_desc, a11.activity_type_cd as activity_type_cd, a11.activity_closed_flg as activity_closed_flag, a110.reporting_ind as reporting_ind, count(distinct a11.activity_key_id) as " # activities, last 8 weeks, not deleted, reported, closed"
        from tst_dbo.fct_activity as a11
        join tst_dbo.rpt_territory_external_rel as a12
            on (a11.territory_key_id = a12.territory_key_id)
        join tst_dbo.dim_day as a13
            on (a11.date_key_id = a13.date_key_id)
        join tst_dbo.dim_week as a14
            on (a13.week_key_id = a14.week_key_id)
        join tst_dbo.rpt_dim_product as a15
            on (a11.product_key_id = a15.product_key_id)
        join tst_dbo.rpt_dim_product_plan_category as a16
            on (a15.product_plan_category_cd = a16.product_plan_category_cd)
        join tst_dbo.rpt_dim_product_suite as a17
            on (a16.product_suite_cd = a17.product_suite_cd)
        join tst_dbo.rpt_dim_product_type as a18
            on (a17.product_type_cd = a18.product_type_cd)
        join tst_dbo.rpt_dim_product_cd as a19
            on (a18.product_cd = a19.product_cd)
        join tst_dbo.rpt_dim_activity_type as a110
            on (a11.activity_type_key_id = a110.activity_type_key_id)
        join tst_dbo.rpt_dim_external_wholesaler as a111
            on (a12.external_wholesaler_key_id = a111.external_wholesaler_id)
        join tst_dbo.rpt_dim_product_sub_group as a112
            on (case
                when a19.product_sub_group_cd = 'dcms' then 'rps'
                else a19.product_sub_group_cd
            end =
            case
                when a112.product_sub_group_cd = 'dcms' then 'rps'
                else a112.product_sub_group_cd
            end)
        join tst_dbo.ref_wholesale_group as a113
            on (a111.external_wholesale_group_cd = a113.wholesale_group_cd)
        where (case
            when a19.product_sub_group_cd = 'dcms' then 'rps'
            else a19.product_sub_group_cd
        end in ('va', 'fa') and a111.external_wholesale_group_cd in ('ann03', 'ann17', 'ann18', 'ann19', 'ann20') and
        /* and [a11].[activity_type_cd] is not null */
        a11.deleted_flg in ('n') and
        /* and [a11].[activity_closed_flg] in ('y') */
        /* and [a11].[title_assigned_to] in ('ext') */
        /* and [a110].[reporting_ind] in ('y') */
        a12.external_wholesaler_key_id in (select
            *
            from peers_top)) and ((dateadd(week, datediff(week, 0, a14.week_of_year_begin_date), - 1)) in (select
            dateadd(week, datediff(week, 0, c21.week_of_year_begin_date), - 1)
            from tst_dbo.dim_week as c21
            cross join tst_dbo.vw_curr_business_day as c23
            where dateadd(week, datediff(week, 0, c21.week_of_year_begin_date), - 1) between dateadd(day, null, dateadd(week, - 8, c23.sale_dt)) and dateadd(day, null, dateadd(week, - 1, c23.sale_dt))))
        group by a111.divisional_sales_manager_id, a111.divisional_sales_manager_logon_id, a12.external_wholesaler_key_id, a111.external_wholesaler_logon_id, a111.national_sales_manager_id, a111.national_sales_manager_logon_id, a111.product_head_logon_id, a111.product_head_id, dateadd(week, datediff(week, 0, a14.week_of_year_begin_date), - 1), a11.activity_key_id, a11.deleted_flg, a111.external_wholesale_group_cd,
        case
            when a19.product_sub_group_cd = 'dcms' then 'rps'
            else a19.product_sub_group_cd
        end, a11.activity_type_cd, a11.activity_closed_flg, a11.title_assigned_to, a110.reporting_ind;
   

