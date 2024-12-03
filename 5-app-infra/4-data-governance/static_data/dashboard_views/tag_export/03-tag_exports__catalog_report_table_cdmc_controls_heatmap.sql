SELECT
project,
dataset,
table,
COUNTIF(tag_field='is_sensitive') > 0 as is_sensitive,
COUNTIF(tag_field='sensitive_category') > 0 as sensitive_cat,
COUNTIF(tag_field='data_owner_name') > 0 as owner_name,
COUNTIF(tag_field='data_owner_email') > 0 as owner_email,
COUNTIF(tag_field='is_authoritative') > 0 as is_authoritative,
COUNTIF(tag_field='approved_storage_location') > 0 as approved_locs,
COUNTIF(tag_field='approved_use') > 0 as approved_use,
COUNTIF(tag_field='ultimate_source') > 0 as ult_source,
COUNTIF(tag_field='sharing_scope_geography') > 0 as sharing_geo,
COUNTIF(tag_field='sharing_scope_legal_entity') > 0 as sharing_entity,
COUNTIF(tag_field='encryption_method') > 0 as encryption_meth,
COUNTIF(tag_field='retention_period') > 0 as retention_period,
COUNTIF(tag_field='expiration_action') > 0 as expiration_action

FROM `${project_id_gov}`.tag_exports.catalog_report_table_tags
where tag_template='cdmc_controls'
GROUP BY project, dataset, table, tag_template