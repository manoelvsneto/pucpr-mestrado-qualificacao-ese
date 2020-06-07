import pyodbc
from git import *
import time
import os

def deleteSonarProjectProperties(_project, _worker):
    path = f"C:\\processamento_sonar\\git-{_worker}\\sonar-scanner-{_project}\\bin\\sonar-project.properties"
    os.remove(path)
    time.sleep(1)


def updateCommit(_committer_hash, _project):
    conn = pyodbc.connect("Driver={SQL Server};"
                          "Server=localhost;"
                          "Database=Repository2;"
                          "uid=user;pwd=Password")
    cursor = conn.cursor()
    cursor.execute(
        f"update  commits set processed = 1 where committer_hash = '{_committer_hash}' and processed = 0")
    conn.commit()
    updateDate(_project,_committer_hash)


def updateDate(_project,_commiterHash):
    conn = pyodbc.connect("Driver={SQL Server};"
                          "Server=localhost;"
                          "Database=sonar;"
                          "uid=user;pwd=Password")
    cursor = conn.cursor()
    cursor.execute(
        f"update sonar.dbo.snapshots  set created_at = t.intdate, build_date = t.intdate from sonar.dbo.snapshots s join (select  distinct s.version ,CAST(Datediff(s, '1970-01-01',  convert(datetime, c.committer_date,103)) AS BIGINT) * 1000  as intdate from  sonar.dbo.project_measures pm (nolock)  inner join  sonar.dbo.metrics m (nolock) on m.id = pm.metric_id inner join sonar.dbo.snapshots s (nolock) on s.uuid = pm.analysis_uuid inner join sonar.dbo.projects p  (nolock) on p.uuid = pm.component_uuid  inner join repository2.dbo.commits c on c.committer_hash = '{_commiterHash}' where  p.name = '{_project}'  and s.version = '1.0.0.' +'{_commiterHash}' ) as t on s.version = t.version")
    conn.commit()


def writeSonarProjectProperties(_hash, _project, _worker):
    file = open(f"C:\\processamento_sonar\\git-{_worker}\\sonar-scanner-{_project}\\bin\\sonar-project.properties", 'w')
    file.writelines(f'sonar.projectKey={_project}\n')
    file.writelines(f'sonar.projectName={_project}\n')
    file.writelines(f'sonar.projectVersion=1.0.0.{_hash}\n')
    file.writelines(f'sonar.sources=C:/processamento_sonar/git-{_worker}/{_project}\n')
    file.writelines(f'sonar.projectBaseDir=C:/processamento_sonar/git-{_worker}/{_project}\n')
    file.writelines('sonar.sourceEncoding=UTF-8\n')
    file.writelines('sonar.scm.disabled=True\n')
    file.close()
    time.sleep(1)
    updateCommit(_hash, _project)
    generateBranch(_hash, _project, _worker)


def generateBranch(_hash, _project, _worker):
    repo = Repo(f'C:\\processamento_sonar\\git-{_worker}\\{_project}')
    new_branch = repo.create_head(f'branch_{_hash}', _hash)
    time.sleep(1)
    new_branch.checkout()
    time.sleep(1)
    filepath = f"C:\\processamento_sonar\\git-{_worker}\\sonar-scanner-{_project}\\bin\\sonar-scanner.bat"
    os.chdir(f'C:\\processamento_sonar\\git-{_worker}\\sonar-scanner-{_project}\\bin')
    os.system(filepath)
    islast(_project,_hash)


def setProject(_hash, _worker, _project):
    deleteSonarProjectProperties(_project, _worker)
    writeSonarProjectProperties(_hash, _project, _worker)


def islast(_project, _committer_hash):
    islastbool = 0
    while islastbool == 0:
        print(f"processando: {_committer_hash} 0")
        conn = pyodbc.connect("Driver={SQL Server};"
                              "Server=localhost;"
                              "Database=sonar;"
                              "uid=user;pwd=Password")
        cursor = conn.cursor()
        cursor.execute(f"select top 1 islast from sonar.dbo.snapshots s (nolock)   where s.version = '1.0.0.' + '{_committer_hash}'")
        records = cursor.fetchall()

        for row in records:
            islastbool = row[0]
            cursor.close()
            conn.close()

        if islastbool == 1:
            print(f"processando: {_committer_hash} 1")
            insertInssues(_project, _committer_hash)


def insertInssues(_project, _committer_hash):
    time.sleep(1)
    conn = pyodbc.connect("Driver={SQL Server};"
                          "Server=localhost;"
                          "Database=sonar;"
                          "uid=user;pwd=Password")
    cursor = conn.cursor()
    cursor.execute(
        f"insert into Repository2.[dbo].[issues_sonar] SELECT  s.*,'{_committer_hash}',GETDATE()  FROM sonar.dbo.issues s (nolock) where project_uuid  in  (select project_uuid from sonar.dbo.projects p(nolock) where p.name = '{_project}'  and enabled = 1 and scope = 'PRJ')")
    conn.commit()
    insertInssues2(_project,_committer_hash)

def insertInssues2(_project, _committer_hash):
    time.sleep(1)
    conn = pyodbc.connect("Driver={SQL Server};"
                          "Server=localhost;"
                          "Database=Repository2;"
                          "uid=user;pwd=Password")
    cursor = conn.cursor()
    cursor.execute(
            f"insert into [dbo].[ISSUES] ( [ISSUE_ID] ,[COMMITER_HASH],[INSERT_DATE]) SELECT  s.id,'{_committer_hash}',GETDATE()  FROM sonar.dbo.issues s (nolock) where project_uuid  in  (select project_uuid from sonar.dbo.projects p(nolock)  where p.name = '{_project}'  and enabled = 1 and scope = 'PRJ')   and id not in ( SELECT   [ISSUE_ID]   FROM Repository2.dbo.[ISSUES] (nolock) )")
    conn.commit()
    print('Concluido')


def selectHashs(_project, _worker):
    print('Iniciando')
    conn = pyodbc.connect("Driver={SQL Server};"
                          "Server=localhost;"
                          "Database=Repository2;"
                          "uid=user;pwd=Password")
    cursor = conn.cursor()
    cursor.execute(
        f"select  c.committer_hash from  Repository2.dbo.commits c  (nolock)  left join sonar.dbo.snapshots s   (nolock)  on s.version   COLLATE DATABASE_DEFAULT =  '1.0.0.'+c.committer_hash COLLATE DATABASE_DEFAULT where c.processed = 0 and c.project_name = '{_project}' and s.status is null order by c.id")
    row = cursor.fetchone()

    while row is not None:
        setProject(row[0], _worker, _project)
        row = cursor.fetchone()

    cursor.close()
    conn.close()


selectHashs('wordpress',2)
