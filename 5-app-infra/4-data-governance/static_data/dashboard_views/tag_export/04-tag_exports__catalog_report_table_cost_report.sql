SELECT
project, dataset, table,
MAX (IF(tag_field = 'sensitive_category', tag_value, NULL)) as sensitive_category,
FORMAT("%'d", CAST(MAX (IF(tag_field = 'total_query_bytes_billed', tag_value, NULL)) AS INT64)) as total_query_bytes_billed,
FORMAT("%'d", CAST(MAX (IF(tag_field = 'total_storage_bytes_billed', tag_value, NULL)) AS INT64)) as total_storage_bytes_billed,
FORMAT("%'d", CAST(MAX (IF(tag_field = 'total_bytes_transferred', tag_value, NULL)) AS INT64)) as total_bytes_transferred,
CONCAT('$',FORMAT("%.4f", CAST(MAX (IF(tag_field = 'estimated_query_cost', tag_value, NULL)) AS FLOAT64))) as estimated_query_cost,
CONCAT('$',FORMAT("%.4f", CAST(MAX (IF(tag_field = 'estimated_storage_cost', tag_value, NULL)) AS FLOAT64))) as estimated_storage_cost,
CONCAT('$',FORMAT("%.4f", CAST(MAX (IF(tag_field = 'estimated_egress_cost', tag_value, NULL)) AS FLOAT64))) as estimated_egress_cost,
CONCAT('$',FORMAT("%.4f", CAST(MAX (IF(tag_field = 'estimated_query_cost', tag_value, NULL)) AS FLOAT64)
  + CAST(MAX (IF(tag_field = 'estimated_storage_cost', tag_value, NULL)) AS FLOAT64)
  + CAST(MAX (IF(tag_field = 'estimated_egress_cost', tag_value, NULL)) AS FLOAT64))) as total_cost

FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags
GROUP BY project, dataset, table