SELECT
project, dataset, table, column,
MAX (IF(tag_field = 'sensitive_field', tag_value, NULL)) as sensitive_field,
MAX (IF(tag_field = 'sensitive_type', tag_value, NULL)) as sensitive_type,
MAX (IF(tag_field = 'platform_deid_method', tag_value, NULL)) as platform_deid_method

FROM `${project_id_gov}`.tag_exports.catalog_report_column_tags
GROUP BY project, dataset, table, column