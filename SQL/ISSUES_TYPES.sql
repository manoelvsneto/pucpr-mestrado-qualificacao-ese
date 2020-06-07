---------------CRIAR TABELA ISSUES_TYPES
SELECT A.id,A.commit_hash,A.status,A.[issue_type]
INTO   ISSUES_TYPES
FROM   [dbo].[ISSUES_SONAR] A JOIN log_commit_action B
ON A.commit_hash = B.COMMITTER_HASH
