SELECT
  assets.project,
  assets.dataset,
  assets.table,
  assets.sensitive,
  IF (findings.C01_Findings > 0, findings.C01_Findings, 0) as C01_Findings,
  IF (findings.C02_Findings > 0, findings.C02_Findings, 0) as C02_Findings,
  IF (findings.C03_Findings > 0, findings.C03_Findings, 0) as C03_Findings,
  IF (findings.C04_Findings > 0, findings.C04_Findings, 0) as C04_Findings,
  IF (findings.C05_Findings > 0, findings.C05_Findings, 0) as C05_Findings,
  IF (findings.C06_Findings > 0, findings.C06_Findings, 0) as C06_Findings,
  IF (findings.C07_Findings > 0, findings.C07_Findings, 0) as C07_Findings,
  IF (findings.C08_Findings > 0, findings.C08_Findings, 0) as C08_Findings,
  IF (findings.C09_Findings > 0, findings.C09_Findings, 0) as C09_Findings,
  IF (findings.C10_Findings > 0, findings.C10_Findings, 0) as C10_Findings,
  IF (findings.C11_Findings > 0, findings.C11_Findings, 0) as C11_Findings,
  IF (findings.C12_Findings > 0, findings.C12_Findings, 0) as C12_Findings,
  IF (findings.C13_Findings > 0, findings.C13_Findings, 0) as C13_Findings,
  IF (findings.C14_Findings > 0, findings.C14_Findings, 0) as C14_Findings,
  IF ((C01_Findings + C02_Findings + C03_Findings + C04_Findings + C05_Findings + C06_Findings + C07_Findings + C08_Findings + C09_Findings + C10_Findings + C11_Findings + C12_Findings + C13_Findings + C14_Findings) > 0, (C01_Findings + C02_Findings + C03_Findings + C04_Findings + C05_Findings + C06_Findings + C07_Findings + C08_Findings + C09_Findings + C10_Findings + C11_Findings + C12_Findings + C13_Findings + C14_Findings), 0) as Total_Findings
FROM
  (SELECT project, dataset, table, sensitive FROM `${project_id_gov}`.cdmc_report_${environment}._last_run_data_assets) as assets
FULL JOIN
  `${project_id_gov}`.cdmc_report_${environment}._last_run_findings_summary as findings
ON
  assets.project = findings.Project_Name AND assets.dataset = findings.Dataset_Name AND assets.table = findings.Table_Name
ORDER BY project, dataset, table ASC
