SELECT
SPLIT(asset_name,'.') [ORDINAL(1)] as project,
SPLIT(asset_name,'.') [ORDINAL(2)] as dataset,
SPLIT(asset_name,'.') [ORDINAL(3)] as table,
sensitive

FROM `${project_id_gov}`.cdmc_report_${environment}.data_assets
WHERE event_timestamp = (SELECT MAX(event_timestamp) FROM `${project_id_gov}`.cdmc_report_${environment}.data_assets)
