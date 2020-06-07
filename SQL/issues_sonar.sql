-------------------criar tabela ISSUES e issues_sonar
IF Object_id('issues_sonar', 'U') IS NOT NULL 
  DROP TABLE issues_sonar; 

CREATE TABLE [dbo].[issues_sonar](
	[id] [bigint]  NOT NULL,
	[kee] [nvarchar](50) NOT NULL,
	[rule_id] [int] NULL,
	[severity] [nvarchar](10) NULL,
	[manual_severity] [bit] NOT NULL,
	[message] [nvarchar](4000) NULL,
	[line] [int] NULL,
	[gap] [decimal](30, 20) NULL,
	[status] [nvarchar](20) NULL,
	[resolution] [nvarchar](20) NULL,
	[checksum] [nvarchar](1000) NULL,
	[reporter] [nvarchar](255) NULL,
	[assignee] [nvarchar](255) NULL,
	[author_login] [nvarchar](255) NULL,
	[action_plan_key] [nvarchar](50) NULL,
	[issue_attributes] [nvarchar](4000) NULL,
	[effort] [int] NULL,
	[created_at] [bigint] NULL,
	[updated_at] [bigint] NULL,
	[issue_creation_date] [bigint] NULL,
	[issue_update_date] [bigint] NULL,
	[issue_close_date] [bigint] NULL,
	[tags] [nvarchar](4000) NULL,
	[component_uuid] [nvarchar](50) NULL,
	[project_uuid] [nvarchar](50) NULL,
	[locations] [varbinary](max) NULL,
	[issue_type] [tinyint] NULL,
	[from_hotspot] [bit] NULL,
	[commit_hash] varchar(max),
	insert_date datetime default getdate())



--USE [Repository2]
GO

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
