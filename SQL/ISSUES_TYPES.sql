---------------CRIAR TABELA ISSUES_TYPES
SELECT A.id,A.commit_hash,A.status,A.[issue_type]
INTO   ISSUES_TYPES
FROM   [dbo].[ISSUES_SONAR] A 

CREATE INDEX i_ISSUES_TYPES ON ISSUES_TYPES (commit_hash)