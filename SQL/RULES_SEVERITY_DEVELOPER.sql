---------------------------------------CRIAR TABELA RULES_SEVERITY_DEVELOPER--------------------
IF Object_id('RULES_SEVERITY_DEVELOPER', 'U') IS NOT NULL 
  DROP TABLE RULES_SEVERITY_DEVELOPER;

  
SELECT c.author_name, 
		r.id,
       r.[name], 
       severity, 
       Count(0)   'total', 
       Sum(Isnull(effort, 0)) effort_total_min 
INTO   RULES_SEVERITY_DEVELOPER 
FROM   dbo.commits c (nolock) 
       JOIN [dbo].[issues] i (nolock) 
         ON c.[committer_hash] = i.[commiter_hash] 
       JOIN [dbo].[issues_sonar] iss (nolock) 
         ON iss.[commit_hash] = c.[committer_hash] 
            AND iss.id = i.[issue_id] 
            AND iss.issue_type = 1 
       JOIN dbo.rules r (nolock) 
         ON r.id = iss.[rule_id] 
GROUP  BY c.author_name, r.id,
          r.[name], 
          severity 
ORDER  BY 4 DESC 