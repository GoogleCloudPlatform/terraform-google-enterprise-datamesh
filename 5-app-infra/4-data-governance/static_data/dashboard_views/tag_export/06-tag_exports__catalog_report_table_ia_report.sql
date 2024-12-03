SELECT
proj_tags.project, proj_tags.dataset, proj_tags.table,

ANY_VALUE (IF(proj_tags.tag_field = 'approved_storage_location', proj_tags.tag_value, NULL)) as approved_storage_location,
ANY_VALUE (IF(proj_tags.tag_field = 'is_sensitive', proj_tags.tag_value, NULL)) as is_sensitive,
ANY_VALUE (IF(proj_tags.tag_field = 'sensitive_category', proj_tags.tag_value, NULL)) as sensitive_category,
(SELECT ia_tags.tag_value FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags ia_tags
  WHERE ia_tags.project=proj_tags.project
  AND ia_tags.dataset=proj_tags.dataset
  AND ia_tags.table=proj_tags.table
  AND ia_tags.tag_field='subject_locations'
  AND ia_tags.tag_template='impact_assessment') as subject_locations,
(SELECT ia_tags.tag_value FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags ia_tags
  WHERE ia_tags.project=proj_tags.project
  AND ia_tags.dataset=proj_tags.dataset
  AND ia_tags.table=proj_tags.table
  AND ia_tags.tag_field='is_dpia'
  AND ia_tags.tag_template='impact_assessment') as is_dpia,
(SELECT ia_tags.tag_value FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags ia_tags
  WHERE ia_tags.project=proj_tags.project
  AND ia_tags.dataset=proj_tags.dataset
  AND ia_tags.table=proj_tags.table
  AND ia_tags.tag_field='is_pia'
  AND ia_tags.tag_template='impact_assessment') as is_pia,
(SELECT ia_tags.tag_value FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags ia_tags
  WHERE ia_tags.project=proj_tags.project
  AND ia_tags.dataset=proj_tags.dataset
  AND ia_tags.table=proj_tags.table
  AND ia_tags.tag_field='most_recent_assessment'
  AND ia_tags.tag_template='impact_assessment') as most_recent_assessment,
(SELECT ia_tags.tag_value FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags ia_tags
  WHERE ia_tags.project=proj_tags.project
  AND ia_tags.dataset=proj_tags.dataset
  AND ia_tags.table=proj_tags.table
  AND ia_tags.tag_field='oldest_assessment'
  AND ia_tags.tag_template='impact_assessment') as oldest_assessment

FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags proj_tags
where proj_tags.tag_template='cdmc_controls'
GROUP BY project, dataset, table, tag_template