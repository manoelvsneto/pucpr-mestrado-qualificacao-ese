DROP TABLE RULES_HASH
DROP TABLE [RULES_PIVOT]
DROP TABLE RULES_P
DROP TABLE #RULES_HASH

CREATE INDEX i_COMMITER_HASH ON [ISSUES_SONAR] ([commit_hash],ID)
CREATE INDEX i_COMMITER_HASH_ID ON [ISSUES_SONAR] ([commit_hash],ID)
CREATE INDEX i_COMMITER_HASH_ID_ID ON [ISSUES_SONAR] (ID)

SELECT DISTINCT ISSUE_ID ,commitER_hash INTO #ISSUE_ID FROM ISSUES (NOLOCK) WHERE commitER_hash  IN (
	SELECT COMMITTER_HASH FROM [TIME_SERIES_PREDICT] WHERE CS_aDD > 0 AND  ROW_NUM > 1 AND ROW_NUM <= 4129  AND CS_ACTION = 'ADD'
)


SELECT DISTINCT RULE_ID , ID INTO #ISSUE_RULE_ID  FROM ISSUES_SONAR (NOLOCK) B JOIN #ISSUE_ID C ON B.ID = C.ISSUE_ID WHERE ISSUE_TYPE = 1 AND status = 'OPEN'

SELECT DISTINCT RULE_ID,B.COMMITER_HASH AS 'COMMIT_HASH' INTO  RULES_HASH  FROM #ISSUE_RULE_ID A JOIN #ISSUE_ID B ON A.id = B.ISSUE_ID


CREATE INDEX i_COMMITER_HASH ON RULES_HASH (COMMIT_HASH)
Create NonClustered Index i_COMMITER_HASH_2 On RULES_HASH (COMMIT_HASH, RULE_ID)

SELECT * INTO #RULES_HASH FROM RULES_HASH
SELECT DISTINCT RULE_ID INTO RULES_P FROM    RULES_HASH  ORDER BY RULE_ID
SELECT DISTINCT COMMIT_HASH INTO  [RULES_PIVOT] FROM  RULES_HASH

WHILE ( (SELECT COUNT(0) FROM RULES_P) > 0)
BEGIN
	DECLARE @RULE_ID INT
	SELECT TOP 1 @RULE_ID = RULE_ID FROM RULES_P ORDER BY RULE_ID;
	DELETE RULES_P WHERE RULE_ID = @RULE_ID;
	DECLARE @query VARCHAR(MAX)
	SET @query= 'ALTER TABLE [RULES_PIVOT] ADD R_' +CONVERT(varchar,@RULE_ID) + ' VARCHAR(1);' ; 
	EXECUTE(@query) 
	SET @query= 'update  [RULES_PIVOT] SET R_' +CONVERT(varchar,@RULE_ID) + ' = ''0'';' ; 
	EXECUTE(@query) 

		WHILE ( (SELECT COUNT(0) FROM #RULES_HASH WHERE  RULE_ID = @RULE_ID ) > 0)
		BEGIN
			DECLARE @COMMIT_HASH VARCHAR(50);
			DECLARE @RULE_ID_B INT;
			SELECT TOP 1 @COMMIT_HASH = COMMIT_HASH , @RULE_ID_B = RULE_ID  FROM #RULES_HASH WHERE  RULE_ID = @RULE_ID;
			DELETE #RULES_HASH WHERE COMMIT_HASH = @COMMIT_HASH AND RULE_ID = @RULE_ID_B;

			DECLARE @query_2 VARCHAR(MAX)
			SET @query_2= 'UPDATE RULES_PIVOT SET R_'+CONVERT(varchar,@RULE_ID_B)+' =  (  SELECT COUNT(0) AS T FROM  (SELECT DISTINCT RULE_ID FROM  RULES_HASH WHERE COMMIT_HASH = '''+@COMMIT_HASH+''' AND RULE_ID = '+CONVERT(VARCHAR,@RULE_ID_B)+') AS Q) WHERE  COMMIT_HASH = '''+@COMMIT_HASH+''';' ; 
			EXECUTE(@query_2) 
			PRINT @query_2
		END

END


