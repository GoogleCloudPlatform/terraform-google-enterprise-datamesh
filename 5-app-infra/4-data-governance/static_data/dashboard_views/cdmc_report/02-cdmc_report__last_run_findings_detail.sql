SELECT
  SUBSTR(DataAsset, (STRPOS(DataAsset, '/projects/') + 10), STRPOS(DataAsset, '/datasets/') - STRPOS(DataAsset, '/projects/') - 10) as Project_Name,
  SUBSTR(DataAsset, (STRPOS(DataAsset, '/datasets/') + 10), STRPOS(DataAsset, '/tables/') - STRPOS(DataAsset, '/datasets/') - 10) as Dataset_Name,
  SUBSTR(DataAsset, (STRPOS(DataAsset, '/tables/') + 8), LENGTH(DataAsset) - STRPOS(DataAsset, '/tables/') - 7) as Table_Name,
  CdmcControlNumber as Control_Number,
  Findings as Finding_Description,
  RecommendedAdjustment as Recommended_Adjustment
FROM
  `${project_id_gov}`.cdmc_report_${environment}.events
where
  CdmcControlNumber>0
  AND reportMetadata.uuid=(SELECT reportMetadata.uuid FROM `${project_id_gov}`.cdmc_report_${environment}.events order by ExecutionTimestamp desc limit 1)
