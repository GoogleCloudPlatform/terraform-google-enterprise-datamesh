SELECT
  reportMetadata.uuid as UUID,
  ExecutionTimestamp,
  reportMetadata.Controls as Controls_In_Scope
FROM `${project_id_gov}`.cdmc_report_${environment}.events
order by ExecutionTimestamp desc
limit 1
