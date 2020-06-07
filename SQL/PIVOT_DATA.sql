------------------------CRIAR TABELA PIVOT_DATA
IF Object_id('PIVOT_DATA', 'U') IS NOT NULL 
  DROP TABLE PIVOT_DATA; 


  DECLARE @cols NVARCHAR(max) 

SET @cols = Stuff((SELECT DISTINCT ',' + Quotename( A.metric_name) 
                   FROM   vw_commits a 
                   WHERE  metric_name NOT IN ( 'complexity_in_classes', 
                                               'complexity_in_functions' 
                                             ) 
                   FOR xml path('')), 1, 1, ''); 

DECLARE @query AS NVARCHAR(max); 
SET @query= ' SELECT *  INTO 
PIVOT_DATA FROM  (   SELECT A.METRIC_NAME , A.METRIC_VALUE , A.committer_hash,a.commit_date,a.author_name   
FROM VW_COMMITS A where  A.METRIC_VALUE is not null ) AS C PIVOT (     MAX(C.METRIC_VALUE)     FOR C.METRIC_NAME  IN ( ' + @cols + ' )  ) as P order by 2 asc;'; 
EXECUTE(@query) 