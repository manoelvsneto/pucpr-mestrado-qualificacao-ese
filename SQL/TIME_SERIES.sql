---------------------------------------CRIAR TABELA TIME_SERIES--------------------
IF Object_id('TIME_SERIES', 'U') IS NOT NULL 
  DROP TABLE TIME_SERIES; 


SELECT c.author_name, 
	   r.id,
       r.[name], 
       CONVERT(VARCHAR(10), CONVERT(DATETIME, C.committer_date, 103), 120) 
       + ' 00:00:00' AS date, 
       Count(0)      AS total 
INTO   time_series 
FROM   dbo.commits c 
       JOIN [dbo].[issues] i 
         ON c.[committer_hash] = i.[commiter_hash] 
       JOIN [dbo].[issues_sonar] iss 
         ON iss.[commit_hash] = c.[committer_hash] 
            AND iss.id = i.[issue_id] 
            AND iss.issue_type = 1 
       JOIN sonar.dbo.rules r 
         ON r.id = iss.[rule_id] 
GROUP  BY c.author_name,    r.id,
          r.[name], 
          CONVERT(VARCHAR(10), CONVERT(DATETIME, C.committer_date, 103), 120) 
          + ' 00:00:00' 
ORDER  BY 1 