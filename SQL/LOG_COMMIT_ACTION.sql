----------------------------CRIAR TABELA LOG_COMMIT_ACTION
IF Object_id('LOG_COMMIT_ACTION', 'U') IS NOT NULL 
  DROP TABLE log_commit_action; 

 


SELECT * 
INTO   LOG_COMMIT_ACTION
FROM   (SELECT Row_number() 
                 OVER ( 
                   ORDER BY commit_date ) row_num, 
               [code_smells], 
               author_name, 
               committer_hash, 
               commit_date, 
               0                          AS Quantity, 
               0                          AS 'Open', 
               0                          AS 'Closed', 
               0                          AS 'New' 
        FROM   [Repository2].[dbo].[pivot_data]) AS Q 
ORDER  BY commit_date ASC 



SELECT * 
INTO   #log_commit_action 
FROM   log_commit_action   

SELECT * FROM #log_commit_action ORDER BY ROW_NUM ASC


WHILE ( (SELECT Count(0) 
         FROM   #log_commit_action) > 0 ) 
  BEGIN 

      DECLARE @row_num INT; 
      DECLARE @quantity INT; 
      DECLARE @new INT; 
      DECLARE @open INT; 
      DECLARE @closed INT; 
      DECLARE @commit_hash VARCHAR(max); 
      DECLARE @code_smells DECIMAL(28, 20); 

      SELECT TOP 1 @row_num = row_num, 
                   @code_smells = code_smells, 
                   @commit_hash = committer_hash 
      FROM   #log_commit_action 
      ORDER  BY row_num ASC 

      DELETE #log_commit_action 
      WHERE  row_num = @row_num 

      SELECT @open = Count(0) 
      FROM   ISSUES_TYPES iss (nolock) 
      WHERE  Iss.commit_hash = @commit_hash 
             AND status = 'OPEN' 
             AND [issue_type] = 1 

      SELECT @closed = Count(0) 
      FROM   ISSUES_TYPES iss (nolock) 
      WHERE  Iss.commit_hash = @commit_hash 
             AND status = 'CLOSED' 
             AND [issue_type] = 1 

      SELECT @quantity = @open + @closed 

      SELECT @new = Count(0) 
      FROM   ISSUES_TYPES iss (nolock) 
             JOIN dbo.issues i (nolock) 
               ON iss.id = i.[issue_id] 
                  AND [issue_type] = 1 
                  AND commit_hash = @commit_hash 
				  and iss.commit_hash = i.COMMITER_HASH
                  AND iss.id IN (SELECT issue_id 
                                 FROM   issues (nolock) 
                                 WHERE  commiter_hash = @commit_hash) 

      UPDATE log_commit_action 
      SET    code_smells = @code_smells, 
             [open] = @open, 
             [closed] = @closed, 
             [quantity] = @quantity, 
             [new] = @new 
      WHERE  [committer_hash] = @commit_hash 
  END 




DROP TABLE #log_commit_action 





