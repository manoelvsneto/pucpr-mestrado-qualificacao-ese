DROP TABLE ALLDATA
DROP TABLE DATA_MODELO 
DROP TABLE RULES_PIVOT
DROP TABLE RULES_SEVERITY_DEVELOPER
DROP TABLE APRIORI
DROP TABLE APRIORI_RULES
DROP TABLE VW_COMMITS
DROP TABLE TIME_SERIES_PREDICT
DROP TABLE TIME_SERIES
DROP TABLE ISSUES_TYPES
DROP TABLE PIVOT_DATA
DROP TABLE LOG_COMMIT_ACTION
SELECT * FROM [dbo].[ISSUES]
SELECT COUNT(0) FROM [dbo].[ISSUES_SONAR]