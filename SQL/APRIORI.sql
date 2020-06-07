----------------CRIAR TABELA APRIORI
	  select a.id, A.committer_hash,  author_name,  [Open] as 'Code_Smell_Qtd' , 
	  CASE WHEN A.[ADD] > 0 THEN 'S' ELSE 'N' END AS [ADD] , 
	  CASE WHEN A.[DEL] > 0 THEN 'S' ELSE 'N' END AS [DEL] ,
	  CASE WHEN A.[MOD] > 0 THEN 'S' ELSE 'N' END AS [MOD] ,
	  CASE WHEN A.[REN] > 0 THEN 'S' ELSE 'N' END AS [REN] ,
	  --CASE WHEN A.[UNK] > 0 THEN 'S' ELSE 'N' END AS [UNK] ,
	  A.PREVIUS_COMMIT_IS_MY,
	  A.CODE_SMELL,
	  A.FILES,
	  A.NCLOC,
	  A.CLASSES,
	  CASE WHEN A.additions_lines > 0 THEN 'S' ELSE 'N' END AS additions_lines ,
	  CASE WHEN A.deletions_lines > 0 THEN 'S' ELSE 'N' END AS deletions_lines ,
	  CASE WHEN A.changed_files > 0 THEN 'S' ELSE 'N' END AS changed_files ,
	   B.*
	  into #dados
	  from ALLDATA A JOIN RULES_PIVOT B ON A.committer_hash = B.COMMIT_HASH    
	  order by A.id

	

	ALTER TABLE #dados DROP COLUMN commit_hash
	ALTER TABLE #dados DROP COLUMN hv_rules
	ALTER TABLE #dados DROP COLUMN CODE_SMELL

	select * from #dados

	DROP TABLE APRIORI
	select * INTO APRIORI from #dados
	DROP TABLE #dados

	SELECT * FROM APRIORI  ORDER BY 1

	

