------------------------CRIAR TABELA PIVOT_DATA
IF Object_id('PIVOT_DATA', 'U') IS NOT NULL 
  DROP TABLE PIVOT_DATA; 
    DROP TABLE PIVOT_DATA_B; 


  DECLARE @cols NVARCHAR(max) 

SET @cols = Stuff((SELECT DISTINCT ',' + Quotename( A.metric_name) 
                   FROM   vw_commits a 
                   WHERE  metric_name NOT IN ( 'complexity_in_classes', 
                                               'complexity_in_functions' 
                                             )  
                   FOR xml path('')), 1, 1, ''); 

DECLARE @query AS NVARCHAR(max); 
SET @query= ' SELECT *  INTO 
PIVOT_DATA_B FROM  (   SELECT A.METRIC_NAME , A.METRIC_VALUE , A.committer_hash,a.commit_date,a.author_name   
FROM VW_COMMITS A where  A.METRIC_VALUE is not null ) AS C PIVOT (     MAX(C.METRIC_VALUE)     FOR C.METRIC_NAME  IN ( ' + @cols + ' )  ) as P order by 2 asc;'; 
EXECUTE(@query) 


SELECT A.ID,B.* INTO PIVOT_DATA FROM COMMITS A JOIN PIVOT_DATA_B B ON A.committer_hash = B.committer_hash

SELECT * FROM PIVOT_DATA ORDER BY 1 ASC