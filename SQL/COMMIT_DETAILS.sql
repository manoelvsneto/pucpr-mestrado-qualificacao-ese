-----------------CRIAR TABELA  COMMITS_DETAIL E  COMMITS_DETAIL_PIVOT
CREATE TABLE COMMITS_DETAIL
(
ID BIGINT PRIMARY key IDENTITY(1,1),
[committer_hash] VARCHAR(60),
[change_type] VARCHAR(200),
[file_name] VARCHAR(500),
[added] INT ,
[removed] INT, 
[nloc] varchar(500) 
)
CREATE INDEX CD_INDEX ON COMMITS_DETAIL (committer_hash);


SELECT u.committer_hash , 
sum([DELETE]) as 'DEL' ,
sum([RENAME]) AS 'REN' ,
sum([MODIFY]) AS 'MOD' ,
sum([ADD]) AS 'ADD',
sum([UNKNOWN]) AS 'UNK'
INTO COMMITS_DETAIL_PIVOT
FROM COMMITS_DETAIL AS C
PIVOT (
  count([file_name]) FOR
  change_type IN ([DELETE],[RENAME],[MODIFY],[ADD],[UNKNOWN])
) AS U
group by committer_hash
CREATE INDEX CDP_INDEX ON COMMITS_DETAIL_PIVOT (committer_hash);

select * from COMMITS_DETAIL_PIVOT


SELECT C.*,P.DEL,P.REN,P.MOD,P.[ADD],P.UNK , P.DEL + P.REN + P.MOD + P.[ADD] + P.UNK AS 'TOT'
   FROM DATA_MODELO C  JOIN COMMITS_DETAIL_PIVOT P
ON C.committer_hash = P.committer_hash
ORDER BY 1


SELECT * FROM [dbo].[LOG_COMMIT_ACTION]  C LEFT JOIN COMMITS_DETAIL_PIVOT P
ON C.committer_hash = P.committer_hash
ORDER BY C.commit_date








