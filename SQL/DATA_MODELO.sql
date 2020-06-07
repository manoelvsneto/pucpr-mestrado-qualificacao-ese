--------------------CRIAR TABELA DATA_MODELO  E TIME_SERIES_PREDICT


SELECT 
   ROW_NUMBER() OVER (
 ORDER BY commit_date
   ) row_num, author_name , committer_hash ,commit_date,
 isnull(files,0) as files ,
 isnull(ncloc,0) as ncloc ,
 isnull(sqale_index,0) as sqale_index ,
 isnull(code_smells,0) as code_smells ,
 isnull(classes,0) as classes 
 INTO #PV
FROM [Repository2].[dbo].[PIVOT_DATA] order by commit_date ASC



SELECT *  INTO DATA_MODELO 
FROM (
SELECT B.row_num, B.committer_hash,  B.author_name,
CASE  WHEN B.author_name = A.author_name THEN 'YES' ELSE 'NO' END AS 'PREVIUS_COMMIT_IS_MY',
CASE  WHEN B.code_smells = A.code_smells THEN 'EQUAL' WHEN B.code_smells > A.code_smells THEN 'ADD' ELSE 'REM' END AS 'CODE_SMELL',
CASE  WHEN B.files = A.files THEN 'EQUAL' WHEN B.files > A.files THEN 'ADD' ELSE 'REM' END AS 'FILES',
CASE  WHEN B.ncloc = A.ncloc THEN 'EQUAL' WHEN B.ncloc > A.ncloc THEN 'ADD' ELSE 'REM' END AS 'NCLOC',
CASE  WHEN B.sqale_index = A.sqale_index THEN 'EQUAL' WHEN B.sqale_index > A.sqale_index THEN 'ADD' ELSE 'REM' END AS 'SQALE_INDEX',
CASE  WHEN B.classes = A.classes THEN 'EQUAL' WHEN B.classes > A.classes THEN 'ADD' ELSE 'REM' END AS 'CLASSES'
,B.code_smells AS 'CODE_SMELL_QTD' ,B.files AS 'FILES_QTD', B.ncloc AS 'NCLOC_QTD' , B.sqale_index AS 'SQI_QTD' ,B.classes  AS 'CLASSES_QTD'

FROM #PV A LEFT JOIN #PV B
ON (B.row_num - 1 = A.row_num) 
) AS  Q WHERE row_num IS NOT NULL
order by Q.row_num





INSERT INTO DATA_MODELO 
SELECT * FROM (
SELECT B.row_num, B.committer_hash,  B.author_name,
'NA' AS 'PREVIUS_COMMIT_IS_MY',
'NA' AS 'CODE_SMELL',
'NA' AS 'FILES',
'NA' AS 'NCLOC',
'NA' AS 'SQALE_INDEX',
'NA' AS 'CLASSES'
,B.code_smells AS 'CODE_SMELL_QTD' ,B.files AS 'FILES_QTD', ISNULL(B.ncloc,0) AS 'NCLOC_QTD' , B.sqale_index AS 'SQI_QTD' ,B.classes  AS 'CLASSES_QTD'
FROM #PV A RIGHT JOIN #PV B
ON B.row_num - 1 = A.row_num  
) 
AS D 
WHERE row_num = 1
order by row_num





SELECT  a.row_num,  A.author_name,
CASE  WHEN B.author_name = A.author_name THEN 'YES' ELSE 'NO' END AS 'PREVIUS_COMMIT_IS_MY',
CASE  WHEN B.code_smells = A.code_smells THEN 'EQUAL' WHEN B.code_smells > A.code_smells THEN 'ADD' ELSE 'REM' END AS 'CODE_SMELL',
convert(int, B.code_smells) AS 'CODE_SMELL_QTD' , convert(int,  b.code_smells - a.code_smells) as 'DIFF'
INTO TIME_SERIES_PREDICT
FROM #PV A LEFT JOIN #PV B
ON B.row_num - 1 = A.row_num
order by a.row_num

