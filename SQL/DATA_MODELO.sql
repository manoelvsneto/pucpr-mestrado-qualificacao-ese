--------------------CRIAR TABELA DATA_MODELO  E TIME_SERIES_PREDICT
DROP TABLE DATA_MODELO
DROP TABLE #PV

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

SELECT ROW_NUM,committer_hash, author_name, CODE_SMELL_QTD,0 AS CS_ADD, 0 AS CS_REM, 0 AS CS_EQ, 'EQU' AS CS_ACTION  INTO TIME_SERIES_PREDICT FROM DATA_MODELO ORDER BY 1 ASC


SELECT * FROM TIME_SERIES_PREDICT ORDER BY 1 ASC 

SELECT * INTO #TIME_SERIES_PREDICT FROM TIME_SERIES_PREDICT ORDER BY 1 ASC 

SELECT * FROM #TIME_SERIES_PREDICT

WHILE ( (SELECT COUNT(0) FROM #TIME_SERIES_PREDICT) > 0 )
BEGIN
		DECLARE @ROW_NUM INT;
		DECLARE @committer_hash VARCHAR(50);
		DECLARE @CS_CORRENT DECIMAL(18,0)

		SELECT TOP 1 @ROW_NUM = row_num  , @committer_hash = committer_hash, @CS_CORRENT = CODE_SMELL_QTD FROM #TIME_SERIES_PREDICT  ORDER BY ROW_NUM ASC
		DELETE FROM #TIME_SERIES_PREDICT WHERE  @ROW_NUM = row_num  AND @committer_hash = committer_hash
		IF(@ROW_NUM > 1)
		BEGIN

				DECLARE @CS_ANTERIOR DECIMAL(18,0)
				SELECT @CS_ANTERIOR = CODE_SMELL_QTD FROM TIME_SERIES_PREDICT  WHERE row_num = (@ROW_NUM - 1)
				IF(@CS_CORRENT = @CS_ANTERIOR)
				BEGIN
					UPDATE TIME_SERIES_PREDICT SET CS_ACTION = 'EQU'  WHERE   @ROW_NUM = row_num  AND @committer_hash = committer_hash
				END
				IF(@CS_CORRENT > @CS_ANTERIOR)
				BEGIN
					UPDATE TIME_SERIES_PREDICT SET CS_ADD = @CS_CORRENT - @CS_ANTERIOR WHERE   @ROW_NUM = row_num  AND @committer_hash = committer_hash
					UPDATE TIME_SERIES_PREDICT SET CS_ACTION = 'ADD'  WHERE   @ROW_NUM = row_num  AND @committer_hash = committer_hash
				END
				IF(@CS_CORRENT < @CS_ANTERIOR)
				BEGIN
					UPDATE TIME_SERIES_PREDICT SET CS_REM = @CS_ANTERIOR - @CS_CORRENT WHERE   @ROW_NUM = row_num  AND @committer_hash = committer_hash
					UPDATE TIME_SERIES_PREDICT SET CS_ACTION = 'REM'  WHERE   @ROW_NUM = row_num  AND @committer_hash = committer_hash
				END
				
		END

END


SELECT * FROM TIME_SERIES_PREDICT ORDER BY 1 ASC