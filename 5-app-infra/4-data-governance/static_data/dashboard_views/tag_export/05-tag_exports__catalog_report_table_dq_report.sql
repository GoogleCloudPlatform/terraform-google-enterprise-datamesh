SELECT project, dataset, table,
MAX (sensitive_type) as sensitive_type,
MIN (completenes_meets_threshold) as dq_is_complete,
MIN (correctness_meets_threshold) as dq_is_correct,
 FROM `${project_id_gov}`.tag_exports.catalog_report_column_dq_report
where completenes_meets_threshold IS NOT NULL OR correctness_meets_threshold IS NOT NULL
GROUP BY project, dataset, table
ORDER BY project, dataset, table ASC