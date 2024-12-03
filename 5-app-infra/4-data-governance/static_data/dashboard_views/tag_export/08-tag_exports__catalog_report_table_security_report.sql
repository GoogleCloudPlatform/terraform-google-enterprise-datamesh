SELECT
project, dataset, table,
ANY_VALUE (IF(tag_field = 'is_sensitive', tag_value, NULL)) as is_sensitive,
ANY_VALUE (IF(tag_field = 'sensitive_category', tag_value, NULL)) as sensitive_category,
ANY_VALUE (IF(tag_field = 'encryption_method', tag_value, NULL)) as encryption_method

FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags
where tag_template='cdmc_controls'
GROUP BY project, dataset, table, tag_template