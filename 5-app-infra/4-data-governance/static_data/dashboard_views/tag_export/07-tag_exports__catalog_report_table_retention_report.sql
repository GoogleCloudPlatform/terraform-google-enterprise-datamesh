SELECT
project, dataset, table,
MAX (IF(tag_field = 'sensitive_category', tag_value, NULL)) as sensitive_category,
MAX (IF(tag_field = 'retention_period', tag_value, NULL)) as retention_period,
MAX (IF(tag_field = 'expiration_action', tag_value, NULL)) as expiration_action

FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags
GROUP BY project, dataset, table