-------------------criar tabela ISSUES e issues_sonar
--IF Object_id('issues_sonar', 'U') IS NOT NULL 
--  DROP TABLE issues_sonar; 

--CREATE TABLE [dbo].[issues_sonar](
--	[id] [bigint]  NOT NULL,
--	[kee] [nvarchar](50) NOT NULL,
--	[rule_id] [int] NULL,
--	[severity] [nvarchar](10) NULL,
--	[manual_severity] [bit] NOT NULL,
--	[message] [nvarchar](4000) NULL,
--	[line] [int] NULL,
--	[gap] [decimal](30, 20) NULL,
--	[status] [nvarchar](20) NULL,
--	[resolution] [nvarchar](20) NULL,
--	[checksum] [nvarchar](1000) NULL,
--	[reporter] [nvarchar](255) NULL,
--	[assignee] [nvarchar](255) NULL,
--	[author_login] [nvarchar](255) NULL,
--	[action_plan_key] [nvarchar](50) NULL,
--	[issue_attributes] [nvarchar](4000) NULL,
--	[effort] [int] NULL,
--	[created_at] [bigint] NULL,
--	[updated_at] [bigint] NULL,
--	[issue_creation_date] [bigint] NULL,
--	[issue_update_date] [bigint] NULL,
--	[issue_close_date] [bigint] NULL,
--	[tags] [nvarchar](4000) NULL,
--	[component_uuid] [nvarchar](50) NULL,
--	[project_uuid] [nvarchar](50) NULL,
--	[locations] [varbinary](max) NULL,
--	[issue_type] [tinyint] NULL,
--	[from_hotspot] [bit] NULL,
--	[commit_hash] varchar(max),
--	insert_date datetime default getdate())



----USE [Repository2]
--GO

/****** Object:  Table [dbo].[ISSUES]    Script Date: 22/03/2020 13:13:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE TABLE [dbo].[ISSUES](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[ISSUE_ID] [bigint] NULL,
	[COMMITER_HASH] [varchar](500) NULL,
	INSERT_DATE DATETIME DEFAULT GETDATE()

PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO


SELECT ID,committer_hash into #COMMITS  FROM COMMITS WHERE processed = 1 ORDER BY 1 ASC

SELECT * FROM #COMMITS
WHILE ( (SELECT COUNT(0) FROM  #COMMITS) > 0)
BEGIN
		DECLARE @ID INT;
		DECLARE @committer_hash VARCHAR(50)
		SELECT TOP 1 @ID=  ID, @committer_hash = committer_hash  FROM #COMMITS  ORDER BY 1 ASC
		DELETE #COMMITS  WHERE committer_hash = @committer_hash;
		
		insert into [dbo].[ISSUES] ( [ISSUE_ID] ,[COMMITER_HASH],[INSERT_DATE]) 
		SELECT   A.ID,A.commit_hash,GETDATE()  FROM ISSUES_SONAR A (NOLOCK) WHERE commit_hash = @committer_hash
		AND A.id NOT IN (SELECT [ISSUE_ID] FROM [dbo].[ISSUES] )
		AND ISSUE_TYPE = 1 order by 1
END