SELECT
project, dataset, table, column,
MAX (IF(tag_field = 'sensitive_field', tag_value, NULL)) as sensitive_field,
MAX (IF(tag_field = 'sensitive_type', tag_value, NULL)) as sensitive_type,

MAX (IF(tag_template = 'completeness_template', IF(tag_field = 'metric', tag_value, NULL), NULL)) as completenes_metric,
MAX (IF(tag_template = 'completeness_template', IF(tag_field = 'rows_validated', tag_value, NULL), NULL)) as completenes_rows_validated,
MAX (IF(tag_template = 'completeness_template', IF(tag_field = 'success_percentage', CAST(tag_value AS NUMERIC) * 100, NULL), NULL)) as completenes_success_percentage,
MAX (IF(tag_template = 'completeness_template', IF(tag_field = 'acceptable_threshold', tag_value, NULL), NULL)) as completenes_acceptable_threshold,
MAX (IF(tag_template = 'completeness_template', IF(tag_field = 'meets_threshold', tag_value, NULL), NULL)) as completenes_meets_threshold,
MAX (IF(tag_template = 'completeness_template', IF(tag_field = 'most_recent_run', tag_value, NULL), NULL)) as completenes_most_recent_run,

MAX (IF(tag_template = 'correctness_template', IF(tag_field = 'metric', tag_value, NULL), NULL)) as correctness_metric,
MAX (IF(tag_template = 'correctness_template', IF(tag_field = 'rows_validated', tag_value, NULL), NULL)) as correctness_rows_validated,
MAX (IF(tag_template = 'correctness_template', IF(tag_field = 'success_percentage', CAST (tag_value AS NUMERIC) * 100, NULL), NULL)) as correctness_success_percentage,
MAX (IF(tag_template = 'correctness_template', IF(tag_field = 'acceptable_threshold', tag_value, NULL), NULL)) as correctness_acceptable_threshold,
MAX (IF(tag_template = 'correctness_template', IF(tag_field = 'meets_threshold', tag_value, NULL), NULL)) as correctness_meets_threshold,
MAX (IF(tag_template = 'correctness_template', IF(tag_field = 'most_recent_run', tag_value, NULL), NULL)) as correctness_most_recent_run,

FROM `${project_id_gov}`.tag_exports.catalog_report_column_tags
GROUP BY project, dataset, table, column