---------------------------------------CRIAR TABELA VW_COMMITS--------------------------------------
IF Object_id('VW_COMMITS', 'U') IS NOT NULL 
  DROP TABLE VW_COMMITS; 

SELECT p.[name] 
       AS 
       'project_name', 
       m.[name] 
       AS 'metric_name', 
       pm.value 
       AS 'metric_value', 
       c.author_name, 
       CONVERT(DATETIME, Replace(CONVERT(VARCHAR, 
       c.committer_date), ',', ''), 103) AS 
       commit_date, 
       C.committer_hash 
--INTO    VW_COMMITS
FROM   sonar.dbo.project_measures pm (nolock) 
       INNER JOIN sonar.dbo.metrics m (nolock) 
               ON m.id = pm.metric_id 
       INNER JOIN sonar.dbo.snapshots s (nolock) 
               ON s.uuid = pm.analysis_uuid 
       INNER JOIN sonar.dbo.projects p (nolock) 
               ON p.uuid = pm.component_uuid 
       LEFT JOIN repository2.dbo.commits c (nolock) 
              ON CONVERT(VARCHAR(500), Replace(s.version, '1.0.0.', '')) COLLATE 
                 database_default 
                 = 
                           CONVERT(VARCHAR(500), 
                           Replace(c.committer_hash, '1.0.0.', '')) COLLATE 
                           database_default 
WHERE  pm.value IS NOT NULL
       AND p.[name] = 'wordpress'

select * from DATA_MODELO order by 1 desc

select * from ISSUES_TYPES  by 1 desc