---------------------CRIAR TABELA ALLDATA
SELECT C.id, C.committer_date, C.author_name,C.committer_hash,  
CA.[Open], CA.Closed,
CA.code_smells, ISNULL( CDP.[ADD],0) AS [ADD], ISNULL(CDP.DEL,0) AS [DEL], ISNULL(CDP.[MOD],0) AS [MOD], ISNULL( CDP.REN,0) AS [REN],
ISNULL(CDP.UNK,0) AS [UNK] , DM.PREVIUS_COMMIT_IS_MY,DM.CODE_SMELL,
 DM.FILES,DM.NCLOC,DM.CLASSES, DM.FILES_QTD,DM.NCLOC_QTD,DM.CLASSES_QTD, isnull(a.additions_lines,0) as additions_lines,
 isnull(a.deletions_lines,0) as deletions_lines ,  isnull(a.changed_files,0) as changed_files
INTO ALLDATA
FROM DBO.COMMITS C  
	 LEFT JOIN [dbo].[LOG_COMMIT_ACTION] CA ON C.committer_hash = CA.committer_hash
     LEFT JOIN COMMITS_DETAIL_PIVOT CDP ON CDP.committer_hash = C.committer_hash
     LEFT JOIN DBO.DATA_MODELO DM ON DM.committer_hash = C.committer_hash
	 LEFT JOIN (
	 select  committer_hash, count(0) changed_files, sum(added) additions_lines , sum (removed) as deletions_lines from COMMITS_DETAIL 
	 group by committer_hash
	 )
	 as a on a.committer_hash = c.committer_hash 
	 WHERE CA.[Open] IS NOT NULL
	 --AND CDP.[ADD] IS NOT NULL
	 --AND DM.PREVIUS_COMMIT_IS_MY IS NOT NULL

ORDER BY 1
DROP TABLE ALLDATA

SELECT A.ID, A.[OPEN] CS,  CONVERT(INT, B.sqale_index) AS SQI  FROM ALLDATA A JOIN  PIVOT_DATA  B ON A.ID = B.ID  WHERE  A.ID > 1 AND A.ID <= 4129  ORDER BY 1 ASC


