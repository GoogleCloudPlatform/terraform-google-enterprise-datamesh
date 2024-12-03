SELECT
  SUBSTR(DataAsset, (STRPOS(DataAsset, '/projects/') + 10), STRPOS(DataAsset, '/datasets/') - STRPOS(DataAsset, '/projects/') - 10) as Project_Name,
  SUBSTR(DataAsset, (STRPOS(DataAsset, '/datasets/') + 10), STRPOS(DataAsset, '/tables/') - STRPOS(DataAsset, '/datasets/') - 10) as Dataset_Name,
  SUBSTR(DataAsset, (STRPOS(DataAsset, '/tables/') + 8), LENGTH(DataAsset) - STRPOS(DataAsset, '/tables/') - 7) as Table_Name,
  COUNTIF(CdmcControlNumber=1) as C01_Findings,
  COUNTIF(CdmcControlNumber=2) as C02_Findings,
  COUNTIF(CdmcControlNumber=3) as C03_Findings,
  COUNTIF(CdmcControlNumber=4) as C04_Findings,
  COUNTIF(CdmcControlNumber=5) as C05_Findings,
  COUNTIF(CdmcControlNumber=6) as C06_Findings,
  COUNTIF(CdmcControlNumber=7) as C07_Findings,
  COUNTIF(CdmcControlNumber=8) as C08_Findings,
  COUNTIF(CdmcControlNumber=9) as C09_Findings,
  COUNTIF(CdmcControlNumber=10) as C10_Findings,
  COUNTIF(CdmcControlNumber=11) as C11_Findings,
  COUNTIF(CdmcControlNumber=12) as C12_Findings,
  COUNTIF(CdmcControlNumber=13) as C13_Findings,
  COUNTIF(CdmcControlNumber=14) as C14_Findings,

from
  `${project_id_gov}`.cdmc_report_${environment}.events
where
  reportMetadata.uuid=(SELECT reportMetadata.uuid FROM `${project_id_gov}`.cdmc_report_${environment}.events order by ExecutionTimestamp desc limit 1)
  # and DataAsset NOT LIKE ('%finwire%')
  and CdmcControlNumber > 0
group by DataAsset
Order by DataAsset
