SELECT project, dataset,
  COUNT(table) as num_tables,
  COUNTIF(Total_Findings > 0) as num_tables_with_findings,
  COUNTIF(sensitive = true) as num_sensitive_tables,
  ROUND(COUNTIF(Total_Findings > 0) / COUNT(table), 2) as percentage_with_findings
FROM `${project_id_gov}`.cdmc_report_${environment}._last_run_findings_summary_alldata
GROUP BY project, dataset
